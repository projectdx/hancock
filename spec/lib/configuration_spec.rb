describe Hancock::Configuration do
  let(:config_hash) do
    {
      :oauth_token    => 'abc-123-def-456-and-so-forth',
      :account_id     => 'the account ID of our account',
      :endpoint       => 'https://fake.docusign.example.com',
      :api_version    => 'of the future',
      :email_template => {
        :subject => 'subject from configuration',
        :blurb => 'blurb from configuration'
      },
      :minimum_document_data_size => 10000,
      :request_timeout_limit => 300
    }
  end


  before do
    Hancock.configure do |config|
      config.oauth_token                = config_hash[:oauth_token]
      config.account_id                 = config_hash[:account_id]
      config.endpoint                   = config_hash[:endpoint]
      config.api_version                = config_hash[:api_version]
      config.email_template             = config_hash[:email_template]
      config.minimum_document_data_size = config_hash[:minimum_document_data_size]
      config.request_timeout_limit      = config_hash[:request_timeout_limit]
    end
  end

  after do
    Hancock.reset
  end

  describe 'It changes configurations with configure method' do

    it 'should change default oauth_token' do
      expect(Hancock.oauth_token).to eq('abc-123-def-456-and-so-forth')
    end

    it 'should change default account_id' do
      expect(Hancock.account_id).to eq('the account ID of our account')
    end

    it 'should change default endpoint' do
      expect(Hancock.endpoint).to eq('https://fake.docusign.example.com')
    end

    it 'should change default api_version' do
      expect(Hancock.api_version).to eq('of the future')
    end

    it 'should change default email_template' do
      expect(Hancock.email_template[:subject]).to eq('subject from configuration')
      expect(Hancock.email_template[:blurb]).to eq('blurb from configuration')
    end

    it 'should change default minimum_document_data_size' do
      expect(Hancock.minimum_document_data_size).to eq(10000)
    end

    it 'should change default request_timeout_limit' do
      expect(Hancock.request_timeout_limit).to eq(300)
    end
  end
end
