module Hancock
  class Recipient < Hancock::Base
    class Recreator
      attr_reader :docusign_recipient, :tabs

      def initialize(docusign_recipient)
        @docusign_recipient = docusign_recipient
        @tabs = JSON.parse(docusign_recipient.tabs.body)
      end

      # Deleting a recipient from an envelope can cause the envelope's status to
      # change. For example, if all other recipients had signed except this one,
      # the envelope status will change to 'complete' when this recipient is
      # deleted, and we will no longer be able to add the recipient back onto the
      # envelope. Hence the placeholder recipient.
      def recreate_with_tabs
        placeholder_docusign_recipient.create

        docusign_recipient.delete
        docusign_recipient.create
        docusign_recipient.create_tabs(tabs) unless tabs.empty?

        placeholder_docusign_recipient.delete
      end

      private

      def placeholder_docusign_recipient
        @placeholder_docusign_recipient ||= DocusignRecipient.new(placeholder_recipient)
      end

      def placeholder_recipient
        Recipient.new(
          :client_user_id      => placeholder_identifier, # Don't send an email
          :identifier          => placeholder_identifier,
          :email               => 'placeholder@example.com',
          :name                => 'Placeholder while recreating recipient',
          :envelope_identifier => docusign_recipient.envelope_identifier,
          :recipient_type      => docusign_recipient.recipient_type,
          :routing_order       => docusign_recipient.routing_order,
          :embedded_start_url  => nil # No really, don't send an email
        )
      end

      def placeholder_identifier
        @placeholder_identifier ||= SecureRandom.uuid
      end
    end
  end
end
