describe Hancock::Document do
  let(:file) { File.open(fixture_path('test.pdf')) }

  context 'validations' do
    it { should have_valid(:name).when('squishy bits') }
    it { should_not have_valid(:name).when(nil, '') }

    it { should have_valid(:extension).when('.foo') }
    it { should_not have_valid(:extension).when(nil, '') }

    context 'when file is present' do
      before { subject.file = file }
      it 'should be valid if no data' do
        subject.data = nil
        subject.valid?
        expect(subject.errors[:base]).to be_empty
      end

      it 'should be invalid if data' do
        subject.data = 'squishy bits'
        subject.valid?
        expect(subject.errors[:base]).not_to be_empty
      end
    end

    context 'when data is present' do
      before { subject.data = 'squishy bits' }
      it 'should be valid if no file' do
        subject.file = nil
        subject.valid?
        expect(subject.errors[:base]).to be_empty
      end

      it 'should be invalid if file' do
        subject.file = 'squishy bits'
        subject.valid?
        expect(subject.errors[:base]).not_to be_empty
      end
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

  describe '#content_type_and_disposition' do
    it "returns a PDF content type and disposition when extension is pdf" do
      subject = described_class.new(:extension => 'pdf', :name => 'booger.pdf', :identifier => 4)
      expect(subject.content_type_and_disposition).to eq(
        "Content-Type: application/pdf\r\n"\
        "Content-Disposition: file; filename=booger.pdf; documentid=4\r\n\r\n"
      )
    end

    it "returns a docx content type and disposition when extension is docx" do
      subject = described_class.new(:extension => 'docx', :name => 'booger.docx', :identifier => 5)
      expect(subject.content_type_and_disposition).to eq(
        "Content-Type: application/vnd.openxmlformats-officedocument.wordprocessingml.document\r\n"\
        "Content-Disposition: file; filename=booger.docx; documentid=5\r\n\r\n"
      )
    end
  end

  describe '#data_for_request' do
    it 'returns raw data when no file' do
      subject.data = 'a multicolored frog turbine shell'
      expect(subject.data_for_request).to eq 'a multicolored frog turbine shell'
    end

    it 'returns bytes of file when file exists' do
      subject.file = file
      expect(subject.data_for_request).to eq IO.read(file)
    end
  end

  describe '#multipart_form_part' do
    it "returns content type and disposition followed by data" do    
      allow(subject).to receive(:content_type_and_disposition).and_return('1, 2, 3... ')
      allow(subject).to receive(:data_for_request).and_return('get excited!')
      expect(subject.multipart_form_part).to eq "1, 2, 3... get excited!"
    end
  end

  describe '.fetch_for_envelope' do
    it 'reloads documents from DocuSign envelope' do
      adapter = double(Hancock::DocuSignAdapter, :documents => JSON.parse(response_body('documents'))['envelopeDocuments'])
      allow(adapter).to receive(:document).with('14').and_return('the bytes')
      allow(adapter).to receive(:document).with('16').and_return('omg more bytes')
      envelope = Hancock::Envelope.new(:identifier => 'a-crazy-envelope-id')
      allow(Hancock::DocuSignAdapter).to receive(:new).
        with('a-crazy-envelope-id').
        and_return(adapter)

      documents = described_class.fetch_for_envelope(envelope)
      expect(documents.map(&:identifier)).
        to match_array(['14', '16'])
      expect(documents.map(&:data)).
        to match_array(['the bytes', 'omg more bytes'])
      expect(documents.map(&:class).uniq).to eq [described_class]
    end
  end
end