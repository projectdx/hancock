describe Hancock::Tab do
  describe "#page_number" do
    it 'defaults to 1' do
      subject.page_number.should eq 1
    end

    it 'can be set via params' do
      subject = described_class.new(page_number: 3)
      subject.page_number.should eq 3
    end
  end

  describe "#to_h" do
    it "generates hash suitable for DocuSign submission" do
      allow(subject).to receive(:page_number).and_return(5)
      allow(subject).to receive(:coordinates).and_return([45,251])
      allow(subject).to receive(:label).and_return('smarmy vikings')
      subject.to_h.should eq({
        :tabLabel       => 'smarmy vikings',
        :xPosition      => 45,
        :yPosition      => 251,
        :pageNumber     => 5
      })
    end
  end

  context 'validations' do
    let(:valid_strings) { ['something', :a_symbol] }

    it { should have_valid(:type).when(*valid_strings) }
    it { should_not have_valid(:type).when(nil, '') }

    it { should have_valid(:coordinates).when([1,2]) }
    it { should_not have_valid(:coordinates).when(6, :not_an_array) }

    it { should have_valid(:label).when(*valid_strings) }
    it { should_not have_valid(:label).when(nil, '') }

    it { should have_valid(:page_number).when(3) }
    it { should_not have_valid(:page_number).when(nil, 'three') }
  end
end