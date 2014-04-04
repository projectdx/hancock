module Hancock
  class AnchoredTab < Hancock::Base
    #
    # type:        'sign_here',
    # label:       '{{recipient.name}} Signature',
    # offset:      [2, 100]
    # anchor_text: 'Owner 1 Signature', # defaults to label
    # page_number: default 1
    #

    ATTRIBUTES = [:type, :label, :offset, :anchor_text, :page_number]

    attr_reader :type, :label, :offset, :anchor_text, :page_number

    def page_number= page_number
      @page_number = page_number || 1
    end

    def type= type
      raise Hancock::ArgumentError.new() unless type
      @type = type
    end

    def label= label
      raise Hancock::ArgumentError.new() unless label
      @label = label
    end

    def offset= offset
      unless offset.is_a? Array
        raise Hancock::ArgumentUnvalidError.new(offset.class, Array) 
      end
      offset.each do |c|
        unless c.is_a? Integer
          raise Hancock::ArgumentUnvalidError.new(c.class, Integer)
        end 
      end
      @offset = offset
    end

    def anchor_text= anchor_text
      anchor_text = anchor_text
      @anchor_text ||= @attributes[:label]
    end

    def initialize(attributes = {})
      @attributes = attributes
      ATTRIBUTES.each do |attr|
        self.send("#{attr}=", attributes[attr])
      end
    end
  end
end