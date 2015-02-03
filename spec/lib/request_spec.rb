describe Hancock::Request do
  before { allow(Hancock).to receive(:oauth_token).and_return('AnAmazingOAuthTokenShinyAndPink') }

  describe '#send_get_request' do
    it "sends a get request to DocuSign and returns response" do
      stub_request(:get, "https://demo.docusign.net/restapi/v2/something_exciting").
         with(:headers => {'Accept'=>'json', 'Authorization'=>'bearer AnAmazingOAuthTokenShinyAndPink', 'Content-Type'=>'application/json'}).
         to_return(:status => 200, :body => "the body", :headers => {})
      response = described_class.send_get_request("/something_exciting")
      expect(response.success?).to be_truthy
      expect(response.parsed_response).to eq 'the body'
    end
  end

  describe '#send_post_request' do
    it "sends a post request to DocuSign and returns response" do
      stub_request(:post, "https://demo.docusign.net/restapi/v2/whatever").
         with(:headers => {'Accept'=>'Yourself'}, :body => 'alien sandwiches').
         to_return(:status => 201, :body => "bodylicious", :headers => {})
      response = described_class.send_post_request("/whatever", 'alien sandwiches', 'Accept' => 'Yourself')
      expect(response.success?).to be_truthy
      expect(response.parsed_response).to eq 'bodylicious'
    end
  end

  describe '#send_put_request' do
    it "sends a put request to DocuSign and returns response" do
      stub_request(:put, "https://demo.docusign.net/restapi/v2/ghost_racquetball").
         with(:headers => {'Header' => 'Shoulderer'}, :body => 'you will rue bidets').
         to_return(:status => 200, :body => "grassy knolls", :headers => {})
      response = described_class.send_put_request("/ghost_racquetball", 'you will rue bidets', 'Header' => 'Shoulderer')
      expect(response.success?).to be_truthy
      expect(response.parsed_response).to eq 'grassy knolls'
    end
  end

  describe '#get_headers' do
    let(:default_headers) { { 'Accept' => 'json', 'Authorization' => "bearer AnAmazingOAuthTokenShinyAndPink" } }

    it "returns Accept and Authorization headers" do
      expect(described_class.get_headers).to eq default_headers
    end

    it 'merges given headers with default headers' do
      content_headers = { 'Content-Type' => "multipart/form-data, boundary='AAA'"}

      expect(described_class.get_headers(content_headers)).
        to eq default_headers.merge!(content_headers)
    end
  end
end
