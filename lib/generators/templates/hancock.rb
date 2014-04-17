require 'hancock'

Hancock.configure do |config|
  config.username       = ***REMOVED***
  config.password       = ***REMOVED***
  config.integrator_key = ***REMOVED***
  config.account_id     = ***REMOVED***
  config.endpoint       = 'https://demo.docusign.net/restapi'
  config.api_version    = 'v2'

  config.event_notification = {
    :connect_name => "EventNotification", #to identify connect configuration for notification
    :logging_enabled => true,
    :uri => ***REMOVED***,
    :include_documents => true,
  }
  
  config.email_template = {
    :subject => 'subject from configuration',
    :blurb => 'blurb from configuration '
  }
end