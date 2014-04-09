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

    validates :identifier, default: lambda{ |inst| inst.generate_identifier }
    validates :id_check, inclusion_of: [true, false], default: true
    validates :routing_order, default: 1
    validates :name, :email, presence: true
    validates :delivery_method, inclusion_of: [:email, :embedded, :offline, :paper], default: :email

    def initialize(attributes = {})
      ATTRIBUTES.each do |attr|
        self.send("#{attr}=", attributes[attr])
      end
      self.validate!
    end
  end
end
