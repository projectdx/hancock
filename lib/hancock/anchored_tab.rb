module Hancock
  class AnchoredTab < Hancock::Base
    #
    # type:        'sign_here',
    # label:       '{{recipient.name}} Signature',
    # offset:      [2, 100]
    # anchor_text: 'Owner 1 Signature', # defaults to label
    # page_number: default 1
    #

    ATTRIBUTES = [:type, :label, :offset, :anchor_text, :page_number]

    attr_accessor :type, :label, :offset, :anchor_text, :page_number

    validates_presence_of :type, :label, :offset
    validates_type_of :coordinates, type: [Array]
    supplies_default_value_for :page_number, value: 1
    supplies_default_value_for :anchor_text, value: :label

    def initialize(attributes = {})
      @attributes = attributes
      ATTRIBUTES.each do |attr|
        self.send("#{attr}=", attributes[attr])
      end
      self.validate!
      self.supply_defaults!
    end
  end
end