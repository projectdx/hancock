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

    RECIPIENT_TYPES = [:agent, :carbon_copy, :certified_delivery, :editor, :in_person_signer, :intermediary, :signer]
    attr_accessor :name, :email, :id_check, :delivery_method, :routing_order, :identifier, :recipient_type

    validates :id_check, inclusion_of: [true, false]
    validates :name, :email, presence: true
    validates :delivery_method, inclusion_of: [:email, :embedded, :offline, :paper]
    validates :recipient_type, inclusion_of: RECIPIENT_TYPES

    def initialize(attributes = {}, run_validations=true)
      @name            = attributes[:name]
      @email           = attributes[:email]
      @id_check        = attributes[:id_check]        || true
      @delivery_method = attributes[:delivery_method] || :email
      @routing_order   = attributes[:routing_order]   || 1
      @recipient_type  = attributes[:recipient_type]  || :signer
      @identifier      = attributes[:identifier]      || generate_identifier()

      self.validate! if run_validations
    end

    def self.reload!(envelope)
      recipient_array = []
      connection = Hancock::DocuSignAdapter.new(envelope.identifier)
      recipients = connection.recipients

      Hancock::Recipient::RECIPIENT_TYPES.each do |type|
        recipients[docusign_recipient_type(type)].each do |r|
          recipient_array << new({ name: r["name"], identifier: r["recipientId"], recipient_type: type,
                                            email: r["email"], routing_order: r["routingOrder"].to_i})
        end
      end
      recipient_array
    end
  end
end
