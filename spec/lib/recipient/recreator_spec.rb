describe Hancock::Recipient::Recreator do
  def reload_placeholder_stub
    load(File.join(File.dirname(__FILE__), "..", "..", "fixtures", "placeholder_stub.rb"))
  end

  before(:each) do
    allow(Hancock).to receive(:account_id).and_return(123456)
    allow(SecureRandom).to receive(:uuid).and_return('123-placeholder-id')
    allow(docusign_recipient).to receive(:tabs).and_return(double(:body => '{"rainbows":"butterflies"}'))
    reload_placeholder_stub
  end

  let(:recipient) {
    Hancock::Recipient.new(
      :client_user_id      => '7890',
      :email               => 'actual_recipient@example.com',
      :envelope_identifier => '1234-5678-9012',
      :identifier          => '7890',
      :name                => 'Fred Flinstone',
      :recipient_type      => :signer,
      :embedded_start_url  => 'place to start!',
      :routing_order       => 2_000
    )
  }

  let(:docusign_recipient) { recipient.send(:docusign_recipient) }

  subject { described_class.new(docusign_recipient) }

  describe 'during initialization' do
    it 'catches INVALID_CLIENT_ID response when fetching tabs' do
      allow(docusign_recipient).to receive(:tabs).and_raise(Hancock::Request::RequestError.new("400 - INVALID_RECIPIENT_ID - A recipient ID is missing or invalid."))
      expect{ subject.recreate_with_tabs }.not_to raise_error
    end

    it 'does not ignore errors other than INVALID_CLIENT_ID' do
      allow(docusign_recipient).to receive(:tabs).and_raise(Hancock::Request::RequestError.new("500 - STUFF_WENT_WRONG - BORKED!"))
      expect{ subject.recreate_with_tabs }.to raise_error(Hancock::Request::RequestError)
    end
  end

  describe '#recreate_with_tabs' do
    it 'creates a placeholder recipient' do
      expect(subject.placeholder_docusign_recipient).to receive(:create).once.and_call_original
      subject.recreate_with_tabs

      expect(WebMock).to have_requested(:post, "https://demo.docusign.net/restapi/v2/accounts/123456/envelopes/1234-5678-9012/recipients")
        .with(
          :body => "{\"signers\":[{\"clientUserId\":\"123-placeholder-id\",\"email\":\"placeholder@example.com\",\"name\":\"Placeholder while recreating recipient\",\"recipientId\":\"123-placeholder-id\",\"routingOrder\":2000,\"requireIdLookup\":true,\"idCheckConfigurationName\":\"ID Check $\",\"embeddedRecipientStartURL\":null}]}"
        )
    end

    it 'deletes the recipient' do
      expect(docusign_recipient).to receive(:delete).once.and_call_original
      subject.recreate_with_tabs

      expect(WebMock).to have_requested(:delete, "https://demo.docusign.net/restapi/v2/accounts/123456/envelopes/1234-5678-9012/recipients")
        .with(:body => "{\"signers\":[{\"recipientId\":\"7890\"}]}")
    end

    it 'recreates the recipient' do
      expect(docusign_recipient).to receive(:create).once.and_call_original
      subject.recreate_with_tabs

      expect(WebMock).to have_requested(:post, "https://demo.docusign.net/restapi/v2/accounts/123456/envelopes/1234-5678-9012/recipients")
        .with(
          :body => "{\"signers\":[{\"clientUserId\":\"7890\",\"email\":\"actual_recipient@example.com\",\"name\":\"Fred Flinstone\",\"recipientId\":\"7890\",\"routingOrder\":2000,\"requireIdLookup\":true,\"idCheckConfigurationName\":\"ID Check $\",\"embeddedRecipientStartURL\":\"place to start!\"}]}"
        )
    end

    it 'recreates tabs for the recipient if there were any' do
      expect(docusign_recipient).to receive(:create_tabs).with(subject.tabs).once.and_call_original
      subject.recreate_with_tabs

      expect(WebMock).to have_requested(:post, "https://demo.docusign.net/restapi/v2/accounts/123456/envelopes/1234-5678-9012/recipients/7890/tabs")
        .with(:body => "{\"rainbows\":\"butterflies\"}")
    end

    it 'does not recreate tabs if there were originally none' do
      allow(docusign_recipient).to receive(:tabs).and_return(double(:body => '{}'))
      expect(docusign_recipient).not_to receive(:create_tabs)
      expect(subject.tabs).to be_empty

      subject.recreate_with_tabs

      expect(WebMock).not_to have_requested(:post, "https://demo.docusign.net/restapi/v2/accounts/123456/envelopes/1234-5678-9012/recipients/7890/tabs")
    end

    it "keeps tabs empty and non-nil when recovering from previous error" do
      allow(docusign_recipient).to receive(:tabs).and_raise(Hancock::Request::RequestError.new("400 - INVALID_RECIPIENT_ID - A recipient ID is missing or invalid."))
      expect(docusign_recipient).not_to receive(:create_tabs)
      expect(subject.tabs).to be_empty

      subject.recreate_with_tabs

      expect(WebMock).not_to have_requested(:post, "https://demo.docusign.net/restapi/v2/accounts/123456/envelopes/1234-5678-9012/recipients/7890/tabs")
    end

    it 'deletes the placeholder' do
      subject.recreate_with_tabs

      expect(WebMock).to have_requested(:delete, "https://demo.docusign.net/restapi/v2/accounts/123456/envelopes/1234-5678-9012/recipients")
        .with(:body => "{\"signers\":[{\"recipientId\":\"123-placeholder-id\"}]}")
    end

    it 'retries 3 times on timeout errors' do
      # receive delete 4 times due to 3 retries and 1 success
      expect(docusign_recipient).to receive(:delete).exactly(4).times.and_call_original

      stub_request(:delete, %r(https://demo.docusign.net/restapi/v2/accounts/123456/envelopes/.+/recipients)).to_timeout
      begin
        subject.recreate_with_tabs
      rescue Timeout::Error => e
        reload_placeholder_stub
        subject.recreate_with_tabs
      end
    end

    it 'does not retry errors other than Timeout' do
      allow(Hancock::Recipient).to receive(:fetch_for_envelope).and_raise(Hancock::Request::RequestError.new("500 - STUFF_WENT_WRONG - BORKED!"))
      expect{ subject.recreate_with_tabs }.to raise_error(Hancock::Request::RequestError)
    end

    it 'sends delete for all placeholder recipients' do
      allow(Hancock).to receive(:account_id).and_return(654321)
      expect(Hancock::Recipient).to receive(:fetch_for_envelope).once.and_call_original

      subject.recreate_with_tabs
      expect(a_request(:delete, "https://demo.docusign.net/restapi/v2/accounts/654321/envelopes/1234-5678-9012/recipients")
        .with(:body => "{\"signers\":[{\"recipientId\":\"123-placeholder-id\"}]}")).to have_been_made.times(3)
    end
  end
end
