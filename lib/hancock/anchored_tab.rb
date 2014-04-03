module Hancock
  class AnchoredTab
    #
    # type: 'sign_here',
    # label: '{{recipient.name}} Signature',
    # offset: [2, 100]
    # anchor_text: 'Owner 1 Signature', # defaults to label
    #

    ATTRIBUTES = [:type, :label, :offset, :anchor_text]

    attr_reader :type, :label, :offset, :anchor_text

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
      @offset = offset
    end

    def anchor_text= anchor_text
      @anchor_text = attributes[:label]
    end

    def initialize(attributes = {})
      @attributes = attributes
      ATTRIBUTES.each do |attr|
        self.send("#{attr}=", attributes[attr])
      end
    end
  end
end