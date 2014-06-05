require_relative '../spec_helper'

describe Hancock::Envelope do
  include_context "configs"
  include_context "variables"
  
  before do
    envelope.add_document(document)
    envelope.add_signature_request({ recipient: recipient, document: document, tabs: [tab] })
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

  describe '#form_post_body' do
    it 'assembles body for posting' do
      doc1 = double(Hancock::Document, :data_for_request => 'Oh my')
      doc2 = double(Hancock::Document, :data_for_request => 'How wondrous')
      subject.documents = [doc1, doc2]
      allow(subject).to receive(:get_content_type_for).with(:json).
        and_return('JSON Content Type')
      allow(subject).to receive(:get_content_type_for).with(:pdf, doc1).
        and_return('Document 1 Content Type')
      allow(subject).to receive(:get_content_type_for).with(:pdf, doc2).
        and_return('Document 2 Content Type')
      allow(subject).to receive(:get_post_params).with(:a_status).
        and_return({ :foo => :bar })
      subject.form_post_body(:a_status).should eq(
        "\r\n"\
        "--MYBOUNDARY\r\nJSON Content Type{\"foo\":\"bar\"}\r\n"\
        "--MYBOUNDARY\r\nDocument 1 Content TypeOh my\r\n"\
        "--MYBOUNDARY\r\nDocument 2 Content TypeHow wondrous\r\n"\
        "--MYBOUNDARY--\r\n"
      )
    end
  end
end