describe Hancock::Envelope do
  include_context "configs"
  include_context "variables"
  
  before do
    envelope.add_document(document)
    envelope.add_signature_request({ recipient: recipient, document: document, tabs: [tab] })
  end

  describe '#save' do
    it "should send envelope with status 'created'" do
      allow(document).to receive(:data_for_request).and_return('hello world')
      stub_envelope_creation('create_draft', 'created')
      expect(envelope).to receive(:reload!)
      envelope.save
      expect(envelope.identifier).to eq 'a-crazy-envelope-id'
    end
  end

  describe '#send!' do
    it "should send envelope with status 'sent'" do
      allow(document).to receive(:data_for_request).and_return('hello world')
      stub_envelope_creation('send_envelope', 'sent')
      expect(envelope).to receive(:reload!)
      envelope.send!
      expect(envelope.identifier).to eq 'a-crazy-envelope-id'
    end
  end

  describe '.find' do
    it "should find envelope with given ID and #reload! it" do
      envelope = Hancock::Envelope.new(:identifier => 'a-crazy-envelope-id')
      allow(Hancock::DocuSignAdapter).to receive(:new).
        with('a-crazy-envelope-id').
        and_return(double(Hancock::DocuSignAdapter, :envelope => JSON.parse(response_body('envelope'))))

      envelope = double(Hancock::Envelope, :identifier => 'a-crazy-envelope-id')
      allow(described_class).to receive(:new).
        with(:status => 'sent', :identifier => 'a-crazy-envelope-id').
        and_return(envelope)

      expect(envelope).to receive(:reload!).and_return(envelope)
      expect(Hancock::Envelope.find('a-crazy-envelope-id')).to eq envelope
    end
  end

  describe '#new' do
    it "can set params on initialization" do
      envelope = Hancock::Envelope.new({
        documents: [:document],
        signature_requests: [:signature_request],
        email: {
          subject: 'Hello there',
          blurb: 'Please sign this!'
        }
      })

      expect(envelope.documents).to eq [:document]
      expect(envelope.signature_requests).to eq [:signature_request]
      expect(envelope.email).to eq({
        subject: 'Hello there',
        blurb: 'Please sign this!'
      })
    end
  end

  describe '#form_post_body' do
    it 'assembles body for posting' do
      doc1 = double(Hancock::Document, :multipart_form_part => 'Oh my', :to_request => 'horse')
      doc2 = double(Hancock::Document, :multipart_form_part => 'How wondrous', :to_request => 'pony')
      subject.documents = [doc1, doc2]
      subject.signature_requests = [:dummy_request]
      allow(subject).to receive(:get_recipients_for_request).
        with([:dummy_request]).
        and_return('the signature requests')
      subject.form_post_body(:a_status).should eq(
        "\r\n"\
        "--MYBOUNDARY\r\nContent-Type: application/json\r\n"\
        "Content-Disposition: form-data\r\n\r\n"\
        "{\"emailBlurb\":\"An Email Blurb\",\"emailSubject\":\"An Email Subject\","\
        "\"status\":\"a_status\",\"documents\":[\"horse\",\"pony\"],"\
        "\"recipients\":\"the signature requests\"}\r\n"\
        "--MYBOUNDARY\r\nOh my\r\n"\
        "--MYBOUNDARY\r\nHow wondrous\r\n"\
        "--MYBOUNDARY--\r\n"
      )
    end
  end
end