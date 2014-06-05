describe Hancock::Helpers do
  include Hancock::Helpers

  before { allow(Hancock).to receive(:oauth_token).and_return('AnAmazingOAuthTokenShinyAndPink') }

  describe '#send_get_request' do
    it "sends a get request to DocuSign and returns response" do
      stub_request(:get, "https://demo.docusign.net/restapi/v2/something_exciting").
         with(:headers => {'Accept'=>'json', 'Authorization'=>'bearer AnAmazingOAuthTokenShinyAndPink', 'Content-Type'=>'application/json'}).
         to_return(:status => 200, :body => "the body", :headers => {})
      response = send_get_request("/something_exciting")
      expect(response).to be_success
      expect(response.parsed_response).to eq 'the body'
    end
  end

  describe '#send_post_request' do
    it "sends a post request to DocuSign and returns response" do
      stub_request(:post, "https://demo.docusign.net/restapi/v2/whatever").
         with(:headers => {'Accept'=>'Yourself'}, :body => 'alien sandwiches').
         to_return(:status => 201, :body => "bodylicious", :headers => {})
      response = send_post_request("/whatever", 'alien sandwiches', 'Accept' => 'Yourself')
      expect(response).to be_success
      expect(response.parsed_response).to eq 'bodylicious'
    end
  end

  describe '#send_put_request' do
    it "sends a put request to DocuSign and returns response" do
      stub_request(:put, "https://demo.docusign.net/restapi/v2/ghost_racquetball").
         with(:headers => {'Header' => 'Shoulderer'}, :body => 'you will rue bidets').
         to_return(:status => 200, :body => "grassy knolls", :headers => {})
      response = send_put_request("/ghost_racquetball", 'you will rue bidets', 'Header' => 'Shoulderer')
      expect(response).to be_success
      expect(response.parsed_response).to eq 'grassy knolls'
    end
  end

  describe '#get_headers' do
    let(:default_headers) { { 'Accept' => 'json', 'Authorization' => "bearer AnAmazingOAuthTokenShinyAndPink" } }

    it "returns Accept and Authorization headers" do
      expect(get_headers).to eq default_headers
    end

    it 'merges given headers with default headers' do
      content_headers = { 'Content-Type' => "multipart/form-data, boundary='AAA'"}

      expect(get_headers(content_headers)).
        to eq default_headers.merge!(content_headers)
    end
  end

  describe '#get_recipients_for_request' do
    it 'returns recipients hash grouped by signer type' do
      recipient1 = Hancock::Recipient.new(:name => 'Frog King', :email => 'frog@owner.owner', :identifier => '7', :recipient_type => 'signer')
      recipient2 = Hancock::Recipient.new(:name => 'Dr. Nurse', :email => 'drnurse@owner.owner', :identifier => '11', :recipient_type => 'signer')
      recipient3 = Hancock::Recipient.new(:name => 'Lurky', :email => 'lurky@lurking.lurk', :identifier => '31', :recipient_type => 'editor')
      tab = Hancock::Tab.new(type: "sign_here", label: "Gopher", coordinates: [2, 100], page_number: 1)
      document = Hancock::Document.new( data: 'yay hello', name: "test", extension: "pdf", identifier: 123 )

      signature_requests = [
        { recipient: recipient1, document: document, tabs: [tab] },
        { recipient: recipient2, document: document, tabs: [tab] },
        { recipient: recipient3, document: document, tabs: [tab] }
      ]

      recipients = get_recipients_for_request(signature_requests)
      expect(recipients["signers"]).to have(2).items
      expect(recipients["editors"]).to have(1).item
      expect(recipients["signers"].map { |s| s[:name] }).to eq(['Frog King', 'Dr. Nurse'])
      expect(recipients["editors"].map { |s| s[:name] }).to eq(['Lurky'])
    end
  end
end