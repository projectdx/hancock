describe Hancock::Document do
  include_context "configs"
  include_context "variables"

  context 'validations' do
    let(:file) { File.open("#{SPEC_ROOT}/fixtures/test.pdf") }

    it { should have_valid(:file).when(file) }
    it { should_not have_valid(:file).when('not a file', nil) }

    it { should have_valid(:data).when('squishy bits') }
    it { should_not have_valid(:data).when(nil, file) }

    it { should have_valid(:name).when('squishy bits') }
    it { should_not have_valid(:name).when(nil, '') }

    it { should have_valid(:extension).when('.foo') }
    it { should_not have_valid(:extension).when(nil, '') }

    it { should have_valid(:data).when('squishy bits') }
    it { should_not have_valid(:data).when(nil) }

    context 'when file is present' do
      before { subject.file = file }
      it { should have_valid(:data).when(nil) }
      it { should_not have_valid(:data).when('squishy bits') }
    end

    context 'when data is present' do
      before { subject.data = 'squishy bits' }
      it { should have_valid(:file).when(nil) }
      it { should_not have_valid(:file).when(file) }
    end
  end

  context 'with a file' do
    subject { described_class.new(:file => file) }
    describe '#name' do
      it 'returns name of file' do
        subject.name.should eq 'test.pdf'
      end

      it 'can be overridden' do
        subject.name = 'moofits.pdf'
        subject.name.should eq 'moofits.pdf'
      end
    end

    describe '#extension' do
      it 'returns extension extracted from filename' do 
        subject.extension.should eq 'pdf'
      end

      it 'can be overridden' do
        subject.extension = 'wild_fans_of_mogwai_county'
        subject.extension.should eq 'wild_fans_of_mogwai_county'
      end
    end
  end

  describe '.reload!' do
    it 'reloads documents from DocuSign envelope' do
      envelope.add_document(document)
      envelope.add_signature_request({ recipient: recipient, document: document, tabs: [tab] })
      envelope.save

      expect(described_class.reload!(envelope).map { |d| [d.name, d.extension, d.identifier.to_s] }).
        to match_array([[document.name, document.extension, document.identifier.to_s]])
    end
  end
end