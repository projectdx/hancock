shared_context "incorrect_configs" do
  before(:all) do 
    Hancock.configure do |config|
      config.username       = ***REMOVED***
      config.password       = '--------'
      config.integrator_key = ***REMOVED***
      config.account_id     = ***REMOVED***
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
  end
end