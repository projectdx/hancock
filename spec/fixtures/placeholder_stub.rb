def read_fixtures(file_name)
  File.read(
    File.join(File.dirname(__FILE__), "#{file_name}")
  )
end

placeholder_recipient_response = read_fixtures('response_bodies/recipients_with_placeholders.json')
multiple_placeholders_response = read_fixtures('response_bodies/multiple_placeholders_response.json')

WebMock
  .stub_request(:any, %r{.+demo.docusign.net/.+})
  .to_return(:status => 200, :body => "", :headers => {})

WebMock
  .stub_request(
    :get, %r{https://demo.docusign.net/restapi/v2/accounts/\d+/envelopes/.+/recipients$}
  )
  .to_return(
    :status => 200,
    :body => placeholder_recipient_response,
    :headers => {
      "Content-type" => "application/json",
    }
  )

WebMock
  .stub_request(
    :get, %r{https://demo.docusign.net/restapi/v2/accounts/654321/envelopes/.+/recipients$}
  )
  .to_return(
    :status => 200,
    :body => multiple_placeholders_response,
    :headers => {
      "Content-type" => "application/json",
    }
  )
