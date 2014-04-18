require_relative '../spec_helper'

describe Hancock::Configuration do

  let(:def_mock) do
    {
      :username       => ***REMOVED***,
      :password       => ***REMOVED***,
      :integrator_key => ***REMOVED***,
      :account_id     => ***REMOVED***,
      :endpoint       => 'https://demo.docusign.net/restapi',
      :api_version    => 'v2',
      :event_notification => {
        :connect_name => "EventNotification", #to identify connect configuration for notification
        :logging_enabled => true,
        :uri => 'https://qwerqwer.com/notifications',
        :include_documents => true,
      },
      :email_template => {
        :subject => 'subject from configuration',
        :blurb => 'blurb from configuration '
      }
    }
  end

  before(:all) do 
    Hancock.configure do |config|
      config.username           = def_mock[:username]
      config.password           = def_mock[:password]
      config.integrator_key     = def_mock[:integrator_key]
      config.account_id         = def_mock[:account_id]
      config.endpoint           = def_mock[:endpoint]
      config.api_version        = def_mock[:api_version]
      config.event_notification = def_mock[:event_notification]
      config.email_template     = def_mock[:email_template]
    end
  end

  describe 'It changes configurations with configure method' do

    it 'should change default username' do 
      Hancock.username.should eq(def_mock[:username])
    end

    it 'should change default password' do
      Hancock.password.should eq(def_mock[:password])
    end

    it 'should change default integrator_key' do
      Hancock.integrator_key.should eq(def_mock[:integrator_key])
    end

    it 'should change default account_id' do
      Hancock.account_id.should eq(def_mock[:account_id])
    end

    it 'should change default endpoint' do
      Hancock.endpoint.should eq(def_mock[:endpoint])
    end

    it 'should change default api_version' do
      Hancock.api_version.should eq(def_mock[:api_version])
    end

    it 'should change default event_notification' do
      Hancock.event_notification.should eq(def_mock[:event_notification])
    end

    it 'should change default email_template' do
      Hancock.email_template.should eq(def_mock[:email_template])
    end

  end

end