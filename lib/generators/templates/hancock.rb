require 'hancock'

Hancock.configure do |config|
  config.username       = 'hancock.docusign.test@gmail.com'
  config.password       = 'qweqwe123123'
  config.integrator_key = 'XXXX-72b4a74c-e8a2-4d59-82bf-c28219bf5ebb'
  config.account_id     = '482411'
  config.endpoint       = 'https://demo.docusign.net/restapi'
  config.api_version    = 'v2'

  config.event_notification = {
    :connect_name => "EventNotification", #to identify connect configuration for notification
    :logging_enabled => true,
    :uri => 'http://605d992.ngrok.com/', #your callback url
    :include_document => true,
  }
  
  config.email_template = {
    :subject => 'subject from configuration',
    :blurb => 'blurb from configuration '
  }
end

uri = URI.parse("#{Hancock.endpoint}/#{Hancock.api_version}/accounts/#{Hancock.account_id}/connect")

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

header = {
  'Content-Type' => 'application/json',
  'Accept' => 'json',
  'X-DocuSign-Authentication' => {
    'Username' => Hancock.username,
    'Password' => Hancock.password,
    'IntegratorKey' => Hancock.integrator_key
  }.to_json 
}

request = Net::HTTP::Get.new(uri.request_uri, header)
configurations = JSON.parse(http.request(request).body)["configurations"]

connect_configuration = configurations.find{|k| k["name"] == Hancock.event_notification[:connect_name]}

post_body = {
  urlToPublishTo: Hancock.event_notification[:uri],
  enableLog: Hancock.event_notification[:logging_enabled],
  includeDocuments: Hancock.event_notification[:include_documents],
  useSoapInterface: "false",
  name: Hancock.event_notification[:connect_name],
  envelopeEvents: "Delivered, Sent, Completed",
  recipientEvents: "Delivered, Sent, Completed"
}

if connect_configuration
  request = Net::HTTP::Put.new(uri.request_uri, header) 
  post_body.merge!({connectId: connect_configuration["connectId"]}) 
else
  request = Net::HTTP::Post.new(uri.request_uri, header)
end

request.body = post_body.to_json
http.request(request)

