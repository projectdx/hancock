describe Hancock::Recipient do
  context 'validations' do
    it { is_expected.to have_valid(:delivery_method).when(:email, :embedded, :offline, :paper) }
    it { is_expected.not_to have_valid(:delivery_method).when(:goofy, nil, '') }

    it { is_expected.to have_valid(:name).when('Soup Can Sam') }
    it { is_expected.not_to have_valid(:name).when(nil, '') }

    it { is_expected.to have_valid(:email).when('nerf@email.com', 'ooh+a+spider@what.is.an.email') }
    it { is_expected.not_to have_valid(:email).when('dan@localhost', 'noobody', nil, '') }

    it { is_expected.to have_valid(:id_check).when(true, false, nil) }
    it { is_expected.not_to have_valid(:id_check).when('oh my yes', :true, '') }

    it { is_expected.to have_valid(:recipient_type).when(*described_class::Types) }
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

    it 'can be set' do
      subject.id_check = false
      expect(subject.id_check).to be_falsey
    end
  end

  describe '#delivery_method' do
    it 'returns :email by default' do
      expect(subject.delivery_method).to eq :email
    end

    it 'can be set' do
      subject.delivery_method = :aerokraft
      expect(subject.delivery_method).to eq :aerokraft
    end
  end

  describe '.fetch_for_envelope' do
    it 'reloads recipients from DocuSign envelope' do
      envelope = Hancock::Envelope.new(:identifier => 'a-crazy-envelope-id')
      allow(Hancock::DocuSignAdapter).to receive(:new).
        with('a-crazy-envelope-id').
        and_return(double(Hancock::DocuSignAdapter, :recipients => JSON.parse(response_body('recipients'))))

      recipients = described_class.fetch_for_envelope(envelope)
      expect(recipients.map(&:email)).
        to match_array(['darwin@example.com', 'salli@example.com'])
      expect(recipients.map(&:class).uniq).to eq [described_class]
    end
  end
end