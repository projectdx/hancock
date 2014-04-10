module Hancock
  class RecipientStatus
    def initialize(xml)
      @noko_doc = Nokogiri::XML.parse xml
    end

    #
    # An accessor for Nokogiri parser
    #
    def noko
      @noko_doc
    end

    #
    # Gives you a raw xml of Recipient data
    #
    def to_raw
      noko.to_s
    end

    #
    # Returns a status of a Recipient
    #
    def status
      noko.xpath('*/Status').text.to_s
    end

    #
    # Returns a Recipient Id
    #
    def recipient_id
      noko.xpath('//RecipientId').text.to_s
    end

    #
    # Returns a Recipient tabs statuses
    #
    def tab_statuses
      # collection of tab statuses
    end

  end
end