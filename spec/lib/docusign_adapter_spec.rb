describe Hancock::DocuSignAdapter do
  before do
    allow(Hancock).to receive(:oauth_token).and_return('AnAmazingOAuthTokenShinyAndPink')
    allow(Hancock).to receive(:account_id).and_return(123456)
    @connection = Hancock::DocuSignAdapter.new('a-crazy-envelope-id')
  end

  describe '#envelope' do
    it "returns info for the requested envelope" do
      stub_request(:get, "https://demo.docusign.net/restapi/v2/accounts/123456/envelopes/a-crazy-envelope-id").
        with(:headers => {'Accept'=>'application/json', 'Authorization'=>'bearer AnAmazingOAuthTokenShinyAndPink', 'Content-Type'=>'application/json'}).
        to_return(:status => 200, :body => response_body('envelope'), :headers => { 'Content-Type' => 'application/json' })

      response = @connection.envelope

      expect(response["envelopeId"]).to eq "a-crazy-envelope-id"
      expect(response["status"]).to eq "sent"
    end
  end

  describe '#documents' do
    it "return document info for all of the requested envelopes' documents" do
      stub_request(:get, "https://demo.docusign.net/restapi/v2/accounts/123456/envelopes/a-crazy-envelope-id/documents").
        with(:headers => {'Accept'=>'application/json', 'Authorization'=>'bearer AnAmazingOAuthTokenShinyAndPink', 'Content-Type'=>'application/json'}).
        to_return(:status => 200, :body => response_body('documents'), :headers => { 'Content-Type' => 'application/json' })

      documents = @connection.documents

      expect(documents.size).to eq(3)
      expect(documents.first["name"]).to eq 'Cool Document'
    end
  end

  describe '#recipients' do
    it "returns info about the recipients for the current envelope" do
      stub_request(:get, "https://demo.docusign.net/restapi/v2/accounts/123456/envelopes/a-crazy-envelope-id/recipients").
        with(:headers => {'Accept'=>'application/json', 'Authorization'=>'bearer AnAmazingOAuthTokenShinyAndPink', 'Content-Type'=>'application/json'}).
        to_return(:status => 200, :body => response_body('recipients'), :headers => { 'Content-Type' => 'application/json' })

      recipients = @connection.recipients

      expect(recipients["signers"].size).to eq(2)
      expect(recipients["editors"].size).to eq(0)
      expect(recipients["signers"].first["name"]).to eq "Darwin Nerdwod"
    end
  end

  describe '#document' do
    it "returns the bytes for the requested document on an envelope" do
      stub_request(:get, "https://demo.docusign.net/restapi/v2/accounts/123456/envelopes/a-crazy-envelope-id/documents/123").
        with(:headers => {'Accept'=>'application/json', 'Authorization'=>'bearer AnAmazingOAuthTokenShinyAndPink', 'Content-Type'=>'application/json'}).
        to_return(:status => 200, :body => File.read(fixture_path('test.pdf')).strip, :headers => { 'Content-Type' => 'application/pdf' })

      document = @connection.document("123")

      expect(document).to eq File.read(fixture_path('test.pdf')).strip
    end
  end
end
