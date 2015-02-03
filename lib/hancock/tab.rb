module Hancock
  class Tab < Hancock::Base
    attr_accessor :type, :label, :page_number, :coordinates

    validates :type, :label, :coordinates, :page_number, :presence => true
    validates :page_number, :numericality => { :greater_than => 0, :only_integer => true }

    def initialize(attributes = {})
      @type        = attributes[:type]
      @label       = attributes[:label]
      @coordinates = attributes[:coordinates] || [0, 0]
      @page_number = attributes[:page_number] || 1
    end

    def to_h
      {
        :tabLabel           => label,
        :xPosition          => coordinates[0],
        :yPosition          => coordinates[1],
        :pageNumber         => page_number
      }
    end

    def coordinates=(coordinates)
      fail ArgumentError unless coordinates.is_a?(Array)

      @coordinates = coordinates
    end
  end
end
