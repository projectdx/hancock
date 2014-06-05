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

    Types = [:agent, :carbon_copy, :certified_delivery, :editor, :in_person_signer, :intermediary, :signer]
    attr_accessor :name, :email, :id_check, :delivery_method, :routing_order, :identifier, :recipient_type

    validates :name, :email, :presence => true
    validates :id_check, :allow_nil => true, :inclusion_of => [true, false]
    validates :delivery_method, :inclusion_of => [:email, :embedded, :offline, :paper]
    validates :recipient_type, :inclusion_of => Types

    def validate!
      super
      unless email =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
        (errors[:email] ||= []) << 'must be valid email'
      end
    end

    def initialize(attributes = {}, run_validations=true)
      @name            = attributes[:name]
      @email           = attributes[:email]
      @id_check        = attributes[:id_check]        || true
      @delivery_method = attributes[:delivery_method] || :email
      @routing_order   = attributes[:routing_order]   || 1
      @recipient_type  = attributes[:recipient_type]  || :signer
      @identifier      = attributes[:identifier]      || generate_identifier()
    end

    def self.fetch_for_envelope(envelope)
      connection = Hancock::DocuSignAdapter.new(envelope.identifier)
      envelope_recipients = connection.recipients

      Types.map { |type|
        envelope_recipients[docusign_recipient_type(type)].map { |envelope_recipient|
          new({
            name: envelope_recipient["name"],
            email: envelope_recipient["email"],
            id_check: nil,
            routing_order: envelope_recipient["routingOrder"].to_i,
            recipient_type: type,
            identifier: envelope_recipient["recipientId"]
          })
        }
      }.flatten
    end
  end
end
