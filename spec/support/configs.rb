shared_context "configs" do
  before(:all) do 
    Hancock.configure do |c|
      c.username       = 'gmhawash@gmail.com'
      c.password       = 'WhatIs25*25'
      c.integrator_key = 'RFXX-5e8080a0-88d3-4c41-94b6-d01674c2c4d8'
      c.account_id     = '443799'
      c.endpoint       = 'https://demo.docusign.net/restapi'
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
  end
end