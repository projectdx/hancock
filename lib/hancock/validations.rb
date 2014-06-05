module Hancock
  module Validations

    #
    # class methods
    #
    module ClassMethods

      def validates(*args)
        validations << args
      end

      def validations
        @validations ||= []
      end
    end

    #
    # class variable defaults, must be unique for every
    # class in whitch this module will be extended
    #
    class << self
      def included base
        base.extend ClassMethods
        base.class_eval do
          def self.inherited(subclass)
            subclass.validations.concat validations
          end
        end
      end
    end

    def errors
      @errors ||= {}
    end

    def errors_on(attribute)
      errors[attribute] || []
    end

    def valid?
      validate!
      errors.empty?
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
          "must be set"
        elsif !attr_val.blank? && !presence
          "must not be set"
        end

        if message
          (errors[attr_name] ||= []) << message
        end
      end

      #
      # We will ignore nil
      # return if options[:presence] == false
      #
      def validate_type!(attr_name, attr_val, type)
        if ![ type ].flatten.include?( attr_val.class.to_s.to_sym.downcase )
          (errors[attr_name] ||= []) << "must be of type: #{type}"
        end
      end

      def validate_inclusion_of!(attr_name, attr_val, inclusion_of)
        unless inclusion_of.include?( attr_val )
          (errors[attr_name] ||= []) << "must be included in: #{inclusion_of}"
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
        options.all? do |key, val|
          if key == :if
            self.send(val)
          elsif key == :unless
            !self.send(val)
          else
            true
          end
        end
      end
  end
end