module Hancock
  class Tab < Hancock::Base

    #
    # type: 'initial_here',
    # label: 'Absolutely Positioned Initials',
    # coordinates: [160, 400]
    # page_number: default 1
    #

    ATTRIBUTES = [:type, :label, :coordinates, :page_number]

    attr_reader :type, :label, :page_number, :coordinates

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
      coordinates.each do |c|
        unless c.is_a? Integer
          raise Hancock::ArgumentUnvalidError.new(c.class, Integer)
        end 
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