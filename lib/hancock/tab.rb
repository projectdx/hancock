module Hancock
  class Tab < Hancock::Base

    #
    # type: 'initial_here',
    # label: 'Absolutely Positioned Initials',
    # coordinates: [160, 400]
    # page_number: default 1
    #

    ATTRIBUTES = [:type, :label, :coordinates, :page_number]

    attr_accessor :type, :label, :page_number, :coordinates

    validates :type, :label, presence: true 
    validates :coordinates, type: :array, presence: true 
    validates :page_number, default: 1

    def initialize(attributes = {})
      ATTRIBUTES.each do |attr|
        self.send("#{attr}=", attributes[attr])
      end
      self.validate!
    end
  end
end