describe Hancock::Request do
  before do
    allow(Hancock).to receive(:account_id).and_return(123_456)
    allow(Hancock).to receive(:oauth_token).and_return('AnAmazingOAuthTokenShinyAndPink')
  end

  describe '#send_get_request' do
    it 'sends a request and receives a parsed body' do
      stub_request(:get, 'https://demo.docusign.net/restapi/v2/accounts/123456/something_exciting')
        .with(
          :headers => {
            'Accept' => 'application/json',
            'Authorization' => 'bearer AnAmazingOAuthTokenShinyAndPink'
          })
        .to_return(
          :status => 200,
          :body => '{"message": "the body"}',
          :headers => { 'Content-Type' => 'application/json' })
      response = described_class.send_get_request('/something_exciting')
      expect(response.success?).to be_truthy
      expect(response.parsed_response).to eq({'message' => 'the body'})
    end

    it 'raises an error for any non-200 response status' do
      stub_request(:get, 'https://demo.docusign.net/restapi/v2/accounts/123456/something_exciting')
        .to_return(
          :status => 404,
          :body => { :errorCode => 'WANNA', :message => 'An error message' }.to_json,
          :headers => { 'Content-Type' => 'application/json' })
      expect {
        described_class.send_get_request('/something_exciting')
      }.to raise_error(Hancock::Request::RequestError, '404 - WANNA - An error message')
    end
  end

  describe '#send_delete_request' do
    it 'sends a delete request to DocuSign and returns response' do
      stub_request(:delete, 'https://demo.docusign.net/restapi/v2/accounts/123456/something_exciting')
        .with(
          :headers => {
            'Accept' => 'application/json',
            'Authorization' => 'bearer AnAmazingOAuthTokenShinyAndPink',
            'Content-Type' => 'application/json'
          })
        .to_return(
          :status => 200,
          :body => '{"message": "the body"}',
          :headers => { 'Content-Type' => 'application/json' })
      response = described_class.send_delete_request('/something_exciting', '{}')
      expect(response.success?).to be_truthy
      expect(response.parsed_response).to eq({'message' => 'the body'})
    end

    it 'raises an error for any non-200 response status' do
      stub_request(:delete, 'https://demo.docusign.net/restapi/v2/accounts/123456/something_exciting')
        .to_return(
          :status => 404,
          :body => { :errorCode => 'WANNA', :message => 'An error message' }.to_json,
          :headers => { 'Content-Type' => 'application/json' })
      expect {
        described_class.send_delete_request('/something_exciting', '{}')
      }.to raise_error(Hancock::Request::RequestError, '404 - WANNA - An error message')
    end
  end

  describe '#send_post_request' do
    it 'sends a post request to DocuSign and returns response' do
      stub_request(:post, 'https://demo.docusign.net/restapi/v2/accounts/123456/whatever')
        .with(
          :headers => {
            'Accept' => 'Yourself',
            'Authorization' => 'bearer AnAmazingOAuthTokenShinyAndPink',
          },
          :body => 'alien sandwiches')
        .to_return(
          :status => 201,
          :body => '{"message": "bodylicious"}',
          :headers => { 'Content-Type' => 'application/json' })
      response = described_class.send_post_request('/whatever', 'alien sandwiches', 'Accept' => 'Yourself')
      expect(response.success?).to be true
      expect(response.parsed_response).to eq({ 'message' => 'bodylicious' })
    end

    it 'raises an error for any non-200 response status' do
      stub_request(:post, 'https://demo.docusign.net/restapi/v2/accounts/123456/something_exciting')
        .to_return(
          :status => 404,
          :body => { :errorCode => 'WANNA', :message => 'An error message' }.to_json,
          :headers => { 'Content-Type' => 'application/json' })
      expect {
        described_class.send_post_request('/something_exciting', 'alien sandwiches')
      }.to raise_error(Hancock::Request::RequestError, '404 - WANNA - An error message')
    end
  end

  describe '#send_put_request' do
    it 'sends a put request to DocuSign and returns response' do
      stub_request(:put, 'https://demo.docusign.net/restapi/v2/accounts/123456/ghost_racquetball')
        .with(
          :headers => {
            'Accept' => 'application/json',
            'Authorization' => 'bearer AnAmazingOAuthTokenShinyAndPink',
            'Content-Type' => 'application/json'
          },
          :body => 'you will rue bidets')
        .to_return(
          :status => 200,
          :body => '{ "message": "grassy knolls" }',
          :headers => { 'Content-Type' => 'application/json' })
      response = described_class.send_put_request('/ghost_racquetball', 'you will rue bidets')
      expect(response.success?).to be_truthy
      expect(response.parsed_response).to eq('message' => 'grassy knolls')
    end

    it 'raises an error for any non-200 response status' do
      stub_request(:put, 'https://demo.docusign.net/restapi/v2/accounts/123456/something_exciting')
        .to_return(
          :status => 404,
          :body => { :errorCode => 'WANNA', :message => 'An error message' }.to_json,
          :headers => { 'Content-Type' => 'application/json' })
      expect {
        described_class.send_put_request('/something_exciting', 'you will rue bidets')
      }.to raise_error(Hancock::Request::RequestError, '404 - WANNA - An error message')
    end
  end

  describe '#merge_headers' do
    let(:default_headers) {
      {
        'Accept' => 'application/json',
        'Authorization' => 'bearer AnAmazingOAuthTokenShinyAndPink',
        'Content-Type' => 'application/json'
      }
    }

    it "returns Accept and Authorization headers" do
      expect(described_class.merge_headers).to eq default_headers
    end

    it 'merges given headers with default headers' do
      content_headers = { 'Content-Type' => "multipart/form-data, boundary='AAA'"}

      expect(described_class.merge_headers(content_headers)).
        to eq default_headers.merge!(content_headers)
    end
  end
end
