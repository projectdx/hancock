module Hancock
  class Envelope
    
    def initialize
      @documents = []
      @recipients = {
          signers: []
        }

      @docusign_headers = {
        'X-DocuSign-Authentication' => {
          'Username' => Hancock.username,
          'Password' => Hancock.password,
          'IntegratorKey' => Hancock.integrator_key
        }
      }
    end

    def add_document(document) 
      @documents << { documentId: document.identifier, name: document.name }
    end

    def add_signature_request(recepient, document, tabs) 
      doc_signer = {
        email: recepient[:email],
        name: recepient[:name],
        recipientId:  recepient[:id]
      }

      doc_signer[:tabs] = {
        #here we can add more types
        initialHereTabs:      get_tabs( tabs, "initial_here", document.identifier),
        signHereTabs:         get_tabs( tabs, "sign_here" , document.identifier),
      }

      @recipients[:signers] << doc_signer
    end

    #################need refactor
    def send!
      uri = build_uri("/accounts/#{Hancock.account_id}/envelopes")
      body_post = get_post_body("sent")     
      
      content_headers = { 'Content-Type' => 'multipart/form-data', 'Content-Length' => "#{body_post.length}" }

      post_request(uri, body_post, get_headers(content_headers))
    end

    def save
      uri = build_uri("/accounts/#{Hancock.account_id}/envelopes")
      body_post = get_post_body("created")     

      content_headers = { 'Content-Type' => 'multipart/form-data', 'Content-Length' => "#{body_post.length}" }

      post_request(uri, body_post, get_headers(content_headers))
    end
    #################################

    def documents
      uri = build_uri("/accounts/#{Hancock.account_id}/envelopes/#{envelope_id}/documents")
      content_headers = { 'Content-Type' => 'application/json' }

      get_request(uri, get_headers(content_headers))
    end

    def recipients
      uri = build_uri("/accounts/#{Hancock.account_id}/envelopes/#{envelope_id}/recipients")
      content_headers = { 'Content-Type' => 'application/json' }

      get_request(uri, get_headers(content_headers))
    end

    def status
      #
    end

    private
      def post_request(uri, body_post, headers)
        http = initialize_http(uri)

        request = Net::HTTP::Post.new(uri.request_uri, headers)
        request.body = body_post
        http.request(request) # return response
      end

      def get_request(uri, headers)
        http = initialize_http(uri)

        request = Net::HTTP::Get.new(uri.request_uri, headers)
        http.request(request) # return response
      end

      def build_uri(url)
        URI.parse("#{Hancock.endpoint}/#{Hancock.api_version}#{url}")
      end

      def get_post_body(status)
        { 
          emailBlurb:   "emailBlurb",
          emailSubject: "emailSubject",
          status: "#{status}",
          documents: @documents,
          recipients: @recipients,
        }
      end

      def get_headers(user_defined_headers={})
        default = {
          'Accept' => 'json' 
        }

        default.merge!(user_defined_headers) if user_defined_headers
        @docusign_headers.merge(default)
      end

      def initialize_http(uri)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http
      end

      def get_tabs(tabs, type, document_id)
        tabs_by_type(tabs, type).each_with_object([]) do |tab, tab_array|
          tab_array << generate_tab(tab, document_id)
        end
      end

      def tabs_by_type(tabs, type)
        tabs.select{ |h| h.values_at('type', type) }
      end

      def generate_tab(tab, document_id)
        tab_hash = {}

        if tab.is_a? Hancock::AnchoredTab
          tab_hash[:anchorString] = tab[:anchor_string]
          tab_hash[:anchorXOffset] = tab[:offset][0] || '0'
          tab_hash[:anchorYOffset]  = tab[:offset][1] || '0'
        else
          tab_hash[:xPosition]  = tab[:coordinates][0] || '0'
          tab_hash[:yPosition]  = tab[:coordinates][1] || '0'          
        end

        tab_hash[:documentId] = document_id || '0'
        tab_hash[:scaleValue] = tab[:scaleValue] || 1

        tab_hash[:name]       = tab[:name] if tab[:name]
        tab_hash[:tabLabel]   = tab[:label] || 'Signature 1'
        tab_hash[:width]      = tab[:width] if tab[:width]
        tab_hash[:height]     = tab[:height] if tab[:width]
        tab_hash[:value]      = tab[:value] if tab[:value]

        tab_hash
      end
  end
end