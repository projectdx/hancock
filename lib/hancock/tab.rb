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

    validates_presence_of :type, :label, :coordinates
    validates_type_of :coordinates, type: [Array]
    supplies_default_value_for :page_number, value: 1

    def initialize(attributes = {})
      ATTRIBUTES.each do |attr|
        self.send("#{attr}=", attributes[attr])
      end
      self.validate!
      self.supply_defaults!
    end
  end
end