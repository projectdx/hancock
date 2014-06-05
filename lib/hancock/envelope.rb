module Hancock
  class Envelope < Hancock::Base

    attr_accessor :identifier, :status, :documents, :signature_requests, :email, :recipients

    def self.find(envelope_id)
      connection = Hancock::DocuSignAdapter.new(envelope_id)
      envelope_params = connection.envelope

      envelope = self.new(status: envelope_params["status"], identifier: envelope_params["envelopeId"])
      envelope.reload!
    end

    #
    # initializing of new instance of Envelope - can be without attributes
    #
    def initialize(attributes = {})
      @identifier = attributes[:identifier]
      @status = attributes[:status]
      @documents = attributes[:documents] || []
      @recipients = attributes[:recipients] || []
      @signature_requests = attributes[:signature_requests] || []
      @email = attributes[:email] || {}
    end

    def add_signature_request(attributes = {})
      @signature_requests << {
        recipient: attributes[:recipient],
        document: attributes[:document],
        tabs: attributes[:tabs]
      }

      @recipients << attributes[:recipient] 
    end

    #
    # sends to DocuSign and sets status to "sent," which sends email
    #
    def send!
      send_envelope("sent")      
    end

    #
    # sends to DocuSign but sets status to "created," which makes it a draft
    #
    def save
      send_envelope("created")
    end

    #
    # reload information about envelope from DocuSign
    #
    def reload!
      if identifier
        response = Hancock::DocuSignAdapter.new(identifier).envelope

        @status = response["status"]
        @email = {subject: response["emailSubject"], blurb: response["emailBlurb"]}
        @documents = Document.fetch_for_envelope(self)
        @recipients = Recipient.fetch_for_envelope(self)
      end
      self
    end

    def signature_requests_for_params
      recipients_by_type = {}

      recipients = signature_requests.inject({}) { |hsh, request|
        recipient = request[:recipient]
        recipient_type = docusign_recipient_type(recipient.recipient_type)
        hsh[recipient_type] ||= []
        entry = hsh[recipient_type].detect { |r|
          r[:recipientId] == recipient.identifier
        }
        unless entry
          entry = { :email => recipient.email, :name => recipient.name, :recipientId => recipient.identifier }
          hsh[recipient_type] << entry
        end
        entry[:tabs] ||= {}
        request[:tabs].each do |tab|
          type = "#{tab.type}_tabs".camelize(:lower).to_sym
          entry[:tabs][type] ||= []
          entry[:tabs][type] << tab.to_h.merge(:documentId => request[:document].identifier)
        end
        hsh
      }
    end

    def form_post_body(status)
      post_body =  "\r\n--#{Hancock.boundary}\r\n"
      post_body << "Content-Type: application/json\r\n"
      post_body << "Content-Disposition: form-data\r\n\r\n"
      post_body << get_post_params(status).to_json
      post_body << "\r\n--#{Hancock.boundary}\r\n"
      post_body << documents_for_body.join("\r\n--#{Hancock.boundary}\r\n")
      post_body << "\r\n--#{Hancock.boundary}--\r\n"
    end

    def documents_for_params
      documents.map(&:to_request)
    end

    def documents_for_body
      documents.map(&:multipart_form_part)
    end

    private
      def send_envelope(status)
        content_headers = { 
          'Content-Type' => "multipart/form-data; boundary=#{Hancock.boundary}" 
        }

        response = send_post_request("/accounts/#{Hancock.account_id}/envelopes", form_post_body(status), get_headers(content_headers))

        if response.success?
          self.identifier = response["envelopeId"]
          reload!
        else
          message = response["message"]
          raise Hancock::DocusignError.new(message) 
        end
      end

      def get_post_params(status)
        { 
          emailBlurb: email[:blurb] || Hancock.email_template[:blurb],
          emailSubject: email[:subject]|| Hancock.email_template[:subject],
          status: "#{status}",
          documents: documents_for_params,
          recipients: signature_requests_for_params,
        }
      end      
  end
end