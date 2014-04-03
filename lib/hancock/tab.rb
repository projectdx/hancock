module Hancock
  class Tab

    #
    # type: 'initial_here',
    # label: 'Absolutely Positioned Initials',
    # coordinates: [160, 400]
    #

    ATTRIBUTES = [:type, :label, :coordinates]

    attr_reader :type, :label, :coordinates

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