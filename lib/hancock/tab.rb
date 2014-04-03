module Hancock
  class Tab < Hancock::TemplateBase

    #
    # type: 'initial_here',
    # label: 'Absolutely Positioned Initials',
    # coordinates: [160, 400]
    #

    ATTRIBUTES = [:type, :label, :coordinates, :page_number]

    attr_reader :type, :label, :coordinates, :page_number

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

    def coordinates= coordinates
      unless coordinates.is_a? Array
        raise Hancock::ArgumentUnvalidError.new(coordinates.class, Array) 
      end
      @coordinates = coordinates
    end

    def initialize(attributes = {})
      ATTRIBUTES.each do |attr|
        self.send("#{attr}=", attributes[attr])
      end
    end
  end
end