module Hancock
  module Helpers
    extend ActiveSupport::Concern

    def send_post_request(uri, body_post, headers)
      http = initialize_http(uri)

      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.body = body_post
      http.request(request) # return response
    end

    def send_get_request(uri, headers)
      http = initialize_http(uri)

      p http

      request = Net::HTTP::Get.new(uri.request_uri, headers)
      http.request(request) # return response
    end

    def get_response(url)
      uri = build_uri(url)
      content_headers = { 'Content-Type' => 'application/json' }

      send_get_request(uri, get_headers(content_headers))
    end

    def build_uri(url)
      URI.parse("#{Hancock.endpoint}/#{Hancock.api_version}#{url}")
    end

    def initialize_http(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http
    end

    def get_headers(user_defined_headers={})
      default = {
        'Accept' => 'json',
        'X-DocuSign-Authentication' => {
          'Username' => Hancock.username,
          'Password' => Hancock.password,
          'IntegratorKey' => Hancock.integrator_key
        }.to_json 
      }

      default.merge!(user_defined_headers) if user_defined_headers
    end

    def get_recipients_for_request(signature_requests)      
      recipients = { }

      Hancock::Recipient::RECIPIENT_TYPES.each do |type|
        recipients[docusign_recipient_type(type)] = []
      end

      signature_requests.each do |signature|
        doc_signer = {
          email: signature[:recipient].email,
          name: signature[:recipient].name,
          recipientId:  signature[:recipient].identifier
        }

        doc_signer[:tabs] = {
          #here we can add more types
          initialHereTabs: get_tabs( signature[:tabs], "initial_here", signature[:document].identifier),
          signHereTabs:    get_tabs( signature[:tabs], "sign_here" , signature[:document].identifier),
        }

        recipients[docusign_recipient_type(signature[:recipient].recipient_type)] << doc_signer
      end
      recipients
    end

    def docusign_recipient_type type
      type.to_s.camelize(:lower).pluralize
    end

    def get_event_notification
      {
        url: Hancock.event_notification[:url],
        loggingEnabled: Hancock.event_notification[:logging_enabled],
        includeDocuments: Hancock.event_notification[:include_documents],
        useSoapInterface: "false",
        # @todo move out a definition of following events
        envelopeEvents: [
            {envelopeEventStatusCode: "Delivered", includeDocuments: "true"},
            {envelopeEventStatusCode: "Sent", includeDocuments: "true"},
            {envelopeEventStatusCode: "Completed", includeDocuments: "true"}
        ],
        recipientEvents: [
            {recipientEventStatusCode: "delivered", includeDocuments: "true"},
            {recipientEventStatusCode: "sent", includeDocuments: "true"},
            {recipientEventStatusCode: "completed", includeDocuments: "true"},
        ]
      }

    end

    def get_content_type_for format, document={}
      case format
      when :json
        "Content-Type: application/json\r\n"\
        "Content-Disposition: form-data\r\n\r\n"
      when :pdf
        "Content-Type: application/pdf\r\n"\
        "Content-Disposition: file; filename=#{document.name}; documentid=#{document.identifier}\r\n\r\n"
      when :docx
        "Content-Type: application/vnd.openxmlformats-officedocument.wordprocessingml.document\r\n"\
        "Content-Disposition: file; filename=#{document.name}; documentid=#{document.identifier}\r\n\r\n"  
      end
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