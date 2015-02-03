module Hancock
  class RecipientStatus
    def initialize(xml)
      @noko = Nokogiri::XML.parse xml
    end

    #
    # Returns a status of a Recipient
    #
    def status
      @noko.xpath('*/Status').text.to_s
    end

    #
    # Returns a Recipient Id
    #
    def recipient_id
      @noko.xpath('//RecipientId').text.to_s
    end

    #
    # Returns a Recipient tabs statuses. (As an example)
    #
    def tab_statuses
      # collection of tab statuses
      # @todo needs realization
    end
  end
end
