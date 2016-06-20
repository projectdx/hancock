describe Hancock::Envelope do
  before do
    allow(Hancock).to receive(:account_id).and_return(123_456)
  end

  context 'validations' do
    def association(klass, identifier: nil, validity: true)
      association = klass.new(identifier: identifier)
      allow(association).to receive(:valid?).and_return(validity)
      association
    end

    let(:recipient) do
      recipient = association(Hancock::Recipient)
      recipient.email = 'bananana@example.com'
      allow(recipient).to receive(:valid?).and_return(true)
      recipient
    end

    it { is_expected.to have_valid(:status).when('yay look a status') }
    it { is_expected.not_to have_valid(:status).when("", nil) }
    it { is_expected.to have_valid(:recipients).when([recipient]) }
    it { is_expected.not_to have_valid(:recipients).when([], nil, [:not_a_recipient], [association(Hancock::Recipient, :validity => false)]) }
    it { is_expected.to have_valid(:documents).when([association(Hancock::Document)]) }
    it { is_expected.not_to have_valid(:documents).when([], nil, [:not_a_document], [association(Hancock::Document, :validity => false)]) }
  end

  context 'with valid envelope' do
    before do
      allow(subject).to receive(:valid?).and_return(true)
      allow(Hancock).to receive(:oauth_token).and_return('AnAmazingOAuthTokenShinyAndPink')
      allow(Hancock).to receive(:account_id).and_return(123456)
    end

    describe '#save' do
      it 'calls #send_envelope' do
        expect(subject).to receive(:send_envelope)
        subject.save
      end

      it 'sets the status to created' do
        allow(subject).to receive(:send_envelope).and_return true

        subject.status = nil
        subject.save
        expect(subject.status).to eq('created')
      end

      it 'raises exception if envelope already has identifier' do
        subject.identifier = 'smokey-heaven'
        expect {
          subject.save
        }.to raise_error(described_class::AlreadySavedError)
      end
    end

    describe '#send!' do
      it 'calls #send_envelope' do
        expect(subject).to receive(:send_envelope)
        subject.send!
      end

      it 'sets the status to created' do
        allow(subject).to receive(:send_envelope).and_return true

        subject.status = nil
        subject.send!
        expect(subject.status).to eq('sent')
      end

      it 'calls #change_status with "sent" argument if draft' do
        subject.identifier = 'smokey-heaven'
        subject.status = 'created'
        expect(subject).to receive(:change_status!).with('sent')
        subject.send!
      end

      it 'raises exception if envelope has already been sent' do
        subject.identifier = 'smokey-heaven'
        subject.status = 'sent'
        expect {
          subject.send!
        }.to raise_error(described_class::AlreadySentError)
      end
    end

    describe '#change_status!' do
      it 'requests a status change with DocuSign for the envelope and reloads' do
        subject.identifier = 'smokey-heaven'
        stub_status_change('smokey-heaven', 'froop', 'changed_status')
        expect(subject).to receive(:reload!)
        subject.change_status!('froop')
      end

      it 'raises exception if envelope has no identifier' do
        expect {
          subject.change_status!('foo')
        }.to raise_error(described_class::NotSavedYet)
      end

      it "raises an error with the returned message if not successful" do
        response = {"errorCode" => "UNEDUCATED_FELON_ERROR", "message" => "Umbrella smoothie is bad idea."}
        subject.identifier = 'smokey-heaven'
        stub_status_change('smokey-heaven', 'floosh', 'failed_status_change', 400)
        expect {
          subject.change_status!('floosh')
        }.to raise_error(Hancock::Request::RequestError, "400 - #{response}")
      end
    end

    describe '#send_envelope' do
      before do
        allow(subject).to receive(:documents_for_params).and_return('the_documents')
        allow(subject).to receive(:documents_for_body).and_return(['hello world'])
        allow(subject).to receive(:signature_requests_for_params).and_return('the_requests')
        allow(subject).to receive(:email).and_return({ :subject => 'fubject', :blurb => 'flurb'})
      end

      it 'raises an exception if envelope is not valid' do
        allow(subject).to receive(:valid?).and_return(false)
        allow(subject).to receive_message_chain(:errors, :full_messages).and_return(
          ['rice pudding', 'wheat berries']
        )

        expect { subject.send! }.to raise_error(
          described_class::InvalidEnvelopeError, 'rice pudding; wheat berries'
        )
      end

      it 'raises an exception if Hancock not configured' do
        allow(Hancock).to receive(:configured?).and_return(false)
        expect {
          subject.send!
        }.to raise_error(Hancock::ConfigurationMissing)
      end

      context 'document ids' do
        before(:each) do
          stub_envelope_creation('send_envelope', 'envelope_sent')
          allow(subject).to receive(:reload!)
          subject.documents << Hancock::Document.new
          subject.documents << Hancock::Document.new
        end

        it "should add unique positive integer ids on sending" do
          subject.send!

          expect(subject.documents.map(&:identifier).all?{|x| x.integer? && x > 0}).to be_truthy
          expect(subject.documents.map(&:identifier).uniq.length).to eq(subject.documents.length)
        end

        it "should preserve existing ids" do
          subject.documents[0].identifier = 3
          subject.documents[1].identifier = 4

          subject.send!

          expect(subject.documents.map(&:identifier)).to eq([3,4])
        end

        it "should preserve existing ids and generate missing ones" do
          subject.documents[1].identifier = 6

          subject.send!

          expect(subject.documents.map(&:identifier)).to eq([7,6])
        end
      end

      context 'recipient ids' do
        before(:each) do
          stub_envelope_creation('send_envelope', 'envelope_sent')
          allow(subject).to receive(:reload!)
          subject.recipients << Hancock::Recipient.new
          subject.recipients << Hancock::Recipient.new
        end

        it "should add unique positive integer ids on sending" do
          subject.send!

          expect(subject.recipients.map(&:identifier).all?{|x| x.integer? && x > 0}).to be_truthy
          expect(subject.recipients.map(&:identifier).uniq.length).to eq(subject.recipients.length)
        end

        it "should preserve existing ids" do
          subject.recipients[0].identifier = 3
          subject.recipients[1].identifier = 4

          subject.send!

          expect(subject.recipients.map(&:identifier)).to eq([3,4])
        end

        it "should preserve existing ids and generate missing ones" do
          subject.recipients[1].identifier = 6

          subject.send!

          expect(subject.recipients.map(&:identifier)).to eq([7,6])
        end
      end

      context 'carbon-copy embedded viewers' do
        let(:document1) { Hancock::Document.new(:identifier => 1, :name => 'test.pdf', :data => 'happiness is mine!') }
        let(:recipient1) { Hancock::Recipient.new(:email => 'b@mail.com', :name => 'Bob', :recipient_type => :signer, :identifier => 1) }
        let(:recipient2) { Hancock::Recipient.new(:email => 'e@mail.com', :name => 'Edna', :recipient_type => :signer, :identifier => 2, :id_check => false) }
        let(:tab1) { instance_double(Hancock::Tab, :type => 'initial_here', :to_h => { :initial => :here }) }

        subject {
          described_class.new(
            :signature_requests => [
              { :recipient => recipient1, :document => document1, :tabs => [tab1] },
            ],
            :email => { :subject => 'fubject', :blurb => 'flurb'}
          )
        }

        before do
          allow(subject).to receive(:signature_requests_for_params).and_call_original
          allow(subject).to receive(:reload!)
        end

        it 'only sends normal recipients in the first post' do
          subject.add_signature_request({ :recipient => recipient2, :document => document1, :tabs => [tab1] })

          expect(Hancock::Request)
            .to receive(:send_post_request)
            .with('/envelopes', anything, anything)
            .and_return({ 'envelopeId' => 'a-crazy-envelope-id' })
          expect(Hancock::Request)
            .to_not receive(:send_post_request)
            .with('/envelopes/a-crazy-envelope-id/recipients', anything)
          subject.send!
        end

        it 'adds regular carbon-copy recipients in the first post' do
          recipient2.recipient_type = :carbon_copy
          subject.add_signature_request({ :recipient => recipient2, :document => document1, :tabs => [tab1] })

          expect(Hancock::Request)
            .to receive(:send_post_request)
            .with('/envelopes', /.*carbonCopies.*/, anything)
            .and_return({ 'envelopeId' => 'a-crazy-envelope-id' })
          expect(Hancock::Request)
            .to_not receive(:send_post_request)
            .with('/envelopes/a-crazy-envelope-id/recipients', anything)
          subject.send!
        end

        it 'sends embedded carbon-copy recipients in a second post' do
          recipient2.recipient_type = :carbon_copy
          recipient2.client_user_id = '13'
          subject.add_signature_request({ :recipient => recipient2, :document => document1, :tabs => [tab1] })

          expect(Hancock::Request)
            .to_not receive(:send_post_request)
            .with('/envelopes', /.*carbonCopies.*/, anything)
          expect(Hancock::Request)
            .to receive(:send_post_request)
            .with('/envelopes', /.*signers.*/, anything)
            .and_return({ 'envelopeId' => 'a-crazy-envelope-id' })
          expect(Hancock::Request)
            .to receive(:send_post_request)
            .with('/envelopes/a-crazy-envelope-id/recipients', /.*carbonCopies.*/)
          subject.send!
        end

        it 'creates a blank envelope if there are only carbon_copy recipients' do
          recipient1.recipient_type = :carbon_copy
          recipient1.client_user_id = '12'
          recipient2.recipient_type = :carbon_copy
          recipient2.client_user_id = '13'
          subject = described_class.new(
            :signature_requests => [
              { :recipient => recipient1, :document => document1, :tabs => [tab1] },
              { :recipient => recipient2, :document => document1, :tabs => [tab1] }
            ],
            :email => { :subject => 'fubject', :blurb => 'flurb'}
          )
          allow(subject).to receive(:signature_requests_for_params).and_call_original
          allow(subject).to receive(:reload!)

          expect(Hancock::Request)
            .to receive(:send_post_request)
            .with('/envelopes', /.*\"recipients\":{}.*/, anything)
            .and_return({ 'envelopeId' => 'a-crazy-envelope-id' })
          expect(Hancock::Request)
            .to receive(:send_post_request)
            .with('/envelopes/a-crazy-envelope-id/recipients', /.*carbonCopies.*/)
            .twice

          subject.send!
        end
      end

      context 'successful send' do
        let!(:request_stub) { stub_envelope_creation('send_envelope', 'envelope_sent') }
        before do
          allow(subject).to receive(:reload!)
        end

        it "sends envelope with given status" do
          subject.send!
          expect(request_stub).to have_been_requested
        end

        it 'calls #reload!' do
          expect(subject).to receive(:reload!)
          subject.send!
        end

        it 'sets the identifier to whatever DocuSign returned' do
          subject.send!
          expect(subject.identifier).to eq 'a-crazy-envelope-id'
        end
      end

      context 'unsuccessful send' do
        let(:response) {
          {"errorCode" => "YOU_ARE_A_BANANA", "message" => "Bananas are not allowed to bank."}
        }

        it 'raises a DocusignError with the returned message if not successful' do
          stub_envelope_creation('send_envelope', 'failed_creation', 500)
          expect {
            subject.send!
          }.to raise_error(Hancock::Request::RequestError, "500 - #{response}")
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
            'statusChangedDateTime' => '2014-06-04T23:55:36.7870000Z',
            'emailSubject' => 'Subjacked',
            'emailBlurb' => 'Blurble'
          }))
        # FIXME: This downloads all the documents, we must find a better way
        # allow(Hancock::Document).to receive(:fetch_all_for_envelope).
        #   with(subject).
        #   and_return(:le_documeneaux)
        allow(Hancock::Recipient).to receive(:fetch_for_envelope).
          with(subject.identifier).
          and_return(:le_recipierre)

        expect(subject.reload!).to eq subject
        expect(subject.status).to eq 'bullfree'
        expect(subject.status_changed_at).to eq(Time.parse('2014-06-04T23:55:36.7870000Z'))
        expect(subject.email).to eq({:subject => 'Subjacked', :blurb => 'Blurble'})
        # expect(subject.documents).to eq :le_documeneaux
        expect(subject.recipients).to eq :le_recipierre
      end

      it 'is safe to call even if no identifier' do
        subject.identifier = nil
        expect {
          subject.reload!
        }.not_to raise_error
      end
    end

    describe '#summary_documents' do
      it 'returns summary documents for envelope' do
        allow(Hancock::Document).to receive(:fetch_all_for_envelope).with(
          subject, :types => ['summary']
        ).and_return(:the_documents)
        expect(subject.summary_documents).to eq :the_documents
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
        recipient = instance_double(Hancock::Recipient, :recipient_type => :signer)
        attributes = {
          :recipient => recipient,
          :document => :a_document,
          :tabs => [:tab1, :tab2]
        }

        subject.add_signature_request(attributes)

        expect(subject.signature_requests).to eq [attributes]
        expect(subject.recipients).to eq [recipient]
      end

      it 'adds regular carbon_copy recipients to the list of signature requests' do
        recipient = instance_double(Hancock::Recipient,
          :recipient_type => :carbon_copy,
          :client_user_id => nil)
        attributes = {
          :recipient => recipient,
          :document => :a_document
        }

        subject.add_signature_request(attributes)

        expect(subject.signature_requests).to eq [attributes.merge({:tabs => nil})]
        expect(subject.recipients).to eq [recipient]
        expect(subject.signature_requests.first[:tabs]).to eq(nil)
      end

      it 'does not add embedded carbon_copy recipients to the list of signature requests' do
        recipient = instance_double(Hancock::Recipient,
          :recipient_type => :carbon_copy,
          :client_user_id => 123)
        attributes = {
          :recipient => recipient,
          :document => :a_document
        }

        subject.add_signature_request(attributes)

        expect(subject.signature_requests).to eq []
        expect(subject.recipients).to eq [recipient]
      end
    end

    describe '#new' do
      it "can set params on initialization" do
        recipient = instance_double(Hancock::Recipient, :recipient_type => :signer)
        envelope = Hancock::Envelope.new({
          documents: [:document],
          signature_requests: [{
            :recipient => recipient,
            :document => :document,
            :tabs => [:tabs]}],
          email: {
            subject: 'Hello there',
            blurb: 'Please sign this!'
          }
        })

        expect(envelope.documents).to eq [:document]
        expect(envelope.recipients).to eq [recipient]
        expect(envelope.email).to eq({
          subject: 'Hello there',
          blurb: 'Please sign this!'
        })
      end
    end

    describe '#current_routing_order' do
      subject { described_class.new(:identifier => 'smokey-joe') }

      it 'uses DocusignRecipient because that\'s what the API requires :(' do
        stub_request(:get, 'https://demo.docusign.net/restapi/v2/accounts/123456/envelopes/smokey-joe/recipients').
          to_return(
            :status => 200,
            :body => '{"currentRoutingOrder":"7","other":"stuff"}',
            :headers => {'Content-Type' => 'application/json'}
          )

        expect(subject.current_routing_order).to eq(7)
      end
    end

    describe '#signature_requests_for_params' do
      let(:document1) { Hancock::Document.new(:identifier => 1) }
      let(:document2) { Hancock::Document.new(:identifier => 2) }
      let(:recipient1) { Hancock::Recipient.new(:email => 'b@mail.com', :name => 'Bob', :recipient_type => :signer, :identifier => 1) }
      let(:recipient2) { Hancock::Recipient.new(:email => 'e@mail.com', :name => 'Edna', :recipient_type => :signer, :identifier => 2, :id_check => false) }
      let(:tab1) { double(Hancock::Tab, :type => 'initial_here', :to_h => { :initial => :here }) }
      let(:tab2) { double(Hancock::Tab, :type => 'sign_here', :to_h => { :sign => :here }) }

      it 'returns signature requests grouped by recipient and set up for submission' do
        subject = described_class.new({
          :signature_requests => [
            { :recipient => recipient1, :document => document1, :tabs => [tab1] },
            { :recipient => recipient1, :document => document2, :tabs => [tab1, tab2] },
            { :recipient => recipient2, :document => document1, :tabs => [tab2] },
            { :recipient => recipient2, :document => document2, :tabs => [tab1] }
          ]
        })
        expect(subject.send(:signature_requests_for_params)).to match({
          'signers' => [
            {
              :clientUserId => nil,
              :email => 'b@mail.com',
              :name => 'Bob',
              :recipientId => 1,
              :routingOrder => 1,
              :requireIdLookup => true,
              :idCheckConfigurationName => 'ID Check $',
              :embeddedRecipientStartURL => 'SIGN_AT_DOCUSIGN',
              :tabs => {
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
              :clientUserId => nil,
              :email => 'e@mail.com',
              :name => 'Edna',
              :recipientId => 2,
              :routingOrder => 1,
              :requireIdLookup => false,
              :idCheckConfigurationName => nil,
              :embeddedRecipientStartURL => 'SIGN_AT_DOCUSIGN',
              :tabs => {
                :initialHereTabs => [
                  { :initial => :here, :documentId => 2 },
                ],
                :signHereTabs => [
                  { :sign => :here, :documentId => 1 },
                ]
              }
            }
          ]
        })
      end

      context 'when not requiring an ID Check' do
        subject {
          described_class.new({
            :signature_requests => [{ :recipient => recipient2, :document => document1, :tabs => [] }]
          })
        }

        it 'sets requireIdLookup to false' do
          expect(subject.send(:signature_requests_for_params)['signers']
            .first[:requireIdLookup]).to be(false)
        end

        it 'does not include idCheckConfigurationName' do
          expect(subject.send(:signature_requests_for_params)['signers']
            .first[:idCheckConfigurationName]).to be_nil
        end
      end
    end

    describe '#notification_for_params' do
      it 'returns reminder and expiration formatted for post' do
        subject = described_class.new({
          :reminder => { :delay => 5, :frequency => 8 },
          :expiration => { :after => 3, :warn => 2 }
        })
        expect(subject.notification_for_params).to eq({
          useAccountDefaults: false,
          reminders: {
            reminderEnabled: true,
            reminderDelay: 5,
            reminderFrequency: 8
          },
          expirations: {
            expireEnabled: true,
            expireAfter: 3,
            expireWarn: 2
          },
        })
      end

      it 'returns skeleton when no reminder or expiration' do
        expect(subject.notification_for_params).to eq({
          useAccountDefaults: false,
          reminders: {
            reminderEnabled: false,
          },
          expirations: {
            expireEnabled: false,
          },
        })
      end
    end

    describe '#form_post_body' do
      it 'assembles body for posting' do
        allow(subject).to receive(:email).and_return({ :subject => 'fubject', :blurb => 'flurb'})
        allow(subject).to receive(:status).and_return('foo')
        doc1 = double(Hancock::Document, :multipart_form_part => 'Oh my', :to_request => 'horse')
        doc2 = double(Hancock::Document, :multipart_form_part => 'How wondrous', :to_request => 'pony')
        subject.documents = [doc1, doc2]
        allow(subject).to receive(:signature_requests_for_params).
          and_return('the signature requests')
        allow(subject).to receive(:notification_for_params).
          and_return('the_notification')
        expect(subject.send(:form_post_body)).to eq(
          "\r\n"\
          "--MYBOUNDARY\r\nContent-Type: application/json\r\n"\
          "Content-Disposition: form-data\r\n\r\n"\
          "{\"emailBlurb\":\"flurb\",\"emailSubject\":\"fubject\","\
          "\"status\":\"foo\",\"documents\":[\"horse\",\"pony\"],"\
          "\"recipients\":\"the signature requests\","\
          "\"notification\":\"the_notification\"}\r\n"\
          "--MYBOUNDARY\r\nOh my\r\n"\
          "--MYBOUNDARY\r\nHow wondrous\r\n"\
          "--MYBOUNDARY--\r\n"
        )
      end
    end
  end

  describe '#viewing_url' do
    subject { described_class.new(:identifier => '1234') }

    it 'returns a url' do
      parsed_body = { 'url' => 'https://demo.docusign.net/linky-linky' }

      allow_any_instance_of(Hancock::Envelope::DocusignEnvelope)
        .to receive(:viewing_url)
        .and_return(double(:parsed_response => parsed_body))

      expect(subject.viewing_url).to eq('https://demo.docusign.net/linky-linky')
    end
  end

  describe "#in_terminal_state?" do
    subject { described_class.new(status: status) }

    before :each do
      stub_const("#{described_class}::TERMINAL_STATUSES", ["banana"])
    end

    context "envelope in non-terminal state" do
      let(:status) { "sent" }

      it "returns true if status is in list" do
        expect(subject.in_terminal_state?).to be_falsey
      end
    end

    context "envelope in terminal state" do
      let(:status) { "banana" }

      it "returns false if status is not in list" do
        expect(subject.in_terminal_state?).to be_truthy
      end
    end
  end


  describe "#in_editable_state?" do
    subject { described_class.new(status: status) }

    before :each do
      stub_const("#{described_class}::EDITABLE_STATUSES", ["banana"])
    end

    context "envelope in editable state" do
      let(:status) { "banana" }

      it "returns true if status is in list" do
        expect(subject.in_editable_state?).to be_truthy
      end
    end

    context "envelope in non-editable state" do
      let(:status) { "voided" }

      it "returns false if status is not in list" do
        expect(subject.in_editable_state?).to be_falsey
      end
    end
  end
end
