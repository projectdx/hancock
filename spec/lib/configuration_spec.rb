require_relative '../spec_helper'
include Hancock::Helpers

describe Hancock::Configuration do
  include_context "variables"

  before do 
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

  describe "It should create and update configurations with 'set_connect' method" do

    it "action 'set_connect' should update connect configuration" do
      response = JSON.parse(Hancock.set_connect.body)

      response["name"].should == Hancock.event_notification[:connect_name]
      response["urlToPublishTo"].should == Hancock.event_notification[:uri]
      response["includeDocuments"].should == Hancock.event_notification[:include_documents].to_s
    end

    it "action 'set_connect' should create connect configuration" do
      configs = JSON.parse(send_get_request("/accounts/#{Hancock.account_id}/connect").body)["configurations"]
      connect_configuration = configs.find{|k| k["name"] == Hancock.event_notification[:connect_name]} if configs

      if connect_configuration
        uri = build_uri("/accounts/#{Hancock.account_id}/connect/#{connect_configuration["connectId"]}")
        http = initialize_http(uri)

        content_headers = { 'Content-Type' => 'application/json' }

        request = Net::HTTP::Delete.new(uri.request_uri, get_headers(content_headers))
        http.request(request).code.should == "200"
      end

      configs = JSON.parse(send_get_request("/accounts/#{Hancock.account_id}/connect").body)["configurations"]
      configs.find{|k| k["name"] == Hancock.event_notification[:connect_name]}.should == nil
      
      response = JSON.parse(Hancock.set_connect.body)

      response["name"].should == Hancock.event_notification[:connect_name]
      response["urlToPublishTo"].should == Hancock.event_notification[:uri]
      response["includeDocuments"].should == Hancock.event_notification[:include_documents].to_s
    end

  end

end