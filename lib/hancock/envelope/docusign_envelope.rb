module Hancock
  class Envelope < Hancock::Base
    class DocusignEnvelope
      attr_reader :envelope

      extend Forwardable
      def_delegators :@envelope, :identifier

      def initialize(envelope)
        fail 'envelope requires an identifier' unless envelope.identifier

        @envelope = envelope
      end

      def viewing_url
        Hancock::Request.send_post_request("/envelopes/#{identifier}/views/sender", '{}')
      end

      def get_lock
        Hancock::Request.send_get_request("/envelopes/#{identifier}/lock")
      end

      def resend_email
        Hancock::Request.send_put_request("/envelopes/#{identifier}/recipients?resend_envelope=true", "{}")
      end
    end
  end
end
