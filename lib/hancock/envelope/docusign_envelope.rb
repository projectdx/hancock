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
        Hancock::Request.send_post_request("/envelopes/#{identifier}/views/sender")
      end
    end
  end
end
