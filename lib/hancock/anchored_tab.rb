module Hancock
  class AnchoredTab < Hancock::Base
    #
    # type:        'sign_here',
    # label:       '{{recipient.name}} Signature',
    # offset:      [2, 100]
    # anchor_text: 'Owner 1 Signature', # defaults to label
    # page_number: default 1
    #

    attr_accessor :type, :label, :offset, :anchor_text, :page_number

    validates :type, :label, :offset, presence: true 
    validates :offset, type: :array
    validates :page_number, default: 1
    validates :anchor_text, default: lambda{ |inst| inst.label }

    def initialize(attributes = {})
      @type        = attributes[:type]
      @label       = attributes[:label]
      @offset      = attributes[:offset]
      @anchor_text = attributes[:anchor_text]
      @page_number = attributes[:page_number]

      self.validate!
    end

    def to_h
      {
        :anchorString       => anchor_text,
        :anchorXOffset      => offset[0],
        :anchorYOffset      => offset[1],
        :IgnoreIfNotPresent => 1,
        :pageNumber         => page_number
      }
    end

  end
end