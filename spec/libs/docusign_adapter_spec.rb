require_relative '../spec_helper'

describe Hancock::DocuSignAdapter do
  include_context "configs"
  include_context "variables"
  
  before do
    envelope.add_document(document)
    envelope.add_signature_request({ recipient: recipient, document: document, tabs: [tab] })
    envelope.save
    @connection = Hancock::DocuSignAdapter.new(envelope.identifier)
  end

  it "action 'envelope' should return the envelope info" do
    response = @connection.envelope

    response["envelopeId"].should == envelope.identifier
    response["status"].should == "created"
  end

  it "action 'documents' should return the documents info for current envelope" do
    documents = @connection.documents

    documents.length.should == 1
    documents.first["name"].should == "test"
  end

  it "action 'recipients' should return the recipients info for current envelope" do
    recipients = @connection.recipients

    recipients["signers"].count.should == 1
    recipients["editors"].count.should == 0
    recipients["signers"].first["name"].should == "Owner"
  end

  it "action 'document' should return the document info by id" do
    document = @connection.document("123")

    document.length.should > 50
    document[-3, 3].should == "EOF"
  end

end