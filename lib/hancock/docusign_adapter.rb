module Hancock
  class DocuSignAdapter < Hancock::Base
    attr_accessor :envelope_id

    def initialize(envelope_id)
      @envelope_id = envelope_id
    end

    #
    # The response returns the current envelope info
    #
    def envelope
      Hancock::Request.send_get_request("/envelopes/#{envelope_id}")
    end

    #
    # This returns a list of documents associated with the specified envelope
    #
    def documents
      Hancock::Request.send_get_request("/envelopes/#{envelope_id}/documents")['envelopeDocuments']
    end

    #
    # This retrieves the specified document from the envelope
    #
    def document(document_id)
      Hancock::Request.send_get_request("/envelopes/#{envelope_id}/documents/#{document_id}")
    end

    #
    # This returns a list of recipients associated with the specified envelope
    #
    def recipients
      Hancock::Request.send_get_request("/envelopes/#{envelope_id}/recipients")
    end
  end
end
