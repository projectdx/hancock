describe Hancock::Request do
  before do
    Hancock.account_id = 123456
    allow(Hancock).to receive(:oauth_token).and_return('AnAmazingOAuthTokenShinyAndPink')
  end

  describe '#send_get_request' do
    it 'sends a request and receives a parsed body' do
      stub_request(:get, 'https://demo.docusign.net/restapi/v2/accounts/123456/something_exciting')
        .with(:headers => { 'Accept' => 'json', 'Authorization' => 'bearer AnAmazingOAuthTokenShinyAndPink', 'Content-Type' => 'application/json' })
        .to_return(:status => 200, :body => 'the body')
      response = described_class.send_get_request('/something_exciting')
      expect(response.success?).to be_truthy
      expect(response.parsed_response).to eq 'the body'
    end

    it 'raises an error for any non-200 response status' do
      stub_request(:get, 'https://demo.docusign.net/restapi/v2/accounts/123456/something_exciting')
        .to_return(:status => 404, :body => { :errorCode => 'WANNA', :message => 'An error message' }.to_json)
      expect { described_class.send_get_request('/something_exciting') }.to raise_error(
        Hancock::Request::RequestError, '404 - WANNA - An error message')
    end
  end

  describe '#send_delete_request' do
    it 'sends a delete request to DocuSign and returns response' do
      stub_request(:delete, 'https://demo.docusign.net/restapi/v2/accounts/123456/something_exciting')
        .with(:headers => { 'Accept' => 'json', 'Authorization' => 'bearer AnAmazingOAuthTokenShinyAndPink', 'Content-Type' => 'application/json' })
        .to_return(:status => 200, :body => 'the body', :headers => {})
      response = described_class.send_delete_request('/something_exciting', '{}')
      expect(response.success?).to be_truthy
      expect(response.parsed_response).to eq 'the body'
    end

    it 'raises an error for any non-200 response status' do
      stub_request(:delete, 'https://demo.docusign.net/restapi/v2/accounts/123456/something_exciting')
        .to_return(:status => 404, :body => { :errorCode => 'WANNA', :message => 'An error message' }.to_json)
      expect { described_class.send_delete_request('/something_exciting', '{}') }.to raise_error(
        Hancock::Request::RequestError, '404 - WANNA - An error message')
    end
  end

  describe '#send_post_request' do
    it 'sends a post request to DocuSign and returns response' do
      stub_request(:post, 'https://demo.docusign.net/restapi/v2/accounts/123456/whatever')
        .with(:headers => { 'Accept' => 'Yourself' }, :body => 'alien sandwiches')
        .to_return(:status => 201, :body => '{"message": "bodylicious"}', :headers => {})
      response = described_class.send_post_request('/whatever', 'alien sandwiches', 'Accept' => 'Yourself')
      expect(response.success?).to be true
      expect(response.body).to eq '{"message": "bodylicious"}'
    end

    it 'raises an error for any non-200 response status' do
      stub_request(:post, 'https://demo.docusign.net/restapi/v2/accounts/123456/something_exciting')
        .to_return(:status => 404, :body => { :errorCode => 'WANNA', :message => 'An error message' }.to_json)
      expect { described_class.send_post_request('/something_exciting', 'alien sandwiches', 'Accept' => 'Yourself') }.to raise_error(
        Hancock::Request::RequestError, '404 - WANNA - An error message')
    end
  end

  describe '#send_put_request' do
    it 'sends a put request to DocuSign and returns response' do
      stub_request(:put, 'https://demo.docusign.net/restapi/v2/accounts/123456/ghost_racquetball')
        .with(:headers => { 'Header' => 'Shoulderer' }, :body => 'you will rue bidets')
        .to_return(:status => 200, :body => 'grassy knolls', :headers => {})
      response = described_class.send_put_request('/ghost_racquetball', 'you will rue bidets', 'Header' => 'Shoulderer')
      expect(response.success?).to be_truthy
      expect(response.parsed_response).to eq 'grassy knolls'
    end

    it 'raises an error for any non-200 response status' do
      stub_request(:put, 'https://demo.docusign.net/restapi/v2/accounts/123456/something_exciting')
        .to_return(:status => 404, :body => { :errorCode => 'WANNA', :message => 'An error message' }.to_json)
      expect { described_class.send_put_request('/something_exciting', 'you will rue bidets', 'Header' => 'Shoulderer') }.to raise_error(
        Hancock::Request::RequestError, '404 - WANNA - An error message')
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
