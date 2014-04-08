module Hancock
  class Envelope < Hancock::Base
    
    BOUNDARY = 'AAA'
    ATTRIBUTES = [:identifier, :status, :documents, :signature_requests, :email]

    ATTRIBUTES.each do |attr|
      self.send(:attr_accessor, attr)
    end

    def self.find(envelope_id)
      uri = build_uri("/accounts/#{Hancock.account_id}/envelopes/#{envelope_id}")
      content_headers = { 'Content-Type' => 'application/json' }

      response = send_get_request(uri, get_headers(content_headers))
      envelope_params = JSON.parse(response.body)

      envelope = self.new(status: envelope_params["status"], identifier: envelope_params["envelopeId"])
      envelope
    end

    def initialize(attributes = {})
      ATTRIBUTES.each do |attr|
        self.send("#{attr}=", attributes[attr])
      end

      @documents = [] unless attributes[:documents]
      @signature_requests = [] unless attributes[:signature_requests]
      @email = {} unless attributes[:email]
    end

    def add_document(document) 
      @documents << document
    end

    def add_signature_request(recipient, document, tabs)
      @signature_requests << {
        recipient: recipient,
        document: document,
        tabs: tabs
      } 
    end

    def send!
      send_envelope("sent")      
    end

    def save
      send_envelope("created")
    end

    def documents
      if identifier
        @documents = []
        response = get_response("/accounts/#{Hancock.account_id}/envelopes/#{identifier}/documents").body
        doc_array = JSON.parse(response)["envelopeDocuments"]

        doc_array.each do |doc|
          document = Hancock::Document.new(identifier: doc["documentId"], name: doc["name"])
          add_document(document) 
        end
      end
      @documents
    end

    def recipients
      if identifier
        response = get_response("/accounts/#{Hancock.account_id}/envelopes/#{identifier}/recipients").body
        signers_array = JSON.parse(response)["signers"]

        recipients_array = []

        signers_array.each do |signer|
          recipient = Hancock::Recipient.new(name: signer["name"], identifier: signer["recipientId"], 
                                            email: signer["email"], routing_order: signer["routingOrder"].to_i)
          recipients_array << recipient
        end
        recipients_array
      end
    end

    def reload!
      if identifier
        response = JSON.parse(get_response("/accounts/#{Hancock.account_id}/envelopes/#{identifier}").body)
        @status = response["status"]
        @email = {subject: response["emailSubject"], blurb: response["emailBlurb"]}
        @documents = documents
      end
      self
    end

    def status
      if identifier
        response = get_response("/accounts/#{Hancock.account_id}/envelopes/#{identifier}")
        @status = JSON.parse(response.body)["status"]
      end
      @status
    end

    # #
    # ##########################################################################
    # #
    # # for test request from console
    # def self.test
    #   envelope = Hancock::Envelope.new
    #   doc1 = File.open("test.pdf")
    #   document1 = Hancock::Document.new(file: doc1, name: "test", extension: "pdf", identifier: "123")
    #   recipient1 = Hancock::Recipient.new(name: "Owner", email: "kolya.bokhonko@gmail.com", routing_order: 1)
    #   envelope.add_document(document1)
    #   tab1 = Hancock::Tab.new(type: "sign_here", label: "Vas", coordinates: [2, 100], page_number: 1)
    #   envelope.add_signature_request(recipient1, document1, [tab1])
    #   envelope.save
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
    #
    
    private
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
          recipients: get_recipients_for_request(@signature_requests)
        }
      end      
  end
end