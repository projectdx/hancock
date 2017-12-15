require_relative 'tab'

module Hancock
  class AnchoredTab < Tab
    def initialize(attributes = {})
      @anchor_text = attributes[:anchor_text]
      super
    end

    def anchor_text
      @anchor_text || label
    end

    def to_h
      {
        anchorString:             anchor_text,
        anchorXOffset:            coordinates[0],
        anchorYOffset:            coordinates[1],
        pageNumber:               page_number,
        anchorIgnoreIfNotPresent: true,
        validationPattern:        validation_pattern,
        validationMessage:        validation_message,
        width:                    width,
        fontSize:                 docusign_font_size(font_size),
        optional:                 optional,
        tabLabel:                 label,
        required:                 required,
        shared:                   shared,
        requireAll:               require_all
      }.reject{ |_, value| value.nil? }
    end
  end
end
