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
        options    = get_options(validation)
        condition  = get_conditions(options)
        validation.select{ |i| i.is_a? Symbol }.each do |atr|
          validate_attribute!( atr, options ) if condition
        end
      end
    end

    private

      #
      # We need conditions hash to be sorted, so defaults run
      # before presence validations. 
      # options.sort => will return array like [[:key, :val],...]
      #
      def validate_attribute! attr_name, options={}
        attr_value = self.send(attr_name)
        return if attr_value.nil? && options[:allow_nil]

        options.each do |method, condition|
          #
          # Skip conditionals
          #
          next if [:unless, :if, :allow_nil].include?(method)

          condition = condition.call(self) if condition.is_a? Proc
          self.send("validate_#{method}!", attr_name, attr_value, condition)
        end
      end

      #
      # Can validate strict presence and strict absence.
      #
      def validate_presence! attr_name, attr_val, presence
        if attr_val.blank? && presence
          message = "Invalid argument '#{attr_name}'. '#{attr_name}' is required"
          raise Hancock::ArgumentError.new(message)
        elsif !attr_val.blank? && !presence
          message = "Invalid argument '#{attr_name}'. '#{attr_name}' is not required"
          raise Hancock::ArgumentError.new(message)
        end
      end

      #
      # We will ignore nil
      # return if options[:presence] == false
      #
      def validate_type! attr_name, attr_val, type
        if ![ type ].flatten.include?( attr_val.class.to_s.to_sym.downcase )
          message = "Invalid argument '#{attr_name}'. Exspected #{ type }, got #{attr_val.class}"
          raise Hancock::ArgumentError.new(message)
        end
      end

      def validate_inclusion_of! attr_name, attr_val, inclusion_of
        unless inclusion_of.include?( attr_val )
          message = "Invalid argument '#{attr_name}'. Exspected #{ inclusion_of }, got #{attr_val}"
          raise Hancock::ArgumentError.new(message)
        end
      end

      def get_options options={}
        options.select { |i| i.is_a? Hash }.inject({}) { |i, res| res.merge!(i) }.clone
      end

      def get_conditions options={}
        if options.has_key?(:if)
          !self.send( options[:if] ).nil?
        elsif options.has_key?(:unless)
          self.send( options[:unless] ).nil?
        else
          true
        end
      end

  end
end