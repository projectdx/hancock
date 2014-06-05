describe Hancock::Envelope do
  before do
    allow(Hancock).to receive(:oauth_token).and_return('AnAmazingOAuthTokenShinyAndPink')
    allow(Hancock).to receive(:account_id).and_return(123456)
  end

  context 'sending envelopes' do
    before do
      allow(subject).to receive(:documents_for_params).and_return('the_documents')
      allow(subject).to receive(:documents_for_body).and_return(['hello world'])
      allow(subject).to receive(:signature_requests_for_params).and_return('the_requests')
      allow(subject).to receive(:email).and_return({ :subject => 'fubject', :blurb => 'flurb'})
    end

    describe '#save' do
      it "should send envelope with status 'created'" do
        stub_envelope_creation('create_draft', 'created')
        expect(subject).to receive(:reload!)
        subject.save
        expect(subject.identifier).to eq 'a-crazy-envelope-id'
      end

      it 'raises a DocusignError with the returned message if not successful' do
        stub_envelope_creation('create_draft', 'failed_creation', 500)
        expect {
          subject.save
        }.to raise_error(Hancock::DocusignError, "Nobody actually loves you; they just pretend until payday.")
      end
    end

    describe '#send!' do
      it "should send envelope with status 'sent'" do
        stub_envelope_creation('send_envelope', 'sent')
        expect(subject).to receive(:reload!)
        subject.send!
        expect(subject.identifier).to eq 'a-crazy-envelope-id'
      end

      it 'raises a DocusignError with the returned message if not successful' do
        stub_envelope_creation('send_envelope', 'failed_creation', 500)
        expect {
          subject.send!
        }.to raise_error(Hancock::DocusignError, "Nobody actually loves you; they just pretend until payday.")
      end
    end
  end

  describe '#reload!' do
    it 'reloads status, documents, and recipients from DocuSign' do
      subject.identifier = 'crayons'
      allow(Hancock::DocuSignAdapter).to receive(:new).
        with('crayons').
        and_return(double('adapter', :envelope => {
          'status' => 'bullfree',
          'emailSubject' => 'Subjacked',
          'emailBlurb' => 'Blurble'
        }))
      allow(Hancock::Document).to receive(:fetch_for_envelope).
        with(subject).
        and_return(:le_documeneaux)
      allow(Hancock::Recipient).to receive(:fetch_for_envelope).
        with(subject).
        and_return(:le_recipierre)

      expect(subject.reload!).to eq subject
      expect(subject.status).to eq 'bullfree'
      expect(subject.email).to eq({:subject => 'Subjacked', :blurb => 'Blurble'})
      expect(subject.documents).to eq :le_documeneaux
      expect(subject.recipients).to eq :le_recipierre
    end

    it 'is safe to call even if no identifier' do
      subject.identifier = nil
      expect {
        subject.reload!
      }.not_to raise_error
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

  describe '#add_signature_request' do
    it 'adds a signature request to the envelope, and caches recipients' do
      attributes = {
        :recipient => :a_recipient,
        :document => :a_document,
        :tabs => [:tab1, :tab2]
      }
      subject.add_signature_request(attributes)
      expect(subject.signature_requests).to eq [attributes]
      expect(subject.recipients).to eq [:a_recipient]
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

  describe '#signature_requests_for_params' do
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
      expect(subject.signature_requests_for_params).to eq({
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
      allow(subject).to receive(:email).and_return({ :subject => 'fubject', :blurb => 'flurb'})
      doc1 = double(Hancock::Document, :multipart_form_part => 'Oh my', :to_request => 'horse')
      doc2 = double(Hancock::Document, :multipart_form_part => 'How wondrous', :to_request => 'pony')
      subject.documents = [doc1, doc2]
      allow(subject).to receive(:signature_requests_for_params).
        and_return('the signature requests')
      subject.form_post_body(:a_status).should eq(
        "\r\n"\
        "--MYBOUNDARY\r\nContent-Type: application/json\r\n"\
        "Content-Disposition: form-data\r\n\r\n"\
        "{\"emailBlurb\":\"flurb\",\"emailSubject\":\"fubject\","\
        "\"status\":\"a_status\",\"documents\":[\"horse\",\"pony\"],"\
        "\"recipients\":\"the signature requests\"}\r\n"\
        "--MYBOUNDARY\r\nOh my\r\n"\
        "--MYBOUNDARY\r\nHow wondrous\r\n"\
        "--MYBOUNDARY--\r\n"
      )
    end
  end
end