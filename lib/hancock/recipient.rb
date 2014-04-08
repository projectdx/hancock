module Hancock
  class Recipient < Hancock::Base

    #
    # name:            'Owner 1',
    # email:           'whoever@whereever.com',
    # id_check:        true/false,
    # delivery_method: email, # email, embedded, offline, paper
    # routing_order:   1
    # identifier:      optional, generates if not given
    #

    ATTRIBUTES = [:name, :email, :id_check, :delivery_method, :routing_order, :identifier]

    attr_accessor :name, :email, :id_check, :delivery_method, :routing_order, :identifier

    supplies_default_value_for :identifier,      value: :random
    supplies_default_value_for :id_check,        value: true
    supplies_default_value_for :routing_order,   value: 1
    validates_presence_of :name, :email
    validates_type_of :id_check, type: [TrueClass, FalseClass]
    validates_type_of :routing_order, type: [Fixnum]
    validates_inclusion_of :delivery_method, inclusions: [:email, :embedded, :offline, :paper]

    def initialize(attributes = {})
      ATTRIBUTES.each do |attr|
        self.send("#{attr}=", attributes[attr])
      end
      self.supply_defaults!
      self.validate!
    end
  end
end
