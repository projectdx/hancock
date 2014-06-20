describe Hancock::EnvelopeStatus do
  let(:callback_xml) { File.open(fixture_path('callback.xml'), "rb").read }

  before do
    @envelope_status = Hancock::EnvelopeStatus.new callback_xml
    @envelope_statuses = ['Sent', 'Delivered', 'Signed', 'Completed', 'Declined', 'Voided'] #allowed statuses
  end

  it "should have input xml with 'DocuSignEnvelopeInformation' root element" do
    doc = Nokogiri::XML::Document.parse callback_xml
    nodes = doc.xpath('//xmlns:DocuSignEnvelopeInformation')
    expect(nodes.empty?).to be_falsey
  end

  it "should have a proper status" do

    expect(@envelope_status.status).to be_an_instance_of(String)

    expect(@envelope_statuses).to include @envelope_status.status.capitalize

  end

  it "should fetch a collection of recipient status objects" do

    @envelope_status.recipient_statuses.each do |recipient_status|
      expect(recipient_status).to be_an_instance_of Hancock::RecipientStatus
    end

  end

  it "should fetch a collection of document objects" do

    @envelope_status.documents.each do |document|
      expect(document).to be_an_instance_of Hancock::Document
    end

  end

  it "each document should have name and identifier" do

    @envelope_status.documents.each do |document|
      document_hash = document.to_request
      expect(document_hash).to include(:name)
      expect(document_hash).to include(:documentId)
    end

  end


end