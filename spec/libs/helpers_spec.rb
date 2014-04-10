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

  it "helper 'send_post_request' should return response code 200(OK)" do 
    uri = build_uri("/oauth2/token")
    body = "username=#{Hancock.username}&password=#{Hancock.password}&client_id=#{Hancock.integrator_key}&grant_type=password&scope=api"
    response = send_post_request(uri, body, header)
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

  it "helper 'get_response' should return response code 200(OK)" do    
    response = get_response("/login_information")
    response.code.should == '200' 
  end

  it "helper 'get_content_type_for' should return correct content type" do    
    type = get_content_type_for(:json)
    type.should == "Content-Type: application/json\r\nContent-Disposition: form-data\r\n\r\n"
  end

  it "helper 'get_content_type_for' with file parameter should return correct content type" do    
    type = get_content_type_for(:pdf, document)
    type.should == "Content-Type: application/pdf\r\nContent-Disposition: file; filename=test; documentid=123\r\n\r\n"
  end

  it "helper 'get_event_notification' should return correct hash" do    
    hash = get_event_notification
    hash[:url].should == Hancock.event_notification[:url]
    hash[:loggingEnabled].should == Hancock.event_notification[:logging_enabled]
    hash[:includeDocuments].should == Hancock.event_notification[:include_documents]
  end
end