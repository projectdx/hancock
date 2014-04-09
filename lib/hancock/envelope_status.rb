module Hancock
  class EnvelopeStatus

    #require 'active_support/core_ext/hash/conversions'

    def initialize(xml)

      @noko_doc = Nokogiri::XML.parse xml

      #@noko_doc_hash = Hash.from_xml(@noko_doc)

      @status = nil
      @recipient_statuses = nil
      @documents = nil

      self

    end

    def noko
      @noko_doc
    end

    # @return a status of envelope
    def status
      #@status = @noko_doc_hash["DocuSignEnvelopeInformation"]["EnvelopeStatus"]["Status"].to_s
      @status ||= noko.xpath("//xmlns:EnvelopeStatus/xmlns:Status").text.to_s
    end

    # @return a collection of Hancock::RecipientStatus
    def recipient_statuses
      #@reсipient_statuses = hash["DocuSignEnvelopeInformation"]["EnvelopeStatus"]["RecipientStatuses"].to_h

      @recipient_statuses = Array.new
      noko.css("RecipientStatuses RecipientStatus").each do |status_element|
        @recipient_statuses.push(Hancock::RecipientStatus.new(status_element.to_s))

        # recipient_id = @recipient_statuses[0].recipient_id
      end

      @recipient_statuses
    end

    # @return a collection of Hancock::Document
    def documents
      #@todo needs to be added
    end

  end
end