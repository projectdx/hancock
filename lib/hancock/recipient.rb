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

    attr_reader :name, :email, :id_check, :delivery_method, :routing_order, :identifier

    def name= name
      raise Hancock::ArgumentError.new() unless name
      @name = name
    end

    def email= email
      raise Hancock::ArgumentError.new() unless email
      @email = email
    end

    def id_check= id_check
      id_check ||= true
      unless [true, false].include?(id_check)
        message = 'must be type of True/False'
        raise Hancock::ArgumentError.new(message)
      end
      @id_check = id_check
    end

    def delivery_method= delivery_method
      delivery_method ||= :email
      unless [:email, :embedded, :offline, :paper].include?(delivery_method)
        message = 'must be inclusion of [:email, :embedded, :offline, :paper]'
        raise Hancock::ArgumentError.new(message) 
      end
      @delivery_method = delivery_method
    end

    def routing_order= routing_order
      unless routing_order.is_a? Integer
        raise Hancock::ArgumentUnvalidError.new(routing_order.class, Integer) 
      end
      @routing_order = routing_order
    end

    def identifier= identifier
      @identifier = identifier 
      @identifier ||= generate_identifier
    end

    def initialize(attributes = {})
      ATTRIBUTES.each do |attr|
        self.send("#{attr}=", attributes[attr])
      end
    end
  end
end