describe Hancock::Tab do
  context 'validations' do
    it { is_expected.to have_valid(:type).when('something', :a_symbol) }
    it { is_expected.not_to have_valid(:type).when(nil, '') }

    it { is_expected.to have_valid(:coordinates).when([1,2]) }
    it { is_expected.not_to have_valid(:coordinates).when([]) }

    it { is_expected.to have_valid(:label).when('something', :a_symbol) }
    it { is_expected.not_to have_valid(:label).when(nil, '') }

    it { is_expected.to have_valid(:page_number).when(3) }
    it { is_expected.not_to have_valid(:page_number).when(-3, 2.5, 'three', nil, '') }
  end

  describe '.new' do
    it 'sets xPosition and yPosition to 0 by default' do
      expect(subject.to_h[:xPosition]).to eq(0)
      expect(subject.to_h[:yPosition]).to eq(0)
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

  describe '#coordinates=' do
    it 'raises ArgumentError if not given an Array' do
      expect{subject.coordinates = nil}.to raise_error ArgumentError
      expect{subject.coordinates = Object.new}.to raise_error ArgumentError
    end
  end

  describe "#to_h" do
    it "generates hash suitable for DocuSign submission" do
      allow(subject).to receive(:page_number).and_return(5)
      allow(subject).to receive(:coordinates).and_return([45,251])
      allow(subject).to receive(:label).and_return('smarmy vikings')
      expect(subject.to_h).to eq({
        :tabLabel       => 'smarmy vikings',
        :xPosition      => 45,
        :yPosition      => 251,
        :pageNumber     => 5
      })
    end
  end
end
