module Hancock
  module Validations

    #
    # class methods
    #
    module ClassMethods

      def validates(*args)
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

    #
    # We are passing a copy of conditions here
    # condition.clone 
    #
    def validate!
      self.class.validations.each do |validation|
        condition  = validation.select{ |i| i.is_a? Hash }.inject({}){|i, res| res.merge!(i)}
        attributes = validation.select{ |i| i.is_a? Symbol }
        attributes.each do |atr|
          validate_attribute!( atr, condition.clone )
        end
      end
    end


    #
    # We need conditions hash to be sorted, so defaults run
    # before presence validations. 
    # options.sort => will return array like [[:key, :val],...]
    #
    def validate_attribute! attr_name, options={}
      return if options[:allow_nil]

      options.sort.each do |validation|
        options[validation[0]] = validation[1].call(self) if validation[1].is_a? Proc
        self.send("validate_#{validation[0]}!", attr_name, self.send(attr_name), options)
      end
    end


    #
    # Can validate strict presence and strict absence.
    #
    def validate_presence! attr_name, attr_val, options
      if attr_val.blank? && options[:presence]
        message = "Invalid argument '#{attr_name}'. '#{attr_name}' is required"
        raise Hancock::ArgumentError.new(message)
      elsif !attr_val.blank? && !options[:presence]
        message = "Invalid argument '#{attr_name}'. '#{attr_name}' is not required"
        raise Hancock::ArgumentError.new(message)
      end
    end

    #
    # We will ignore nil
    # return if options[:presence] == false
    #
    def validate_type! attr_name, attr_val, options
      if ![ options[:type] ].flatten.include?( attr_val.class.to_s.to_sym.downcase )
        return if options[:presence] == false
        message = "Invalid argument '#{attr_name}'. Exspected #{ options[:type] }, got #{attr_val.class}"
        raise Hancock::ArgumentError.new(message)
      end
    end

    def validate_inclusion_of! attr_name, attr_val, options
      unless options[:inclusion_of].include?( attr_val )
        message = "Invalid argument '#{attr_name}'. Exspected #{ options[:inclusion_of] }, got #{attr_val}"
        raise Hancock::ArgumentError.new(message)
      end
    end

  end
end