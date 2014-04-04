require 'hancock'

Hancock.configure do |config|
  config.username       = 'gmhawash@gmail.com'
  config.password       = 'WhatIs25*25'
  config.integrator_key = 'RFXX-5e8080a0-88d3-4c41-94b6-d01674c2c4d8'
  config.account_id     = '443799'
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