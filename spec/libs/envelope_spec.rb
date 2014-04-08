require_relative '../spec_helper'

describe Hancock::Envelope do
  include_context "configs"
  include_context "variables"
  
  before do
    envelope.add_document(document)
    envelope.add_signature_request(recipient, document, [tab])
  end

  it "should send envelope with status 'created'" do
    envelope.save
    envelope.status.should == "created" 
  end

  it "should send envelope with status 'sent'" do
    envelope.send!
    envelope.status.should == "sent" 
  end

  it "should find envelope with status id" do
    envelope.save

    en = Hancock::Envelope.find(envelope.identifier)
    en.identifier.should == envelope.identifier 
  end

  it "should send envelope with status 'created' in one call" do
    envelope1 = Hancock::Envelope.new({
      documents: [document],
      signature_requests: [
        {
          recipient: recipient,
          document: document,
          tabs: [tab],
        },
      ],
      email: {
        subject: 'Hello there',
        blurb: 'Please sign this!'
      }
    })

    envelope1.save
    envelope1.status.should == "created"
    envelope1.identifier.should_not == nil
  end

  it "action 'documents' should return correct result" do
    envelope.save
    documents = envelope.documents

    documents.length.should == 1
    documents.first.name.should == "test"
  end

  it "action 'recipients' should return correct result" do
    envelope.save
    recipients = envelope.recipients

    recipients.length.should == 1
    recipients.first.name.should == "Owner"
  end

end