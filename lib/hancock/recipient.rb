require_relative 'recipient/docusign_recipient'
require_relative 'recipient/recreator'

module Hancock
  class Recipient < Hancock::Base
    SigningUrlError = Class.new(StandardError)

    TYPES = [:agent, :carbon_copy, :certified_delivery, :editor, :in_person_signer, :intermediary, :signer]

    attr_accessor :email,
      :id_check,
      :identifier,
      :name,
      :recipient_type,
      :routing_order

    attr_reader :client_user_id,
      :envelope_identifier,
      :docusign_recipient,
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
      @embedded_start_url  = attributes.fetch(:embedded_start_url, 'SIGN_AT_DOCUSIGN')
    end

    def self.fetch_for_envelope(envelope_identifier)
      response = DocusignRecipient.all_for(envelope_identifier).parsed_response

      TYPES.map do |type|
        response[docusign_recipient_type(type)].map do |envelope_recipient|
          new(:name => envelope_recipient['name'],
              :email => envelope_recipient['email'],
              :id_check => nil,
              :routing_order => envelope_recipient['routingOrder'].to_i,
              :recipient_type => type,
              :identifier => envelope_recipient['recipientId'].to_i,
              :envelope_identifier => envelope_identifier)
        end
      end.flatten
    end

    # DocuSign currently provides no way to resend an envelope for a
    # recipient with embedded signing enabled. So we use a workaround.
    def resend_email
      recreate_recipient_and_tabs
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
      # FIXME: We need to check the status somehow
      # fail unless status == :sent

      unless access_method == :embedded
        fail SigningUrlError, 'This recipient is not setup for in-person signing'
      end

      docusign_recipient.signing_url(return_url).parsed_response['url']
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

    private

    def recreate_recipient_and_tabs
      Recipient::Recreator.new(docusign_recipient).recreate_with_tabs
    end

    def id_check_configuration_name
      id_check ? 'ID Check $' : nil
    end

    def docusign_recipient
      @docusign_recipient ||= DocusignRecipient.new(self)
    end

    def access_method
      client_user_id.nil? ? :remote : :embedded
    end

    #
    # format recipient type(symbol) for DocuSign
    #
    def self.docusign_recipient_type(type)
      type.to_s.camelize(:lower).pluralize
    end
  end
end
