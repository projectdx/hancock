require_relative '../spec_helper'

describe Hancock::EnvelopeStatus do
  include_context "variables"

  before do
    @envelope_status = Hancock::EnvelopeStatus.new callback_xml
    @envelope_statuses = ['Sent', 'Delivered', 'Signed', 'Completed', 'Declined', 'Voided'] #allowed statuses
  end

  it "should have input xml with 'DocuSignEnvelopeInformation' root element" do
    doc = Nokogiri::XML::Document.parse callback_xml
    nodes = doc.xpath('//xmlns:DocuSignEnvelopeInformation')
    nodes.empty?.should be_false
  end

  it "should have a proper status" do

    @envelope_status.status.should be_an_instance_of(String)

    expect(@envelope_statuses).to include @envelope_status.status.capitalize

  end

  it "should fetch a collection of recipient status objects" do

    @envelope_status.recipient_statuses.each do |recipient_status|
      recipient_status.should be_an_instance_of Hancock::RecipientStatus
    end

  end

  it "should fetch a collection of document objects" do

    @envelope_status.documents.each do |document|
      document.should be_an_instance_of Hancock::Document
    end

  end

  it "each document should have name and identifier" do

    @envelope_status.documents.each do |document|
      document_hash = document.to_request
      document_hash.should include(:name)
      document_hash.should include(:documentId)
    end

  end


end