require 'net/http'
require 'uri'
require 'openssl'
require 'json'

# Token used to terminate the file in the post body. Make sure it is not
# present in the file you're uploading.
BOUNDARY = 'myboundary'

uri = URI.parse('https://demo.docusign.net/restapi/v2/accounts/327367/envelopes')
file = 'test.pdf'

request_hash = {
  emailBlurb: 'eblurb',
  emailSubject: 'esubj',
  documents: [
    {
      documentId: '1',
      name: "#{File.basename(file)}"
    }
  ],
  recipients: {
    signers: [
      {
        email: ***REMOVED***,
        name: 'Test Guy',
        recipientId: '1'
      }
    ]
  },
  status: 'sent'
}

post_body = ''
post_body << "\r\n"
post_body << "--#{BOUNDARY}\r\n"
post_body << "Content-Type: application/json\r\n"
post_body << "Content-Disposition: form-data\r\n"
post_body << "\r\n"
post_body << request_hash.to_json
post_body << "\r\n"
post_body << "--#{BOUNDARY}\r\n"
post_body << "Content-Type: application/pdf\r\n"
post_body << "Content-Disposition: file; filename=\"#{File.basename(file)}\"; documentid=1\r\n"
post_body << "\r\n"
post_body << IO.read(file) #this includes the %PDF-1.3 and %%EOF wrapper
post_body << "\r\n"
post_body << "--#{BOUNDARY}--\r\n"

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_PEER

docusign_headers = %{
  <DocuSignCredentials>
    <Username>gmhawash@gmail.com</Username>
    <Password>seven11</Password>
    <IntegratorKey>RFXX-5e8080a0-88d3-4c41-94b6-d01674c2c4d8</IntegratorKey>
  </DocuSignCredentials>
}

headers = {
  'X-DocuSign-Authentication' => "#{docusign_headers}",
  'Content-Type'              => "multipart/form-data, boundary=#{BOUNDARY}",
  'Accept'                    => 'application/json',
  'Content-Length'            => "#{post_body.length}"
}

request = Net::HTTP::Post.new(uri.request_uri, headers)

request.body = post_body

response = http.request(request)

puts response.body
