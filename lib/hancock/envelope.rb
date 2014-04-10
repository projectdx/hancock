module Hancock
  class Envelope < Hancock::Base
    
    BOUNDARY = 'AAA'

    attr_accessor :identifier, :status, :documents, :signature_requests, :email, :recipients

    def self.find(envelope_id)
      uri = build_uri("/accounts/#{Hancock.account_id}/envelopes/#{envelope_id}")
      content_headers = { 'Content-Type' => 'application/json' }

      response = send_get_request(uri, get_headers(content_headers))
      envelope_params = JSON.parse(response.body)

      envelope = self.new(status: envelope_params["status"], identifier: envelope_params["envelopeId"])
      envelope.reload!
    end

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

    def send!
      send_envelope("sent")      
    end

    def save
      send_envelope("created")
    end

    def reload!
      if identifier
        response = JSON.parse(get_response("/accounts/#{Hancock.account_id}/envelopes/#{identifier}").body)
        @status = response["status"]
        @email = {subject: response["emailSubject"], blurb: response["emailBlurb"]}
        get_documents
        get_recipients
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
    #   document1 = Hancock::Document.new(file: doc1, name: "test", extension: "pdf", identifier: "123")
    #   recipient1 = Hancock::Recipient.new(identifier: 222, name: "Owner", email: "kolya.bokhonko@gmail.com", routing_order: 1, delivery_method: :email)
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
    #   document1 = Hancock::Document.new(file: doc1, name: "test", extension: "pdf", identifier: "123")
    #   recipient1 = Hancock::Recipient.new(name: "Owner", email: "kolya.bokhonko@gmail.com", routing_order: 1, delivery_method: :email)
    #   envelope.add_document(document1)
    #   tab1 = Hancock::Tab.new(type: "sign_here", label: "Vas", coordinates: [2, 100], page_number: 1)
    #   envelope.add_signature_request(recipient: recipient1, document: document1, tabs: [tab1])
    #   envelope.send!
    # end
    # # One call does it all
    # def self.test_init
    #   doc1 = File.open("test.pdf")
    #   document1 = Hancock::Document.new(file: doc1, name: "test", extension: "pdf", identifier: "123")
    #   recipient1 = Hancock::Recipient.new(name: "Owner", email: "kolya.bokhonko@gmail.com", routing_order: 1)
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
      def get_documents
        if identifier
          @documents = []
          response = get_response("/accounts/#{Hancock.account_id}/envelopes/#{identifier}/documents").body
          doc_array = JSON.parse(response)["envelopeDocuments"]

          doc_array.each do |doc|
            response_data = get_response("/accounts/#{Hancock.account_id}/envelopes/#{identifier}/documents/#{doc["documentId"]}").body

            document = Hancock::Document.new(identifier: doc["documentId"], name: doc["name"], extension: "pdf", data: response_data)
            
            add_document(document) 
          end
        end
        @documents
      end

      def get_recipients
        if identifier
          response = get_response("/accounts/#{Hancock.account_id}/envelopes/#{identifier}/recipients").body
          signers_array = JSON.parse(response)["signers"]

          @recipients = []

          signers_array.each do |signer|
            recipient = Hancock::Recipient.new({ name: signer["name"], identifier: signer["recipientId"], 
                                              email: signer["email"], routing_order: signer["routingOrder"].to_i}, false)
            @recipients << recipient
          end
          @recipients
        end
      end

      def send_envelope(status)
        uri = build_uri("/accounts/#{Hancock.account_id}/envelopes")
        content_headers = { 
          'Content-Type' => "multipart/form-data, boundary=#{BOUNDARY}" 
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

      def form_post_body(status)     
        post_body =  "\r\n--#{BOUNDARY}\r\n"
        post_body << get_content_type_for(:json)
        post_body << get_post_params(status).to_json
        post_body << "\r\n--#{BOUNDARY}\r\n"

        @documents.each do |doc|
          post_body << get_content_type_for(:pdf, doc)
          post_body << doc.data_for_request
          post_body << "\r\n"
        end

        post_body << "\r\n--#{BOUNDARY}--\r\n"
      end

      def get_post_params(status)
        { 
          emailBlurb: @email[:blurb] || Hancock.email_template[:blurb],
          emailSubject: @email[:subject]|| Hancock.email_template[:subject],
          status: "#{status}",
          documents: @documents.map{|d| d.to_request},
          recipients: get_recipients_for_request(@signature_requests),
          eventNotification: get_event_notification
        }
      end      
  end
end