describe Hancock::Recipient::Recreator do
  before(:each) do
    allow(Hancock).to receive(:account_id).and_return(123456)
  end

  describe '#recreate_with_tabs' do
    let(:recipient) {
      Hancock::Recipient.new(
        :client_user_id      => '7890',
        :email               => 'actual_recipient@example.com',
        :envelope_identifier => '1234-5678-9012',
        :identifier          => '7890',
        :name                => 'Fred Flinstone',
        :recipient_type      => :signer,
        :embedded_start_url  => 'SIGN_AT_DOCUSIGN'
      )
    }
    let(:docusign_recipient) { recipient.send(:docusign_recipient) }

    subject { described_class.new(docusign_recipient) }

    before(:each) do
      allow(docusign_recipient).to receive(:tabs).and_return(double(:body => '{"rainbows":"butterflies"}'))
      allow(SecureRandom).to receive(:uuid).and_return('123-placeholder-id')
      stub_request(:any, %r{.*demo.docusign.net/.*})
        .to_return(:status => 200, :body => "", :headers => {})
    end

    it 'creates a placeholder recipient' do
      subject.recreate_with_tabs

      expect(WebMock).to have_requested(:post, "https://demo.docusign.net/restapi/v2/accounts/123456/envelopes/1234-5678-9012/recipients")
        .with(
          :body => "{\"signers\":[{\"clientUserId\":\"123-placeholder-id\",\"email\":\"placeholder@example.com\",\"name\":\"Placeholder while recreating recipient\",\"recipientId\":\"123-placeholder-id\",\"routingOrder\":1,\"requireIdLookup\":true,\"idCheckConfigurationName\":\"ID Check $\",\"embeddedRecipientStartURL\":null}]}",
          :headers => {'Accept'=>'application/json', 'Authorization'=>'bearer', 'Content-Type'=>'application/json'}
        )
    end

    it 'deletes the recipient' do
      subject.recreate_with_tabs

      expect(WebMock).to have_requested(:delete, "https://demo.docusign.net/restapi/v2/accounts/123456/envelopes/1234-5678-9012/recipients")
        .with(
          :body => "{\"signers\":[{\"recipientId\":\"7890\"}]}",
          :headers => {'Accept'=>'application/json', 'Authorization'=>'bearer', 'Content-Type'=>'application/json'})
    end

    it 'recreates the recipient' do
      subject.recreate_with_tabs

      expect(WebMock).to have_requested(:post, "https://demo.docusign.net/restapi/v2/accounts/123456/envelopes/1234-5678-9012/recipients")
        .with(
          :body => "{\"signers\":[{\"clientUserId\":\"7890\",\"email\":\"actual_recipient@example.com\",\"name\":\"Fred Flinstone\",\"recipientId\":\"7890\",\"routingOrder\":1,\"requireIdLookup\":true,\"idCheckConfigurationName\":\"ID Check $\",\"embeddedRecipientStartURL\":\"SIGN_AT_DOCUSIGN\"}]}",
          :headers => {'Accept'=>'application/json', 'Authorization'=>'bearer', 'Content-Type'=>'application/json'})
    end

    it 'recreates tabs for the recipient if there were any' do
      subject.recreate_with_tabs

      expect(WebMock).to have_requested(:post, "https://demo.docusign.net/restapi/v2/accounts/123456/envelopes/1234-5678-9012/recipients/7890/tabs")
        .with(
          :body => "{\"rainbows\":\"butterflies\"}",
          :headers => {'Accept'=>'application/json', 'Authorization'=>'bearer', 'Content-Type'=>'application/json'})
    end

    it 'does not recreate tabs if there were originally none' do
      allow(docusign_recipient).to receive(:tabs).and_return(double(:body => '{}'))

      subject.recreate_with_tabs

      expect(WebMock).not_to have_requested(:post, "https://demo.docusign.net/restapi/v2/accounts/123456/envelopes/1234-5678-9012/recipients/7890/tabs")
    end

    it 'deletes the placeholder' do
      subject.recreate_with_tabs

      expect(WebMock).to have_requested(:delete, "https://demo.docusign.net/restapi/v2/accounts/123456/envelopes/1234-5678-9012/recipients")
        .with(
          :body => "{\"signers\":[{\"recipientId\":\"123-placeholder-id\"}]}",
          :headers => {'Accept'=>'application/json', 'Authorization'=>'bearer', 'Content-Type'=>'application/json'})
    end
  end
end
