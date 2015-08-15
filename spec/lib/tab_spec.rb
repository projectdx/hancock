describe Hancock::Tab do
  context 'validations' do
    it { is_expected.to have_valid(:type).when('something', :a_symbol) }
    it { is_expected.not_to have_valid(:type).when(nil, '') }

    it { is_expected.to have_valid(:page_number).when(3) }
    it { is_expected.not_to have_valid(:page_number).when(-3, 2.5, 'three', nil, '') }
  end

  describe 'font_size' do
    let(:available_sizes) {
      [7, 8, 9, 10, 11, 12, 14, 16, 18, 20, 22, 24, 26, 28, 36, 48, 72]
    }
    let(:unavailable_sizes) {
      [0, 1, 25, 99]
    }

    it 'accepts font sizes from the list' do
      available_sizes.each do |size|
        expect{ described_class.new(:font_size => size) }.to_not raise_error
      end
    end

    it 'does not raise an exception if no font size is passed in' do
      expect{ described_class.new() }.to_not raise_error
    end

    it 'raises an exception when the font_size is not supported' do
      possibilities = "7, 8, 9, 10, 11, 12, 14, 16, 18, 20, 22, 24, 26, 28, 36, 48, 72"

      unavailable_sizes.each do |size|
        message = "Font size #{size} is not supported. Please choose from: " + possibilities
        expect{ described_class.new(:font_size => size) }.to raise_error(ArgumentError, message)
      end
    end
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
      subject = described_class.new(
        :page_number        => 5,
        :coordinates        => [45,251],
        :label              => 'smarmy vikings',
        :validation_pattern => 'dr. suess',
        :validation_message => 'foodbart',
        :width              => 10,
        :font_size          => 26
      )

      expect(subject.to_h).to eq({
        :tabLabel          => 'smarmy vikings',
        :xPosition         => 45,
        :yPosition         => 251,
        :pageNumber        => 5,
        :validationPattern => 'dr. suess',
        :validationMessage => 'foodbart',
        :width             => 10,
        :fontSize          => 'Size26'
      })
    end

    it "does not include nil values" do
      subject = described_class.new(
        :page_number => 5,
        :coordinates => [45,251],
        :label       => 'smarmy vikings'
      )

      expect(subject.to_h).to eq({
        :tabLabel       => 'smarmy vikings',
        :xPosition      => 45,
        :yPosition      => 251,
        :pageNumber     => 5
      })
    end
  end
end
