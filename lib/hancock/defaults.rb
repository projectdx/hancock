module Hancock
  module Defaults

    #
    # class methods
    # 
    module ClassMethods
      def supplies_default_value_for(*args, &block)
        @defaults ||= []
        args << {block: block} if block
        @defaults << args
      end

      def defaults
        @defaults
      end

    end

    #
    # class variable defaults, must be unique for every
    # class in whitch this module will be extended
    #
    class << self
      def included base
        base.extend ClassMethods
      end
    end

    def supply_defaults!
      self.class.defaults.each do |validation|
        default_val = validation.select{ |i| i.is_a? Hash }.inject({}){|i, res| res.merge!(i)}
        attributes = validation.select{ |i| i.is_a? Symbol }
        attributes.each do |atr|
          supply_defaults_for_attribute!( atr, self.send(atr), default_val )
        end
      end
    end

    def supply_defaults_for_attribute! attr_name, attr_val, defaul_value
      value = defaul_value[:value]
      block = defaul_value[:block]
      if block
        value = self.send(value) ? block.call(self.send(value)) : nil
      elsif value.is_a?(Symbol) && self.respond_to?(value)
        value = self.send(value)
      end
      self.send( "#{attr_name}=", value ) unless attr_val
    end

    def random
      Random.rand(1..1234)
    end

  end
end