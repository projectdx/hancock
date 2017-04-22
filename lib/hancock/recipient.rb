require_relative 'recipient/docusign_recipient'
require_relative 'recipient/recreator'

module Hancock
  class Recipient < Hancock::Base
    SigningUrlError = Class.new(StandardError)
    ResendEmailError = Class.new(StandardError)
    CorrectionError = Class.new(StandardError)

    TYPES = [:agent, :carbon_copy, :certified_delivery, :editor, :in_person_signer, :intermediary, :signer]
    CORRECTABLE_STATUSES = ["created", "sent", "delivered"]

    attr_accessor :client_user_id,
      :email,
      :id_check,
      :identifier,
      :name,
      :recipient_type,
      :routing_order,
      :status

    attr_reader :envelope_identifier,
      :embedded_start_url

    validates :name, :email, :presence => true
    validates :id_check, :allow_nil => true, :inclusion => [true, false]
    validates :recipient_type, :inclusion => TYPES
    validates :email, :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }

    def initialize(attributes = {})
      @client_user_id      = attributes[:client_user_id]
      @email               = attributes[:email]
      @envelope_identifier = attributes[:envelope_identifier]
      @id_check            = attributes.fetch(:id_check, true)
      @identifier          = attributes[:identifier]
      @name                = attributes[:name]
      @routing_order       = attributes.fetch(:routing_order, 1)
      @recipient_type      = attributes.fetch(:recipient_type, :signer).to_sym
      @status              = attributes[:status]
      @embedded_start_url  = attributes.fetch(:embedded_start_url, 'SIGN_AT_DOCUSIGN')
    end

    def self.fetch_for_envelope(envelope_identifier)
      parsed_response = DocusignRecipient.all_for(envelope_identifier)

      TYPES.map do |type|
        parsed_response[docusign_recipient_type(type)].map do |envelope_recipient|
          new(
            :client_user_id => envelope_recipient['clientUserId'],
            :email => envelope_recipient['email'],
            :envelope_identifier => envelope_identifier,
            :id_check => envelope_recipient['requireIdLookup'],
            :identifier => envelope_recipient['recipientId'],
            :name => envelope_recipient['name'],
            :routing_order => envelope_recipient['routingOrder'].to_i,
            :recipient_type => type,
            :status => envelope_recipient['status']
          )
        end
      end.flatten
    end

    def update(params)
      unless in_correctable_state?
        raise CorrectionError.new(
          "Cannot update recipient, they have already signed or declined."
        )
      end

      docusign_recipient.update(
        params.merge(:recipientId => identifier, :resend_envelope => false)
      )

      params.each do |key, value|
        self.send(:"#{key}=", value)
      end
    end

    def resend_email
      raise_unless_email_resendable!

      if access_method == :remote
        handle_remote_envelope
      elsif access_method == :embedded
        handle_embedded_envelope
      end
    end

    # The DocuSign API provides no way to change the access method for an
    # existing recipient, so we must delete and recreate the recipient.
    def change_access_method_to(new_access_method)
      return true if new_access_method == access_method

      case new_access_method
      when :embedded
        @client_user_id = identifier
      when :remote
        @client_user_id = nil
      else
        fail ArgumentError, 'access_method must be :embedded or :remote'
      end

      recreate_recipient_and_tabs
    end

    def signing_url(return_url)
      unless access_method == :embedded
        fail SigningUrlError, 'This recipient is not setup for in-person signing'
      end

      docusign_recipient.signing_url(return_url)["url"]
    end

    def create(envelope_identifier: )
      @envelope_identifier = envelope_identifier
      docusign_recipient.create
    end

    def to_hash
      {
        :clientUserId    => client_user_id,
        :email           => email,
        :name            => name,
        :recipientId     => identifier,
        :routingOrder    => routing_order,
        :requireIdLookup => id_check,
        :idCheckConfigurationName => id_check_configuration_name,
        :embeddedRecipientStartURL => embedded_start_url
      }
    end

    def docusign_recipient
      @docusign_recipient ||= DocusignRecipient.new(self)
    end

    #
    # format recipient_type(symbol) for DocuSign
    #
    def self.docusign_recipient_type(recipient_type)
      DocusignRecipient.docusign_recipient_type(recipient_type)
    end

    def docusign_recipient_type
      DocusignRecipient.docusign_recipient_type(recipient_type)
    end

    private

    def handle_remote_envelope
      # The API seems to require more than just recipientId
      # NOTE: this uses `.update` as a means to resend email
      docusign_recipient.update(
        :recipientId => identifier,
        :name => name,
        :resend_envelope => true
      )
    end

    def handle_embedded_envelope
      envelope.resend_email
    end

    def raise_unless_email_resendable!
      raise ResendEmailError.new(
        "Cannot resend email, recipient has already signed or declined."
      ) unless in_correctable_state?

      raise ResendEmailError.new(
        "Cannot resend email, envelope is in a non-editable state."
      ) unless envelope.in_editable_state?

      raise ResendEmailError.new(
        "Cannot resend email, envelope is in a terminal state."
      ) if envelope.in_terminal_state?
    end

    def recreate_recipient_and_tabs
      Recipient::Recreator.new(docusign_recipient).recreate_with_tabs
    end

    def id_check_configuration_name
      id_check ? 'ID Check $' : nil
    end

    def access_method
      client_user_id.nil? ? :remote : :embedded
    end

    def in_correctable_state?
      self.status ||= fetch_status_from_docusign
      CORRECTABLE_STATUSES.include?( status.to_s.downcase )
    end

    def fetch_status_from_docusign
      self.class.fetch_for_envelope(envelope_identifier).select do |recipient|
        recipient.identifier == identifier
      end.first.try(:status)
    end

    def envelope
      @envelope ||= Envelope.find(envelope_identifier)
    end
  end
end
