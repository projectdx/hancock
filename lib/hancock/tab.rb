module Hancock
  class Tab < Hancock::Base
    attr_accessor :type, :label, :page_number, :coordinates, :optional, :required
    attr_reader :width, :font_size, :validation_pattern, :validation_message

    AVAILABLE_FONT_SIZES = [7, 8, 9, 10, 11, 12, 14, 16, 18, 20, 22, 24, 26, 28, 36, 48, 72]

    # TODO: These validations aren't actually being called, perhaps they should be
    validates :type, :presence => true
    validates :page_number, :numericality => { :greater_than => 0, :only_integer => true }

    def initialize(attributes = {})
      @type               = attributes[:type]
      @label              = attributes[:label]
      @coordinates        = attributes[:coordinates] || [0, 0]
      @page_number        = attributes[:page_number] || 1
      @validation_pattern = attributes[:validation_pattern]
      @validation_message = attributes[:validation_message]
      @width              = attributes[:width]
      @font_size          = attributes[:font_size]
      @optional           = attributes[:optional].to_s unless attributes[:optional].nil? # for Signer Attachment Tag
      @required           = attributes[:required].to_s unless attributes[:required].nil? # for Text tag

      unless acceptable_font_sizes.include?(font_size)
        raise ArgumentError, "Font size #{font_size} is not supported. Please choose from: #{AVAILABLE_FONT_SIZES.join(', ')}"
      end
    end

    def to_h
      {
        :tabLabel           => label,
        :xPosition          => coordinates[0],
        :yPosition          => coordinates[1],
        :pageNumber         => page_number,
        :validationPattern  => validation_pattern,
        :validationMessage  => validation_message,
        :width              => width,
        :fontSize           => docusign_font_size(font_size),
        :optional           => optional,
        :required           => required
      }.reject{ |_,value| value.nil? }
    end

    def coordinates=(coordinates)
      fail ArgumentError unless coordinates.is_a?(Array)

      @coordinates = coordinates
    end

    private

    def acceptable_font_sizes
      [nil] + AVAILABLE_FONT_SIZES
    end

    def docusign_font_size(number)
      number.nil? ? nil : "Size#{number}"
    end
  end
end
