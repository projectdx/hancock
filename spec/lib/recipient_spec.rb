describe Hancock::Recipient do
  before do
    allow(Hancock).to receive(:account_id).and_return(123_456)
  end

  context 'validations' do
    it { is_expected.to have_valid(:name).when('Soup Can Sam') }
    it { is_expected.not_to have_valid(:name).when(nil, '') }

    it { is_expected.to have_valid(:email).when('nerf@email.com', 'ooh+a+spider@what.is.an.email') }
    it { is_expected.not_to have_valid(:email).when('dan@localhost', 'noobody', nil, '') }

    it { is_expected.to have_valid(:id_check).when(true, false, nil) }
    it { is_expected.not_to have_valid(:id_check).when('oh my yes', :true, '') }

    it { is_expected.to have_valid(:recipient_type).when(*described_class::TYPES) }
    it { is_expected.not_to have_valid(:recipient_type).when(:puppy, nil, '') }
  end

  describe "#routing_order" do
    it 'defaults to 1' do
      expect(subject.routing_order).to eq 1
    end

    it 'can be set' do
      subject.routing_order = 3
      expect(subject.routing_order).to eq 3
    end
  end

  describe '#identifier' do
    it 'returns nil by default' do
      expect(subject.identifier).to be_nil
    end

    it 'can be set' do
      subject = described_class.new(:identifier => 'smithy mcsmitherson')
      expect(subject.identifier).to eq 'smithy mcsmitherson'
    end
  end

  describe '#recipient_type' do
    it 'returns :signer by default' do
      expect(subject.recipient_type).to eq :signer
    end

    it 'can be set' do
      subject.recipient_type = :swooner
      expect(subject.recipient_type).to eq :swooner
    end
  end

  describe '#id_check' do
    it 'returns true by default' do
      expect(subject.id_check).to be_truthy
    end

    it 'can be set to false' do
      subject = described_class.new(:id_check => false)
      expect(subject.id_check).to be_falsey
    end
  end

  describe '.fetch_for_envelope' do
    it 'reloads recipients from DocuSign envelope' do
      envelope = Hancock::Envelope.new(:identifier => 'a-crazy-envelope-id')
      stub_request(:get, 'https://demo.docusign.net/restapi/v2/accounts/123456/envelopes/a-crazy-envelope-id/recipients').
        to_return(:status => 200, :body => response_body('recipients'), :headers => {'Content-Type' => 'application/json'})

      recipients = described_class.fetch_for_envelope(envelope.identifier)
      expect(recipients.map(&:email)).
        to match_array(['darwin@example.com', 'salli@example.com'])
      expect(recipients.map(&:identifier)).
        to match_array([12, 50])
      expect(recipients.map(&:class).uniq).to eq [described_class]
    end
  end

  describe '.find_or_initialize' do
    context 'when a matching envelope exists' do
      let(:kermie) { double() }

      it 'returns a recipient if one was found' do
        allow(Hancock::Recipient::DocusignRecipient).to receive(:find)
          .and_return(kermie)

        expect(
          described_class.find_or_initialize('envelope_identifier', :identifier => 'kerms')
        ).to eq(kermie)
      end

      it 'creates a new recipient if no match was found' do
        allow(Hancock::Recipient::DocusignRecipient).to receive(:find)
          .and_return(nil)

        new_recipient = described_class.find_or_initialize('1234', :name => 'MacGyver')
        expect(new_recipient.name).to eq('MacGyver')
        expect(new_recipient.instance_variable_get :@envelope_identifier).to eq('1234')
      end
    end
  end

  describe '#change_access_method_to' do
    context 'when new access method is the same as the old' do
      subject {
        described_class.new(
          :envelope_identifier => 'bluh',
          :client_user_id => 'uniquity',
          :identifier => 42)
      }

      it 'returns true' do
        expect(subject.change_access_method_to(:embedded)).to eq(true)
      end

      it 'does not attempt to delete and recreate the recipient' do
        expect_any_instance_of(Hancock::Recipient::DocusignRecipient)
          .not_to receive(:delete)
        expect_any_instance_of(Hancock::Recipient::DocusignRecipient)
          .not_to receive(:create)
        expect_any_instance_of(Hancock::Recipient::DocusignRecipient)
          .not_to receive(:tabs)
        expect_any_instance_of(Hancock::Recipient::DocusignRecipient)
          .not_to receive(:create_tabs_from_json)

        subject.change_access_method_to(:embedded)
      end
    end

    context 'when setting access method to :embedded' do
      subject {
        described_class.new(
          :envelope_identifier => 'bluh',
          :identifier => 42)
      }

      before(:each) do
        expect_any_instance_of(Hancock::Recipient::DocusignRecipient)
          .to receive(:delete)
          .and_return(double(:success? => true))
        expect_any_instance_of(Hancock::Recipient::DocusignRecipient)
          .to receive(:create)
          .and_return(double(:success? => true))
        expect_any_instance_of(Hancock::Recipient::DocusignRecipient)
          .to receive(:tabs)
          .and_return(double(:success? => true))
        expect_any_instance_of(Hancock::Recipient::DocusignRecipient)
          .to receive(:create_tabs_from_json)
          .and_return(double(:success? => true))
      end

      it 'sets the client_user_id to the identifier' do
        expect(subject.client_user_id).to be nil

        subject.change_access_method_to(:embedded)

        expect(subject.client_user_id).to eq(subject.identifier)
      end
    end

    context 'when setting access method to :remote' do
      subject {
        described_class.new(
          :envelope_identifier => 'bluh',
          :client_user_id => 'susketchuwon',
          :identifier => 42)
      }

      before(:each) do
        expect_any_instance_of(Hancock::Recipient::DocusignRecipient)
          .to receive(:delete)
          .and_return(double(:success? => true))
        expect_any_instance_of(Hancock::Recipient::DocusignRecipient)
          .to receive(:create)
          .and_return(double(:success? => true))
        expect_any_instance_of(Hancock::Recipient::DocusignRecipient)
          .to receive(:tabs)
          .and_return(double(:success? => true))
        expect_any_instance_of(Hancock::Recipient::DocusignRecipient)
          .to receive(:create_tabs_from_json)
          .and_return(double(:success? => true))
      end

      it 'sets the client_user_id to the nil' do
        expect(subject.client_user_id).to eq('susketchuwon')

        subject.change_access_method_to(:remote)

        expect(subject.client_user_id).to be(nil)
      end
    end

    context 'when setting access method to :something_unknown_and_silly' do
      subject {
        described_class.new(
          :envelope_identifier => 'bluh',
          :identifier => 42)
      }

      it 'sets the client_user_id to the nil' do
        expect {
          subject.change_access_method_to(:something_unknown_and_silly)
        }.to raise_error ArgumentError
      end
    end

    context 'when, for once, things go accordingly to plans laid best by mice and men' do
      subject {
        described_class.new(
          :envelope_identifier => 'bluh',
          :identifier => 'squirrel')
      }

      it 'returns true' do
        expect_any_instance_of(Hancock::Recipient::DocusignRecipient)
          .to receive(:delete)
          .and_return(double(:success? => true))
        expect_any_instance_of(Hancock::Recipient::DocusignRecipient)
          .to receive(:create)
          .and_return(double(:success? => true))
        expect_any_instance_of(Hancock::Recipient::DocusignRecipient)
          .to receive(:tabs)
          .and_return(double(:success? => true))
        expect_any_instance_of(Hancock::Recipient::DocusignRecipient)
          .to receive(:create_tabs_from_json)
          .and_return(double(:success? => true))

        expect(subject.change_access_method_to(:embedded)).to be true
      end
    end
  end
end
