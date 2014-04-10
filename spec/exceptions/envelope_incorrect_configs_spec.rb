require_relative '../spec_helper'

describe Hancock::Envelope do
  include_context "incorrect_configs"
  include_context "variables"

  it "should raise error because of bad configs" do
    envelope.add_document(document)
    envelope.add_signature_request({ 
      recipient: recipient, 
      document:  document, 
      tabs:      [tab] 
    })

    lambda { envelope.save }.should raise_error( Hancock::DocusignError )
  end

  it "helper 'send_post_request' should return response code 401(Unauthorized)" do 
    uri = build_uri("/oauth2/token")
    body = "username=#{Hancock.username}&password=#{Hancock.password}&client_id=#{Hancock.integrator_key}&grant_type=password&scope=api"
    response = send_post_request(uri, body, bad_header)
    response.code.should == '401' 
  end
end