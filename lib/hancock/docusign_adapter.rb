module Hancock
  class DocuSignAdapter < Hancock::Base
    
    attr_accessor :envelope_id
    
    def initialize(envelope_id=nil)
      @envelope_id = envelope_id
    end

    #
    # The response returns the current envelope info
    #
    def envelope
      send_get_request("/accounts/#{Hancock.account_id}/envelopes/#{envelope_id}")
    end

    #
    # This returns a list of documents associated with the specified envelope
    #
    def documents
      send_get_request("/accounts/#{Hancock.account_id}/envelopes/#{envelope_id}/documents")["envelopeDocuments"]
    end

    #
    # This retrieves the specified document from the envelope
    #
    def document(document_id)
      send_get_request("/accounts/#{Hancock.account_id}/envelopes/#{envelope_id}/documents/#{document_id}").body
    end

    #
    # This returns a list of recipients associated with the specified envelope
    #
    def recipients
      send_get_request("/accounts/#{Hancock.account_id}/envelopes/#{envelope_id}/recipients")
    end
  end
end
