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

    expect { envelope.save }.to raise_error( Hancock::DocusignError )
  end

  it "helper 'send_post_request' should return response code 401(Unauthorized)" do 
    response = send_post_request("/accounts/#{Hancock.account_id}/views/console", "", header)
    response.code.should == '401' 
  end

  it "helper 'send_get_request' should return response code 401(Unauthorized)" do 
    response = send_get_request("/login_information")
    response.code.should == '401' 
  end
end