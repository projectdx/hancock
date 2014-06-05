module RequestStubHelper
  def stub_envelope_creation(request_type, response_type)
    stub_request(:post, "https://demo.docusign.net/restapi/v2/accounts/123456/envelopes").
      with(:headers => {
        'Accept' => 'json',
        'Authorization' => 'bearer AnAmazingOAuthTokenShinyAndPink',
        'Content-Type' => 'multipart/form-data; boundary=MYBOUNDARY'
      }, :body => request_body(request_type)).
      to_return(:status => 201, :body => response_body(response_type), :headers => { 'Content-Type' => 'application/json'})
  end
end
