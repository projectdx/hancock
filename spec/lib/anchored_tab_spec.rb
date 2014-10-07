describe Hancock::AnchoredTab do
  context 'validations' do
    let(:valid_strings) { ['something', :a_symbol] }

    it { is_expected.to have_valid(:type).when(*valid_strings) }
    it { is_expected.not_to have_valid(:type).when(nil, '') }

    it { is_expected.to have_valid(:coordinates).when([1,2]) }
    it { is_expected.not_to have_valid(:coordinates).when([]) }

    it { is_expected.to have_valid(:label).when(*valid_strings) }
    it { is_expected.not_to have_valid(:label).when(nil, '') }

    it { is_expected.to have_valid(:page_number).when(3) }
    it { is_expected.not_to have_valid(:page_number).when(-3, 2.5, 'three', nil, '') }
  end

  describe '.new' do
    it 'sets anchorXOffset and anchorYOffset to 0 by default' do
      expect(subject.to_h[:anchorXOffset]).to eq(0)
      expect(subject.to_h[:anchorYOffset]).to eq(0)
    end
  end

  describe "#page_number" do
    it 'defaults to 1' do
      expect(subject.page_number).to eq 1
    end

    it 'can be set via params' do
      subject = described_class.new(page_number: 3)
      expect(subject.page_number).to eq 3
    end
  end

  describe "#anchor_text" do
    it 'defaults to label' do
      allow(subject).to receive(:label).and_return('ghosts')
      expect(subject.anchor_text).to eq 'ghosts'
    end

    it 'can be set via params' do
      subject = described_class.new(anchor_text: 'smurf bees')
      expect(subject.anchor_text).to eq 'smurf bees'
    end
  end

  describe "#to_h" do
    it "generates hash suitable for DocuSign submission" do
      allow(subject).to receive(:page_number).and_return(5)
      allow(subject).to receive(:coordinates).and_return([45,251])
      allow(subject).to receive(:anchor_text).and_return('smarmy vikings')
      expect(subject.to_h).to eq({
        :anchorString => 'smarmy vikings',
        :anchorXOffset      => 45,
        :anchorYOffset      => 251,
        :anchorIgnoreIfNotPresent => true,
        :pageNumber         => 5
      })
    end
  end
end
