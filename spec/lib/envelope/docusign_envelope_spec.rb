describe Hancock::Envelope::DocusignEnvelope do
  let(:envelope) {
    Hancock::Envelope.new(:identifier => 'maui')
  }
  subject { described_class.new(envelope) }

  describe '.new' do
    it 'requires an envelope identifier' do
      expect{ described_class.new(double(Hancock::Envelope, :identifier => nil)) }
        .to raise_error('envelope requires an identifier')
    end
  end

  describe '#viewing_url' do
    it 'makes a request to Docusign' do
      expect(Hancock::Request).to receive(:send_post_request)
        .with('/envelopes/maui/views/sender')

      subject.viewing_url
    end
  end

  describe '#send_envelope' do
    xit 'sets the status of each signer to "sent"' do
      # PUT v2/accounts/:accountId/envelopes/:envelopeId
      # { "status": "sent" }
    end
  end
end
