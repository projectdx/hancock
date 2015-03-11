module Hancock
  class Recipient < Hancock::Base
    class DocusignRecipient
      attr_reader :recipient

      extend Forwardable

      def_delegators :@recipient,
        :envelope_identifier,
        :identifier,
        :recipient_type,
        :routing_order,
        :to_hash

      def initialize(recipient)
        fail 'recipient requires an envelope_identifier' unless recipient.envelope_identifier
        fail 'recipient requires an identifier' unless recipient.identifier

        @recipient = recipient
      end

      def self.all_for(envelope_identifier)
        Hancock::Request.send_get_request(
          "/envelopes/#{envelope_identifier}/recipients")
      end

      def self.find(envelope_identifier, identifier)
        Hancock::Request.send_get_request(
          "/envelopes/#{envelope_identifier}/recipients/#{identifier}")
      end

      def tabs
        Hancock::Request.send_get_request(
          "/envelopes/#{envelope_identifier}/recipients/#{identifier}/tabs")
      end

      def create_tabs(tabs)
        Hancock::Request.send_post_request(
          "/envelopes/#{envelope_identifier}/recipients/#{identifier}/tabs",
          tabs.to_json
        )
      end

      def delete
        json_body = { :signers => [{ :recipientId => identifier }] }.to_json

        Hancock::Request.send_delete_request(
          "/envelopes/#{envelope_identifier}/recipients",
          json_body
        )
      end

      def create
        Hancock::Request.send_post_request(
          "/envelopes/#{envelope_identifier}/recipients",
          { docusign_recipient_type => [to_hash] }.to_json
        )
      end

      def update
        Hancock::Request.send_put_request(
          "/envelopes/#{envelope_identifier}/recipients",
          { :signers => [to_hash] }.to_json
        )
      end

      def signing_url(return_url)
        json_body = {
          :authenticationMethod => 'none',
          :email => recipient.email,
          :returnUrl => return_url,
          :userName => recipient.name,
          :clientUserId => recipient.client_user_id
        }.to_json
        Hancock::Request.send_post_request(
          "/envelopes/#{envelope_identifier}/views/recipient",
          json_body
        )
      end

      #
      # format recipient type(symbol) for DocuSign
      #
      def self.docusign_recipient_type(recipient_type)
        recipient_type.to_s.camelize(:lower).pluralize
      end
      def docusign_recipient_type
        recipient_type.to_s.camelize(:lower).pluralize
      end
    end
  end
end
