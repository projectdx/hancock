describe Hancock::Configuration do
  let(:config_hash) do
    {
      :oauth_token    => 'smarmle fumpit newtroph yumgi',
      :account_id     => '482411',
      :endpoint       => 'https://demo.docusign.net/restapi',
      :api_version    => 'v2',
      :email_template => {
        :subject => 'subject from configuration',
        :blurb => 'blurb from configuration '
      }
    }
  end


  before do 
    Hancock.configure do |config|
      config.oauth_token        = config_hash[:oauth_token]
      config.account_id         = config_hash[:account_id]
      config.endpoint           = config_hash[:endpoint]
      config.api_version        = config_hash[:api_version]
      config.email_template     = config_hash[:email_template]
    end
  end

  after do
    Hancock.reset
  end

  describe 'It changes configurations with configure method' do

    it 'should change default oauth_token' do 
      Hancock.oauth_token.should eq(config_hash[:oauth_token])
    end

    it 'should change default account_id' do
      Hancock.account_id.should eq(config_hash[:account_id])
    end

    it 'should change default endpoint' do
      Hancock.endpoint.should eq(config_hash[:endpoint])
    end

    it 'should change default api_version' do
      Hancock.api_version.should eq(config_hash[:api_version])
    end

    it 'should change default email_template' do
      Hancock.email_template.should eq(config_hash[:email_template])
    end

  end
end