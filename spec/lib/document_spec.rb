describe Hancock::Document do
  let(:file) { File.open(fixture_path('test.pdf')) }
  let(:data) { IO.read(File.open(fixture_path('Person.docx'))) }

  context 'validations' do
    it { is_expected.to have_valid(:name).when('squishy bits') }
    it { is_expected.not_to have_valid(:name).when(nil, '') }

    it { is_expected.to have_valid(:extension).when('.foo') }
    it { is_expected.not_to have_valid(:extension).when(nil, '') }

    describe '#data_meets_minimum_size_requirement?' do
      it 'should be invalid if data is too small' do
        subject.data = 'squishy bits'
        allow(Hancock).to receive(:minimum_document_data_size).and_return(20)
        subject.file = nil
        subject.valid?
        expect(subject.errors[:base].first).to eq("Data size is: 12 bytes. Minimum size is: 20.")
        expect(subject.data_meets_minimum_size_requirement?).to be_falsey
      end

      it 'should be true if the data is greater than the minimum' do
        subject.data = data
        subject.file = nil
        subject.valid?
        expect(subject.errors[:base]).to be_empty
        expect(subject.data_meets_minimum_size_requirement?).to be_truthy
      end

      it 'should be nil if there is no data' do
        subject.file = file
        subject.valid?
        expect(subject.errors[:base]).to be_empty
        expect(subject.data_meets_minimum_size_requirement?).to be_nil
      end
    end

    describe '#has_either_data_or_file?' do
      context 'when file is present' do
        before { subject.file = file }
        it 'should be valid if no data' do
          subject.data = nil
          subject.valid?
          expect(subject.errors[:base]).to be_empty
          expect(subject.has_either_data_or_file?).to be_truthy
        end

        it 'should be invalid if data' do
          subject.data = 'squishy bits'
          subject.valid?
          expect(subject.errors[:base]).not_to be_empty
          expect(subject.has_either_data_or_file?).to be_falsey
        end
      end

      context 'when data is present' do
        context 'given a string' do
          before { subject.data = 'squishy bits' }
          it 'should be valid if no file' do
            subject.file = nil
            subject.valid?
            expect(subject.errors[:base]).to be_empty
            expect(subject.has_either_data_or_file?).to be_truthy
          end

          it 'should be invalid if file' do
            subject.file = file
            subject.valid?
            expect(subject.errors[:base]).not_to be_empty
            expect(subject.has_either_data_or_file?).to be_falsey
          end
        end
      end

      context 'when given neither file nor data' do
      end

      context 'when given both file nor data' do
      end
    end

  end

  context 'with a file' do
    subject { described_class.new(file: file) }
    describe '#name' do
      it 'returns name of file' do
        expect(subject.name).to eq 'test.pdf'
      end

      it 'can be overridden' do
        subject.name = 'moofits.pdf'
        expect(subject.name).to eq 'moofits.pdf'
      end
    end

    describe '#extension' do
      it 'returns extension extracted from filename' do
        expect(subject.extension).to eq 'pdf'
      end

      it 'returns extension extracted from @name when using @data instead of @file' do
        subject = described_class.new(data: '', name: 'superman.docx')
        expect(subject.extension).to eq 'docx'
      end

      it 'can be overridden' do
        subject.extension = 'wild_fans_of_mogwai_county'
        expect(subject.extension).to eq 'wild_fans_of_mogwai_county'
      end
    end
  end

  describe '#content_type_and_disposition' do
    it 'returns a PDF content type and disposition when extension is pdf' do
      subject = described_class.new(extension: 'pdf', name: 'booger.pdf', identifier: 4)
      expect(subject.content_type_and_disposition).to eq(
        "Content-Type: application/pdf\r\n"\
        "Content-Disposition: file; filename=booger.pdf; documentid=4\r\n\r\n"
      )
    end

    it 'returns a docx content type and disposition when extension is docx' do
      subject = described_class.new(extension: 'docx', name: 'booger.docx', identifier: 5)
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

  context 'document fetching' do
    let(:envelope) { Hancock::Envelope.new(identifier: 'a-crazy-envelope-id') }
    before(:each) do
      adapter = double(Hancock::DocuSignAdapter, documents: JSON.parse(response_body('documents'))['envelopeDocuments'])
      allow(adapter).to receive(:document).with('14').and_return('the bytes')
      allow(adapter).to receive(:document).with('16').and_return('omg more bytes')
      allow(adapter).to receive(:document).with('certificate').and_return('a golden ticket!')
      allow(Hancock::DocuSignAdapter).to receive(:new).
        with('a-crazy-envelope-id').
        and_return(adapter)
    end

    describe '.fetch_all_for_envelope' do
      it 'reloads only content documents from DocuSign envelope by default' do
        documents = described_class.fetch_all_for_envelope(envelope)
        expect(documents.map(&:data)).
          to match_array(['the bytes', 'omg more bytes'])
        expect(documents.map(&:identifier)).
          to match_array([14, 16])
        expect(documents.map(&:class).uniq).to eq [described_class]
      end

      it 'also loads summary documents if requested' do
        documents = described_class.fetch_all_for_envelope(envelope, types: ['content', 'summary'])
        expect(documents.map(&:identifier)).
          to match_array([14, 16, 'certificate'])
      end

      it 'only loads summary documents if requested' do
        documents = described_class.fetch_all_for_envelope(envelope, types: ['summary'])
        expect(documents.map(&:identifier)).
          to match_array(['certificate'])
      end
    end
  end
end
