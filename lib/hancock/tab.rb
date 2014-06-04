module Hancock
  class Tab < Hancock::Base

    #
    # type: 'initial_here',
    # label: 'Absolutely Positioned Initials',
    # coordinates: [160, 400]
    # page_number: default 1
    #

    attr_accessor :type, :label, :page_number, :coordinates

    validates :type, :label, presence: true 
    validates :coordinates, type: :array, presence: true 

    def initialize(attributes = {})
      @type        = attributes[:type] 
      @label       = attributes[:label]
      @coordinates = attributes[:coordinates]
      @page_number = attributes[:page_number] || 1

      self.validate!
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