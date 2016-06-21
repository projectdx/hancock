describe Hancock::AnchoredTab do
  context 'validations' do
    it { is_expected.to have_valid(:type).when(['something', :a_symbol]) }
    it { is_expected.not_to have_valid(:type).when(nil, '') }

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

  describe '#to_h' do
    it 'generates hash suitable for DocuSign submission' do
      subject = described_class.new(
        :page_number => 5,
        :coordinates => [45,251],
        :anchor_text => 'smarmy vikings',
        :validation_message => 'foodbart',
        :validation_pattern => 'Dr. Suess',
        :width => 27,
        :font_size => 48,
        :optional => true,
        :label => 'label maker'
      )

      expect(subject.to_h).to eq({
        :anchorString => 'smarmy vikings',
        :anchorXOffset      => 45,
        :anchorYOffset      => 251,
        :anchorIgnoreIfNotPresent => true,
        :pageNumber         => 5,
        :validationPattern => 'Dr. Suess',
        :validationMessage => 'foodbart',
        :width => 27,
        :fontSize => 'Size48',
        :optional => "true",
        :tabLabel => 'label maker'
      })
    end

    it 'does not include nil values' do
      subject = described_class.new(
        :page_number => 5,
        :coordinates => [45,251],
        :anchor_text => 'smarmy vikings',
        :optional => nil
      )

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
