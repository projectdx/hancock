module Hancock
  class Recipient < Hancock::Base
    class DocusignRecipient
      attr_reader :recipient

      extend Forwardable
      def_delegators :@recipient, :envelope_identifier, :identifier

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

      def create_tabs_from_json(tabs)
        Hancock::Request.send_post_request(
          "/envelopes/#{envelope_identifier}/recipients/#{identifier}/tabs",
          tabs
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
          { :signers => [to_hash] }.to_json
        )
      end

      def signing_url(return_url = nil)
        json_body = {
          :authenticationMethod => 'none',
          :email => recipient.email,
          :returnUrl => return_url,
          :userName => recipient.name,
          :clientUserId => recipient.client_user_id
        }.to_json
        Hancock::Request.send_post_request(
          "/envelopes/#{envelope_identifier}/views/recipient/signer",
          json_body
        )
      end

      private

      def to_hash
        {
          :clientUserId  => recipient.client_user_id,
          :email         => recipient.email,
          :idCheck       => recipient.id_check,
          :name          => recipient.name,
          :recipientId   => recipient.identifier,
          :routingOrder  => recipient.routing_order
        }
      end
    end
  end
end
