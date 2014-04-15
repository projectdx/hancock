module Hancock
  class DocuSignAdapter < Hancock::Base
    attr_accessor :envelope_id
    def initialize(envelope_id=nil)
      @envelope_id = envelope_id
    end

    def envelope
      JSON.parse(send_get_request("/accounts/#{Hancock.account_id}/envelopes/#{envelope_id}").body)
    end

    def documents
      JSON.parse(send_get_request("/accounts/#{Hancock.account_id}/envelopes/#{envelope_id}/documents").body)["envelopeDocuments"]
    end

    def document(document_id)
      send_get_request("/accounts/#{Hancock.account_id}/envelopes/#{envelope_id}/documents/#{document_id}").body
    end

    def recipients
      JSON.parse(send_get_request("/accounts/#{Hancock.account_id}/envelopes/#{envelope_id}/recipients").body)
    end
  end
end