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

    def add_document(document) 
      @documents << document
    end

    def add_signature_request(attributes = {})
      @signature_requests << {
        recipient: attributes[:recipient],
        document: attributes[:document],
        tabs: attributes[:tabs]
      }

      @recipients << attributes[:recipients] 
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
        @documents = Document.reload!(self)
        @recipients = Recipient.reload!(self)
      end
      self
    end

    # #
    # ##########################################################################
    # #
    # # for test request from console
    # def self.test
    #   envelope = Hancock::Envelope.new
    #   doc1 = File.open("test.pdf")
    #   document1 = Hancock::Document.new({file: doc1, name: "test", extension: "pdf", identifier: "123"})
    #   recipient1 = Hancock::Recipient.new({identifier: 222, name: "Owner", email: "kolya.bokhonko@gmail.com", routing_order: 1, delivery_method: :email, recipient_type: :signer})
    #   envelope.add_document(document1)
    #   tab1 = Hancock::Tab.new(type: "sign_here", label: "Vas", coordinates: [2, 100], page_number: 1)
    #   envelope.add_signature_request(recipient: recipient1, document: document1, tabs: [tab1])
    #   envelope.save
    # end

    # #
    # # This one for testing API's callbacks
    # #
    # def self.callback_test
    #   envelope = Hancock::Envelope.new
    #   doc1 = File.open("test.pdf")
    #   document1 = Hancock::Document.new({file: doc1, name: "test", extension: "pdf", identifier: "123"})
    #   recipient1 = Hancock::Recipient.new({identifier: 222, name: "Owner", email: "kolya.bokhonko@gmail.com", routing_order: 1, delivery_method: :email, recipient_type: :signer})
    #   envelope.add_document(document1)
    #   tab1 = Hancock::Tab.new(type: "sign_here", label: "Vas", coordinates: [2, 100], page_number: 1)
    #   envelope.add_signature_request(recipient: recipient1, document: document1, tabs: [tab1])
    #   envelope.send!
    # end
    # # One call does it all
    # def self.test_init
    #   doc1 = File.open("test.pdf")
    #   document1 = Hancock::Document.new({file: doc1, name: "test", extension: "pdf", identifier: "123"})
    #   recipient1 = Hancock::Recipient.new({identifier: 222, name: "Owner", email: "kolya.bokhonko@gmail.com", routing_order: 1, delivery_method: :email, recipient_type: :signer})
    #   tab1 = Hancock::Tab.new(type: "sign_here", label: "Vas", coordinates: [2, 100], page_number: 1)
      
    #   envelope = Hancock::Envelope.new({
    #     documents: [document1],
    #     signature_requests: [
    #       {
    #         recipient: recipient1,
    #         document: document1,
    #         tabs: [tab1],
    #       },
    #     ],
    #     email: {
    #       subject: 'Hello there',
    #       blurb: 'Please sign this!'
    #     }
    #   })

    #   envelope.save
    # end
    # #
    # ##########################################################################
    # #
    
    private
      def send_envelope(status)
        uri = build_uri("/accounts/#{Hancock.account_id}/envelopes")
        content_headers = { 
          'Content-Type' => "multipart/form-data, boundary=#{Hancock.boundary}" 
        }

        response = send_post_request(uri, form_post_body(status), get_headers(content_headers))
        envelope_params = JSON.parse(response.body)

        if response.is_a? Net::HTTPSuccess
          self.identifier = envelope_params["envelopeId"]
          reload!
        else
          message = envelope_params["message"]
          raise Hancock::DocusignError.new(message) 
        end
      end

      def get_post_params(status)
        { 
          emailBlurb: @email[:blurb] || Hancock.email_template[:blurb],
          emailSubject: @email[:subject]|| Hancock.email_template[:subject],
          status: "#{status}",
          documents: @documents.map{|d| d.to_request},
          recipients: get_recipients_for_request(@signature_requests),
        }
      end      
  end
end