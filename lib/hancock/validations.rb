module Hancock
  module Validations

    #
    # class methods
    #
    module ClassMethods

      def validates(*args, &block)
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
          validate_attribute!( atr, condition )
        end
      end
    end

    #
    # We need @presence instance variable to skip
    # (type, inclusion_of, ..ect) validations if 
    # value should not be present.
    # For example if we are expecting inst.var_file 
    # to be File, we will get an error if it is Nil.
    #
    def validate_attribute! attr_name, options={}
      return  if options[:allow_nil]
      
      @presence = if options[:presence].is_a? Proc  
        options[:presence].call(self)
      else 
        options[:presence]
      end

      options.sort.to_h.each do |k, v|
        v = v.call(self) if v.is_a? Proc
        self.send("validate_#{k}!", attr_name, self.send(attr_name), v)
      end
    end

    def validate_presence! attr_name, attr_val, presence
      if !attr_val && presence
        message = "Invalid argument '#{attr_name}'. '#{attr_name}' is required"
        raise Hancock::ArgumentError.new(message)
      elsif attr_val && !presence
        message = "Invalid argument '#{attr_name}'. '#{attr_name}' is not required"
        raise Hancock::ArgumentError.new(message)
      end
    end

    def validate_type! attr_name, attr_val, type
      if ![type].flatten.include?( attr_val.class.to_s.to_sym.downcase ) && @presence
        message = "Invalid argument '#{attr_name}'. Exspected #{type}, got #{attr_val.class}"
        raise Hancock::ArgumentError.new(message)
      end
    end

    def validate_inclusion_of! attr_name, attr_val, inclusions
      unless inclusions.include?( attr_val )
        message = "Invalid argument '#{attr_name}'. Exspected #{inclusions}, got #{attr_val}"
        raise Hancock::ArgumentError.new(message)
      end
    end

    def validate_default! attr_name, attr_val, default
      self.send( "#{attr_name}=", default ) unless attr_val
    end

  end
end