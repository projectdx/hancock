module Hancock
  class EnvelopeStatus

    def initialize(xml)

      @noko_doc = Nokogiri::XML.parse xml

      @status = nil
      @recipient_statuses = []
      @documents = []

      self

    end

    #
    # An accessor for Nokogiri parser
    #
    def noko
      @noko_doc
    end

    #
    # Returns a status of envelope
    #
    def status
      #@status = @noko_doc_hash["DocuSignEnvelopeInformation"]["EnvelopeStatus"]["Status"].to_s
      @status ||= noko.xpath("//xmlns:EnvelopeStatus/xmlns:Status").text.to_s
    end

    #
    # Returns collection of Hancock::RecipientStatus
    #
    def recipient_statuses

      return @recipient_statuses unless @recipient_statuses.empty?
      noko.css('RecipientStatuses > RecipientStatus').each do |status_element|
        @recipient_statuses << Hancock::RecipientStatus.new(status_element.to_s)

        # recipient_id = @recipient_statuses[0].recipient_id
      end

      @recipient_statuses
    end

    #
    # Returns a collection of Hancock::Document
    #
    def documents

      return @documents unless @documents.empty?
      #noko.xpath("//xmlns:DocumentPDFs/xmlns:DocumentPDF").each do |document_element|
      noko.css('DocumentPDFs > DocumentPDF').each do |document_element|
        @documents.push(Hancock::Document.new(
            data: document_element.css('PDFBytes').first.text,
            name: document_element.css('Name').first.text,
            extension: 'pdf'
        ))
      end

      @documents

    end

  end
end