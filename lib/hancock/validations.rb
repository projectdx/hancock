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

    def validate!
      self.class.validations.each do |validation|
        options    = get_options(validation)
        condition  = build_condition(options)
        validation.select{ |i| i.is_a? Symbol }.each do |atr|
          validate_attribute!( atr, options ) if condition
        end
      end
    end

    private

      def validate_attribute!(attr_name, options={})
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
      def validate_presence!(attr_name, attr_val, presence)
        message = if attr_val.blank? && presence
          "Invalid argument '#{attr_name}'. '#{attr_name}' is required"
        elsif !attr_val.blank? && !presence
          "Invalid argument '#{attr_name}'. '#{attr_name}' is not required"
        end

        raise_error(message) if message
      end

      #
      # We will ignore nil
      # return if options[:presence] == false
      #
      def validate_type!(attr_name, attr_val, type)
        if ![ type ].flatten.include?( attr_val.class.to_s.to_sym.downcase )
          raise_error("Invalid argument '#{attr_name}'. Exspected #{ type }, got #{attr_val.class}")
        end
      end

      def validate_inclusion_of!(attr_name, attr_val, inclusion_of)
        unless inclusion_of.include?( attr_val )
          raise_error("Invalid argument '#{attr_name}'. Exspected #{ inclusion_of }, got #{attr_val}")
        end
      end

      #
      # We are passing a copy of conditions here
      # condition.clone 
      #
      def get_options(options={})
        options.select { |i| i.is_a? Hash }.inject({}) { |i, res| res.merge!(i) }.clone
      end

      def build_condition(options={})
        if options.has_key?(:if)
          !self.send( options[:if] ).nil?
        elsif options.has_key?(:unless)
          self.send( options[:unless] ).nil?
        else
          true
        end
      end

      def raise_error(message)
        raise Hancock::ArgumentError.new(message)
      end

  end
end