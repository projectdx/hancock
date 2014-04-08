module Hancock
  class EnvelopeStatus

    require 'active_support/core_ext/hash/conversions'

    def initialize(xml)

      @noko_doc = Nokogiri::XML.parse xml

      @noko_doc_hash = Hash.from_xml(@noko_doc)

      @status = nil
      @resipient_statuses = nil
      @documents = nil

    end

    def status
      @status = @noko_doc_hash["DocuSignEnvelopeInformation"]["EnvelopeStatus"]["Status"].to_s
    end

    def recipient_statuses
      @resipient_statuses = hash["DocuSignEnvelopeInformation"]["EnbelopeStatus"]["RecipientStatuses"].to_h
    end

    def documents
      @documents = hash["DocuSignEnvelopeInformation"]["DocumentPDFs"].to_h
    end

  end
end