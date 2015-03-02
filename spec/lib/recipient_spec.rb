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

    it 'is set as a symbol' do
      subject = described_class.new(:recipient_type => 'spinner')
      expect(subject.recipient_type).to eq :spinner
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

  describe '#embedded_start_url' do
    it 'defaults to the "SIGN_AT_DOCUSIGN" magic value' do
      subject = described_class.new()
      expect(subject.embedded_start_url).to eq 'SIGN_AT_DOCUSIGN'
    end

    it 'can be set' do
      subject = described_class.new(:embedded_start_url => 'sign-now.example.com')
      expect(subject.embedded_start_url).to eq 'sign-now.example.com'
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

  describe '#resend_email' do
    subject {
      described_class.new(
        :envelope_identifier => 'yuppie-kittens',
        :identifier => 'hey-now'
      )
    }

    it 'recreates the recipient' do
      recreator = double(Hancock::Recipient::Recreator)

      allow(Hancock::Recipient::Recreator).to receive(:new)
        .and_return(recreator)
      expect(recreator).to receive(:recreate_with_tabs)

      subject.resend_email
    end
  end

  describe '#change_access_method_to' do
    let(:recreator) { double(Hancock::Recipient::Recreator) }

    subject {
      described_class.new(
        :envelope_identifier => 'bluh',
        :client_user_id => 'uniquity',
        :identifier => 42)
    }

    before(:each) do
      allow(Hancock::Recipient::Recreator).to receive(:new).and_return(recreator)
    end

    context 'when new access method is the same as the old' do
      it 'returns true' do
        expect(subject.change_access_method_to(:embedded)).to eq(true)
      end

      it 'does not attempt to delete and recreate the recipient' do
        expect(a_request(:any, /.*docusign.net.*/)).not_to have_been_made

        subject.change_access_method_to(:embedded)
      end
    end

    context 'when setting access method to :embedded' do
      subject {
        described_class.new(
          :envelope_identifier => 'bluh',
          :identifier => 42)
      }

      it 'sets the client_user_id to the identifier' do
        allow(recreator).to receive(:recreate_with_tabs)

        expect(subject.client_user_id).to be nil
        subject.change_access_method_to(:embedded)
        expect(subject.client_user_id).to eq(42)
      end

      it 'recreates the recipient' do
        expect(recreator).to receive(:recreate_with_tabs)
        subject.change_access_method_to(:embedded)
      end
    end

    context 'when setting access method to :remote' do
      it 'sets the client_user_id to nil' do
        allow(recreator).to receive(:recreate_with_tabs)

        expect(subject.client_user_id).to eq('uniquity')
        subject.change_access_method_to(:remote)
        expect(subject.client_user_id).to be(nil)
      end

      it 'recreates the recipient' do
        expect(recreator).to receive(:recreate_with_tabs)
        subject.change_access_method_to(:remote)
      end
    end

    context 'when setting access method to :something_unknown_and_silly' do
      subject {
        described_class.new(
          :envelope_identifier => 'bluh',
          :identifier => 42)
      }

      it 'raises an exception' do
        expect {
          subject.change_access_method_to(:something_unknown_and_silly)
        }.to raise_error ArgumentError
      end
    end
  end

  describe '#signing_url' do
    before(:each) do
      allow(subject).to receive(:access_method).and_return(:embedded)
    end

    subject {
      described_class.new(
        :envelope_identifier => 'bluh',
        :identifier => 'squirrel')
    }

    it 'returns a url' do
      parsed_body = { 'url' => 'https://demo.docusign.net/linky-linky' }

      allow_any_instance_of(Hancock::Recipient::DocusignRecipient)
        .to receive(:signing_url)
        .and_return(double(:parsed_response => parsed_body))

      expect(subject.signing_url('redirect-us-here-afters-please'))
        .to eq('https://demo.docusign.net/linky-linky')
    end

    it 'allows an optional return url' do
      parsed_body = { 'url' => 'https://demo.docusign.net/another-linky' }

      expect_any_instance_of(Hancock::Recipient::DocusignRecipient)
        .to receive(:signing_url)
        .with('http://example.com/fish-tacos')
        .and_return(double(:parsed_response => parsed_body))

      expect(subject.signing_url('http://example.com/fish-tacos'))
        .to eq('https://demo.docusign.net/another-linky')
    end

    it 'fails if the access_method is remote' do
      allow(subject).to receive(:access_method).and_return(:remote)

      expect { subject.signing_url('return-me-here-yo') }.to raise_error(
        Hancock::Recipient::SigningUrlError,
        'This recipient is not setup for in-person signing'
      )
    end
  end
end
