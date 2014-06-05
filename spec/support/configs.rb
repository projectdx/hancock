shared_context "configs" do
  before(:all) do 
    Hancock.configure do |config|
      config.oauth_token    = 'AnAmazingOAuthTokenShinyAndPink'
      config.account_id     = '123456'
      config.endpoint       = 'https://demo.docusign.net/restapi'
      config.api_version    = 'v2'

      config.event_notification = {
        :connect_name => "Everyone Is Happy",
        :logging_enabled => true,
        :uri => 'http://everyoneishappy.com/callback',
        :include_documents => true,
      }
      
      config.email_template = {
        :subject => 'An Email Subject',
        :blurb => 'An Email Blurb'
      }
    end
  end
end