describe Hancock::Callback do
  let(:docusign_response) { JSON.parse(response_body('connect_configurations'))['configurations'] }

  before do
    allow(Hancock).to receive(:oauth_token).and_return('AnAmazingOAuthTokenShinyAndPink')
    allow(Hancock).to receive(:account_id).and_return(123456)
  end

  describe '.all' do
    it 'returns all existing connect configurations' do
      stub_request(:get, "https://demo.docusign.net/restapi/v2/accounts/123456/connect").
        with(:headers => {'Accept'=>'json', 'Authorization'=>'bearer AnAmazingOAuthTokenShinyAndPink', 'Content-Type'=>'application/json'}).
        to_return(:status => 200, :body => response_body('connect_configurations'), :headers => { 'Content-Type' => 'application/json'})

      allow(described_class).to receive(:from_docusign_response).
        with(docusign_response[0]).
        and_return(:a_connect)
      allow(described_class).to receive(:from_docusign_response).
        with(docusign_response[1]).
        and_return(:another_connect)
      expect(described_class.all).to match_array [:a_connect, :another_connect]
    end
  end

  describe '.from_docusign_response' do
    it 'returns a new callback instance that mirrors the docusign response hash' do
      new_callback = described_class.from_docusign_response(docusign_response.first)
      expect(new_callback).to eq Hancock::Callback.new({
        name: "Awesomeville",
        url: "http://awesomeville.com",
        active: true,
        logging: true,
        envelope_events: "Completed,Declined,Delivered,Sent,Signed,Voided",
        recipient_events: "Completed,Declined,Delivered,Sent,AuthenticationFailed,AutoResponded",
        include_documents: false,
        all_users: false,
        identifier: "1"
      })
    end
  end

  describe '.find_by_name' do
    it 'returns a saved connect configuration with the given name' do
      connect1 = described_class.new(:name => 'cadger')
      connect2 = described_class.new(:name => 'spoofy')
      allow(described_class).to receive(:all).and_return([connect1, connect2])
      expect(described_class.find_by_name('cadger')).to eq connect1
      expect(described_class.find_by_name('spoofy')).to eq connect2
    end

    it 'returns nil if no saved connect configuration exists with the given name' do
      allow(described_class).to receive(:all).and_return([])
      expect(described_class.find_by_name('cadger')).to be_nil
    end
  end

  describe "#save!" do
    it "updates an existing connect configuration with same name" do
      stub_request(:put, "https://demo.docusign.net/restapi/v2/accounts/123456/connect").
         with(:body => "{\"name\":\"cadger\",\"urlToPublishTo\":null,\"allowEnvelopePublish\":false,\"enableLog\":false,\"envelopeEvents\":null,\"recipientEvents\":null,\"includeDocuments\":false,\"allUsers\":false,\"connectId\":\"45\",\"useSoapInterface\":false}",
              :headers => {'Accept'=>'json', 'Authorization'=>'bearer AnAmazingOAuthTokenShinyAndPink', 'Content-Type'=>'application/json'}).
         to_return(:status => 200, :body => '{"connectId":"45"}', :headers => { 'Content-Type' => 'application/json' })

      connect1 = described_class.new(:name => 'cadger', :identifier => '45')
      allow(described_class).to receive(:find_by_name).
        with('cadger').
        and_return(connect1)
      connect1.save!
      expect(connect1.identifier).to eq '45'
    end

    it "creates a new connect configuration if name doesn't exist" do
      stub_request(:post, "https://demo.docusign.net/restapi/v2/accounts/123456/connect").
         with(:body => "{\"name\":\"cadger\",\"urlToPublishTo\":null,\"allowEnvelopePublish\":false,\"enableLog\":false,\"envelopeEvents\":null,\"recipientEvents\":null,\"includeDocuments\":false,\"allUsers\":false,\"connectId\":null,\"useSoapInterface\":false}",
              :headers => {'Accept'=>'json', 'Authorization'=>'bearer AnAmazingOAuthTokenShinyAndPink', 'Content-Type'=>'application/json'}).
         to_return(:status => 200, :body => '{"connectId":"1856"}', :headers => { 'Content-Type' => 'application/json' })

      connect1 = described_class.new(:name => 'cadger')
      allow(described_class).to receive(:find_by_name).
        with('cadger').
        and_return(nil)
      connect1.save!
      expect(connect1.identifier).to eq '1856'
    end
  end
end