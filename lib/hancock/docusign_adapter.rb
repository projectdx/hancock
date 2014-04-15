module Hancock
  class DocuSignAdapter < Hancock::Base
    attr_accessor :envelope_id
    def initialize(envelope_id=nil)
      @envelope_id = envelope_id
    end

    #
    # The response returns the current envelope status
    #
    def envelope
      JSON.parse(send_get_request("/accounts/#{Hancock.account_id}/envelopes/#{envelope_id}").body)
    end

    #
    # This retrieves the specified document from the envelope
    #
    def documents
      JSON.parse(send_get_request("/accounts/#{Hancock.account_id}/envelopes/#{envelope_id}/documents").body)["envelopeDocuments"]
    end

    #
    # This returns a list of documents associated with the specified envelope
    #
    def document(document_id)
      send_get_request("/accounts/#{Hancock.account_id}/envelopes/#{envelope_id}/documents/#{document_id}").body
    end

    #
    # This returns a list of recipients associated with the specified envelope
    #
    def recipients
      JSON.parse(send_get_request("/accounts/#{Hancock.account_id}/envelopes/#{envelope_id}/recipients").body)
    end
  end
end