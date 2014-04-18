require_relative '../spec_helper'
include Hancock::Helpers

describe Hancock::Helpers do
  include_context "configs"
  include_context "variables"

  it "helper 'send_get_request' should return response code 200(OK)" do 
    response = send_get_request("/login_information")
    response.code.should == '200' 
  end

  it "helper 'send_post_request' should return response code 201(Created)" do 
    uri = build_uri("/accounts/#{Hancock.account_id}/views/console")
    response = send_post_request(uri, "", header)
    response.code.should == '201' 
  end

  it "helper 'send_put_request' should return response code 200(OK)" do 
    uri = build_uri("/accounts/#{Hancock.account_id}/settings")
    
    put_body = {
      accountSettings: [{
        name: "allowSignerReassign",
        value: true
      }]
    }.to_json

    content_headers = { 'Content-Type' => 'application/json' }

    response = send_put_request(uri, put_body, get_headers(content_headers))
    response.code.should == '200' 
  end

  it "helper 'get_headers' should return correct get_headers" do    
    content_headers = { 'Content-Type' => "multipart/form-data, boundary='AAA'"}

    generated_header = get_headers(content_headers)
    generated_header.should == header.merge!(content_headers)
  end

  it "helper 'get_recipients_for_request' should return correct recipient" do    
    signature_requests = [{ recipient: recipient, document: document, tabs: [tab] }]

    recipients = get_recipients_for_request(signature_requests)
    recipients["signers"].count.should == 1
    recipients["editors"].count.should == 0
    recipients["signers"].first[:name] == "Owner"
  end

  it "helper 'get_content_type_for' should return correct content type" do    
    type = get_content_type_for(:json)
    type.should == "Content-Type: application/json\r\nContent-Disposition: form-data\r\n\r\n"
  end

  it "helper 'get_content_type_for' with file parameter should return correct content type" do    
    type = get_content_type_for(:pdf, document)
    type.should == "Content-Type: application/pdf\r\nContent-Disposition: file; filename=test; documentid=123\r\n\r\n"
  end
end