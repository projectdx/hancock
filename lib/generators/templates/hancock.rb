require 'hancock'

Hancock.configure do |config|
  config.username       = 'hancock.docusign.test@gmail.com'
  config.password       = 'qweqwe123123'
  config.integrator_key = 'XXXX-72b4a74c-e8a2-4d59-82bf-c28219bf5ebb'
  config.account_id     = '482411'
  config.endpoint       = 'https://demo.docusign.net/restapi'
  config.api_version    = 'v2'

  # c.event_notification = {
  #   :logging_enabled => true,
  #   :uri => 'http://callback.com',
  #   :include_document => true,
  # }
  config.email_template = {
    :subject => 'subject from configuration',
    :blurb => 'blurb from configuration '
  }
end