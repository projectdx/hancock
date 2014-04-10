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

    attr_accessor :name, :email, :id_check, :delivery_method, :routing_order, :identifier

    validates :identifier, default: lambda{ |inst| inst.generate_identifier }
    validates :id_check, inclusion_of: [true, false], default: true
    validates :routing_order, default: 1
    validates :name, :email, presence: true
    validates :delivery_method, inclusion_of: [:email, :embedded, :offline, :paper], default: :email

    def initialize(attributes = {}, run_validations=true)
      @name            = attributes[:name]
      @email           = attributes[:email]
      @id_check        = attributes[:id_check]
      @delivery_method = attributes[:delivery_method]
      @routing_order   = attributes[:routing_order]
      @routing_order   = attributes[:routing_order]

      self.validate! if run_validations
    end
  end
end
