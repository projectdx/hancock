shared_context "configs" do
  before(:all) do 
    Hancock.configure do |c|
      c.username       = ***REMOVED***
      c.password       = ***REMOVED***
      c.integrator_key = ***REMOVED***
      c.account_id     = ***REMOVED***
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