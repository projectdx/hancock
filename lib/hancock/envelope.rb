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

      response = get_request(uri, get_headers(content_headers))
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

      @files_array = []
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
      uri = build_uri("/accounts/#{Hancock.account_id}/envelopes")
      content_headers = { 
        'Content-Type' => "multipart/form-data, boundary=#{BOUNDARY}" 
      }

      post_request(uri, form_post_body("sent"), get_headers(content_headers))
    end

    def save
      uri = build_uri("/accounts/#{Hancock.account_id}/envelopes")
      content_headers = { 
        'Content-Type' => "multipart/form-data, boundary=#{BOUNDARY}" 
      }

      response = post_request(uri, form_post_body("created"), get_headers(content_headers))
      envelope_params = JSON.parse(response.body)

      self.status = envelope_params["status"]
      self.identifier = envelope_params["envelopeId"]
      self
    end

    def documents
      uri = build_uri("/accounts/#{Hancock.account_id}/envelopes/#{identifier}/documents")
      content_headers = { 'Content-Type' => 'application/json' }

      get_request(uri, get_headers(content_headers))
    end

    def recipients
      uri = build_uri("/accounts/#{Hancock.account_id}/envelopes/#{identifier}/recipients")
      content_headers = { 'Content-Type' => 'application/json' }

      get_request(uri, get_headers(content_headers))
    end

    def status
      uri = build_uri("/accounts/#{Hancock.account_id}/envelopes/#{identifier}")
      content_headers = { 'Content-Type' => 'application/json' }

      response = get_request(uri, get_headers(content_headers))
      JSON.parse(response.body)["status"]
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
    # #

    private
      def form_post_body(status)     
        post_body =  "\r\n--#{BOUNDARY}\r\n"
        post_body << get_content_type_for(:json)
        post_body << get_post_params(status).to_json
        post_body << "\r\n--#{BOUNDARY}\r\n"

        @documents.each do |f|
          post_body << get_content_type_for(:pdf, f)
          post_body << IO.read(f.file) 
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

      def get_tabs(tabs, type, document_id)
        tabs_by_type(tabs, type).each_with_object([]) do |tab, tab_array|
          tab_array << generate_tab(tab, document_id)
        end
      end

      def tabs_by_type(tabs, type)
        tabs.select{ |h| h.type == type }
      end

      def generate_tab(tab, document_id)
        tab_hash = {}

        if tab.is_a? Hancock::AnchoredTab
          tab_hash[:anchorString]  = tab.anchor_text
          tab_hash[:anchorXOffset] = tab.offset[0]
          tab_hash[:anchorYOffset] = tab.offset[1]
          tab_hash[:IgnoreIfNotPresent] = 1
        else
          tab_hash[:tabLabel]   = tab.label
          tab_hash[:xPosition]  = tab.coordinates[0]
          tab_hash[:yPosition]  = tab.coordinates[1]
        end

        tab_hash[:documentId] = document_id || '0'
        tab_hash[:pageNumber] = tab.page_number
        tab_hash
      end
  end
end