module Hancock
  class Recipient < Hancock::Base
    TYPES = [:agent, :carbon_copy, :certified_delivery, :editor, :in_person_signer, :intermediary, :signer]

    attr_accessor :name, :email, :id_check, :delivery_method, :routing_order, :identifier, :recipient_type

    validates :name, :email, :presence => true
    validates :id_check, :allow_nil => true, :inclusion => [true, false]
    validates :delivery_method, :inclusion => [:email, :embedded, :offline, :paper]
    validates :recipient_type, :inclusion => TYPES
    validates :email, :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }

    def initialize(attributes = {})
      @name            = attributes[:name]
      @email           = attributes[:email]
      @id_check        = attributes.fetch(:id_check,        true)
      @delivery_method = attributes.fetch(:delivery_method, :email)
      @routing_order   = attributes.fetch(:routing_order,   1)
      @recipient_type  = attributes.fetch(:recipient_type,  :signer)
      @identifier      = attributes[:identifier]
    end

    def self.fetch_for_envelope(envelope)
      connection = Hancock::DocuSignAdapter.new(envelope.identifier)
      envelope_recipients = connection.recipients

      TYPES.map do |type|
        envelope_recipients[docusign_recipient_type(type)].map do |envelope_recipient|
          new(:name => envelope_recipient['name'],
              :email => envelope_recipient['email'],
              :id_check => nil,
              :routing_order => envelope_recipient['routingOrder'].to_i,
              :recipient_type => type,
              :identifier => envelope_recipient['recipientId'].to_i)
        end
      end.flatten
    end
    #
    # format recipient type(symbol) for DocuSign
    #
    def self.docusign_recipient_type(type)
      type.to_s.camelize(:lower).pluralize
    end
  end
end
