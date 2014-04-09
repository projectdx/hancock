module Hancock
  class RecipientStatus
    def initialize(xml)

      @noko_doc = Nokogiri::XML.parse xml

    end

    def to_raw
      @noko_doc.to_s
    end

    def status
      @noko_doc.xpath('//Status').text.to_s
    end

    def recipient_id
      recipient_id = @noko_doc.xpath('//RecipientId').text.to_s
      recipient_id
    end

    def tab_statuses
      # collection of tab statuses
    end

  end
end