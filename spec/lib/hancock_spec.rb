describe Hancock do
  describe "#configured?" do
    before(:each) do
      described_class.oauth_token = 'valid_token'
      described_class.account_id = 'valid_account'
    end

    it 'returns false if no oauth token' do
      described_class.oauth_token = nil
      expect(described_class.configured?).to be_falsey
    end

    it 'returns false if no account id' do
      described_class.account_id = nil
      expect(described_class.configured?).to be_falsey
    end

    it 'returns true if account id and oauth_token' do
      expect(described_class.configured?).to be_truthy
    end
  end
end