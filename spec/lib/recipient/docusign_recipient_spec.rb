describe Hancock::Recipient::DocusignRecipient do
  let(:recipient) {
    Hancock::Recipient.new(
      :envelope_identifier => 'fiji',
      :identifier => 'snorkel-puffer')
  }
  subject { described_class.new(recipient) }

  describe '.all_for' do
    it 'makes a request' do
      expect(Hancock::Request).to receive(:send_get_request)
        .with('/envelopes/yosemite-sam/recipients')

      described_class.all_for('yosemite-sam')
    end
  end

  describe '.find' do
    it 'makes a request' do
      expect(Hancock::Request).to receive(:send_get_request)
        .with('/envelopes/yosemite-sam/recipients/bugs-bunny')

      described_class.find('yosemite-sam', 'bugs-bunny')
    end
  end

  describe '#tabs' do
    it 'makes a request' do
      expect(Hancock::Request).to receive(:send_get_request)
        .with('/envelopes/fiji/recipients/snorkel-puffer/tabs')

      subject.tabs
    end
  end

  describe '#create_tabs_from_json' do
    it 'makes a request' do
      json = '{ "some": "thingy" }'

      expect(Hancock::Request).to receive(:send_post_request)
        .with('/envelopes/fiji/recipients/snorkel-puffer/tabs', json)

      subject.create_tabs_from_json(json)
    end
  end

  describe '#delete' do
    it 'makes a request' do
      json = { :signers => [{ :recipientId => 'snorkel-puffer' }] }.to_json

      expect(Hancock::Request).to receive(:send_delete_request)
        .with('/envelopes/fiji/recipients', json)

      subject.delete
    end
  end

  describe '#create' do
    let(:recipient) {
      Hancock::Recipient.new(
        :client_user_id => '1',
        :email => 'jimmy@example.com',
        :name => 'Jimmy Stewart',
        :recipient_type => 'signer',
        :identifier => '42',
        :id_check => true,
        :envelope_identifier => 'barbra-streisand'
      )
    }

    it 'makes a request' do
      json = {
        :signers => [
          {
            :clientUserId => '1',
            :email => 'jimmy@example.com',
            :idCheck => true,
            :name => 'Jimmy Stewart',
            :recipientId => '42',
            :routingOrder => 1
          }
        ]
      }.to_json

      expect(Hancock::Request).to receive(:send_post_request)
        .with('/envelopes/barbra-streisand/recipients', json)

      subject.create
    end
  end
end

