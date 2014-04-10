require_relative '../spec_helper'
include Hancock::Helpers

describe Hancock::Helpers do
  include_context "configs"
  include_context "variables"

  it "helper 'send_get_request' should return response code 200(OK)" do 
    uri = build_uri("/login_information")
    response = send_get_request(uri, header)
    response.code.should == '200' 
  end

  it "helper 'send_get_request' should return response code 401(Unauthorized)" do 
    uri = build_uri("/login_information")
    response = send_get_request(uri, bad_header)
    response.code.should == '401' 
  end

  it "helper 'build_uri' should return correct uri" do 
    uri = build_uri("/login_information")
    uri.to_s.should == "https://demo.docusign.net/restapi/v2/login_information"
  end
end