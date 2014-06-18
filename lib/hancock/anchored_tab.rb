require_relative 'tab'

module Hancock
  class AnchoredTab < Tab
    def initialize(attributes = {})
      @anchor_text = attributes[:anchor_text]
      super
    end

    # NOTE: I would really like to know if this has any difference in DocuSign's interface.
    def anchor_text
      @anchor_text || label
    end

    def to_h
      {
        :anchorString       => anchor_text,
        :anchorXOffset      => coordinates[0],
        :anchorYOffset      => coordinates[1],
        :IgnoreIfNotPresent => 1,
        :pageNumber         => page_number
      }
    end
  end
end
