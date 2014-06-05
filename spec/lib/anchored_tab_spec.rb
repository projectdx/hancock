describe Hancock::AnchoredTab do
  let(:params) { { type: 'type', offset: [1,2], label: 'label' } }
  subject { described_class.new(params) }

  describe "#page_number" do
    it 'defaults to 1' do
      subject.page_number.should eq 1
    end

    it 'can be set via params' do
      params.merge!(page_number: 3)
      subject.page_number.should eq 3
    end
  end

  describe "#anchor_text" do
    it 'defaults to label' do
      allow(subject).to receive(:label).and_return('ghosts')
      subject.anchor_text.should eq 'ghosts'
    end

    it 'can be set via params' do
      params.merge!(anchor_text: 'smurf bees')
      subject.anchor_text.should eq 'smurf bees'
    end
  end

  describe "#to_h" do
    it "generates hash suitable for DocuSign submission" do
      allow(subject).to receive(:page_number).and_return(5)
      allow(subject).to receive(:offset).and_return([45,251])
      allow(subject).to receive(:anchor_text).and_return('smarmy vikings')
      subject.to_h.should eq({
        :anchorString => 'smarmy vikings',
        :anchorXOffset      => 45,
        :anchorYOffset      => 251,
        :IgnoreIfNotPresent => 1,
        :pageNumber         => 5
      })
    end
  end
end