module RequestStubHelper
  def stub_envelope_creation(request_type, response_type, response_code = 201)
    stub_request(:post, "https://demo.docusign.net/restapi/v2/accounts/123456/envelopes").
      with(
        :headers => auth_headers.merge('Content-Type' => 'multipart/form-data; boundary=MYBOUNDARY'),
        :body => request_body(request_type)
      ).
      to_return(:status => response_code, :body => response_body(response_type), :headers => { 'Content-Type' => 'application/json'})
  end

  def stub_status_change(identifier, new_status, response_type, response_code = 200)
    stub_request(:put, "https://demo.docusign.net/restapi/v2/accounts/123456/envelopes/#{identifier}").
      with(
        :headers => auth_headers.merge('Content-Type' => 'application/json'),
        :body => { "status" => new_status }.to_json
      ).
      to_return(:status => response_code, :body => response_body(response_type), :headers => { 'Content-Type' => 'application/json'})
  end

  def auth_headers
    {
      'Accept' => 'json',
      'Authorization' => 'bearer AnAmazingOAuthTokenShinyAndPink'
    }
  end
end
