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

  describe '#signature_requests_for_submission' do
    it 'returns signature requests grouped by recipient and set up for submission' do
      document1 = Hancock::Document.new(:identifier => 1)
      document2 = Hancock::Document.new(:identifier => 2)
      recipient1 = Hancock::Recipient.new(:email => 'b@mail.com', :name => 'Bob', :recipient_type => :signer, :identifier => 1)
      recipient2 = Hancock::Recipient.new(:email => 'e@mail.com', :name => 'Edna', :recipient_type => :signer, :identifier => 2)
      recipient3 = Hancock::Recipient.new(:email => 'f@mail.com', :name => 'Fump', :recipient_type => :editor, :identifier => 3)
      tab1 = double(Hancock::Tab, :type => 'initial_here', :to_h => { :initial => :here })
      tab2 = double(Hancock::Tab, :type => 'sign_here', :to_h => { :sign => :here })
      subject = described_class.new({
        :signature_requests => [
          { :recipient => recipient1, :document => document1, :tabs => [tab1] },
          { :recipient => recipient1, :document => document2, :tabs => [tab1, tab2] },
          { :recipient => recipient2, :document => document1, :tabs => [tab2] },
          { :recipient => recipient2, :document => document2, :tabs => [tab1] },
          { :recipient => recipient3, :document => document2, :tabs => [tab2] },
        ]
      })
      expect(subject.signature_requests_for_submission).to eq({
        'signers' => [
          {
            :email => 'b@mail.com', :name => 'Bob', :recipientId => 1, :tabs => {
              :initialHereTabs => [
                { :initial => :here, :documentId => 1 },
                { :initial => :here, :documentId => 2 },
              ],
              :signHereTabs => [
                { :sign => :here, :documentId => 2 },
              ]
            },
          },
          {
            :email => 'e@mail.com', :name => 'Edna', :recipientId => 2, :tabs => {
              :initialHereTabs => [
                { :initial => :here, :documentId => 2 },
              ],
              :signHereTabs => [
                { :sign => :here, :documentId => 1 },
              ]
            }
          }
        ],
        'editors' => [
          {
            :email => 'f@mail.com', :name => 'Fump', :recipientId => 3, :tabs => {
              :signHereTabs => [
                { :sign => :here, :documentId => 2 },
              ]
            }
          }
        ]
      })
    end
  end

  describe '#form_post_body' do
    it 'assembles body for posting' do
      doc1 = double(Hancock::Document, :multipart_form_part => 'Oh my', :to_request => 'horse')
      doc2 = double(Hancock::Document, :multipart_form_part => 'How wondrous', :to_request => 'pony')
      subject.documents = [doc1, doc2]
      allow(subject).to receive(:signature_requests_for_submission).
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