require 'hancock'

Hancock.configure do |c|
   c.username       = 'awesome@whereever.com'
   c.password       = '12345'
   c.integrator_key = 'YAY-9ED8E711-C191-4265-AFCC-253F6241207A'
   c.account_id     = '999999'
   c.endpoint       = 'https://www.docusign.net/restapi'
   c.api_version    = 'v2'

  # c.event_notification = {
  #   :logging_enabled => true,
  #   :uri => 'http://callback.com',
  #   :include_document => true,
  # }
  # c.email_template = {
  #   :subject => 'sign me',
  #   :blurb => 'whatever '
  # }
end