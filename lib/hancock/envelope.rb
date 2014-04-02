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
        }.to_json
      }
    end

    def add_document document 
      @documents << { documentId: document.identifier, name: document.name }
    end

    def add_signature_request recepient, document, tabs 
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
    end

    def send!
      post_body = {
          emailBlurb:   "emailBlurb",
          emailSubject: "emailSubject",
          status: "sent",
          documents: @documents,
          recipients: @recipients,
        }.to_json

      uri = build_uri("/accounts/#{Hancock.account_id}/envelopes")
      http = initialize_http(uri)

      headers = {
        'Content-Type'              => "multipart/form-data",
        'Accept'                    => 'application/json',
        'Content-Length'            => "#{@post_body.length}"
      }
      headers.merge!(@docusign_headers)

      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.body = post_body
      response = http.request(request)
      response.body
    end

    def build_uri(url)
      URI.parse("#{Hancock.endpoint}/#{Hancock.api_version}#{url}")
    end

    #
    #for testing connection
    #
    def get_login_information(options={})
      uri = build_uri('/login_information')
      
      http = initialize_http(uri)

      request = Net::HTTP::Get.new(uri.request_uri, @docusign_headers)
      response = http.request(request)
      response
    end

    private

      def initialize_http uri
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http
      end

      def get_tabs(tabs, type, document_id)
        tab_array = []

        tabs_by_type = tabs.select{ |h| h.values_at('type', type) }

        tabs_by_type.map do |tab|
          tab_hash = {}

          if tab.is_a? Hancock::AnchoredTab
            tab_hash[:anchorString] = tab[:anchor_string]
            tab_hash[:anchorXOffset] = tab[:offset][0] || '0'
            tab_hash[:anchorYOffset]  = tab[:offset][1 || '0'
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

          tab_array << tab_hash
        end
        tab_array
      end
  end
end