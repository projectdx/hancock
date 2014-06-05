module Hancock
  class Tab < Hancock::Base
    attr_accessor :type, :label, :page_number, :coordinates

    validates :type, :label, presence: true 
    validates :coordinates, type: :array, presence: true
    validates :page_number, :presence => true, :type => :fixnum

    def initialize(attributes = {})
      @type        = attributes[:type] 
      @label       = attributes[:label]
      @coordinates = attributes[:coordinates]
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
  end
end