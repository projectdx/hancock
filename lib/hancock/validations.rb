module Hancock
  module Validations

    #
    # class methods
    #
    module ClassMethods
      
      def validates_presence_of(*args)
        @validations ||= []
        args << { presence: true }
        @validations << args
      end

      def validates_type_of(*args)
        @validations ||= []
        @validations << args
      end

      def validates_inclusion_of(*args)
        @validations ||= []
        @validations << args
      end

      def validations
        @validations
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

    def validate!
      self.class.validations.each do |validation|
        condition  = validation.select{ |i| i.is_a? Hash }.inject({}){|i, res| res.merge!(i)}
        attributes = validation.select{ |i| i.is_a? Symbol }
        attributes.each do |atr|
          validate_attribute!( atr, self.send(atr), condition )
        end
      end
    end

    # TODO: Refactor this methos
    def validate_attribute! attr_name, attr_val, option={}
      return true if option[:allow_nil] && attr_val.nil?
      return true if option[:unless]    && self.send(option[:unless])

      if option[:presence]

        message = "Invalid argument '#{attr_name}'. '#{attr_name}' is required"
        raise Hancock::ArgumentError.new(message) unless attr_val

      elsif option[:type] && !option[:type].include?( attr_val.class )

        message = "Invalid argument '#{attr_name}'. Exspected #{option[:type]}, got #{attr_val.class}"
        raise Hancock::ArgumentError.new(message)

      elsif option[:inclusions] && !option[:inclusions].include?( attr_val )

        message = "Invalid argument '#{attr_name}'. Exspected #{option[:inclusions]}, got #{attr_val}"
        raise Hancock::ArgumentError.new(message)

      end
    end

  end
end