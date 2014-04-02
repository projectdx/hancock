module Hancock
  class Recipient
    #
    # name: 'Owner 1',
    # email: 'whoever@whereever.com',
    # id_check: true,
    # delivery_method: email, # email, embedded, offline, paper
    # routing_order: 1
    #

    ATTRIBUTES = [:name, :email, :id_check, :delivery_method, :routing_order]

    attr_reader :name, :email, :id_check, :delivery_method, :routing_order

    def name= name
      raise 'error' unless name
      @name = name
    end

    def email= email
      raise 'error' unless email
      @email = email
    end

    def id_check= id_check
      id_check ||= true
      raise 'error' unless [true, false].include?(id_check)
      @id_check = id_check
    end

    def delivery_method= delivery_method
      delivery_method ||= :email
      raise 'error' unless [:email, :embedded, :offline, :paper].include?(delivery_method)
      @delivery_method = delivery_method
    end

    def routing_order= routing_order
      raise 'error' unless routing_order.is_a? Integer
      @routing_order = routing_order
    end

    def initialize(attributes = {})
      ATTRIBUTES.each do |attr|
        self.send(attr, attributes[attr])
      end
    end
  end
end