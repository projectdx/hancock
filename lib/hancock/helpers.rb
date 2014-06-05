module Hancock
  module Helpers

    #
    # send post request to set uri with post body and headers
    #
    def send_post_request(url, body_post, headers)
      uri = build_uri(url)
      http = initialize_http(uri)

      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.body = body_post
      http.request(request) # return response
    end

    #
    # send put request to set url
    #
    def send_put_request(url, body_post, headers)
      uri = build_uri(url)
      http = initialize_http(uri)

      request = Net::HTTP::Put.new(uri.request_uri, headers)
      request.body = body_post
      http.request(request) # return response
    end

    #
    # send get request to set url
    #
    def send_get_request(url)
      uri = build_uri(url)
      http = initialize_http(uri)
      content_headers = { 'Content-Type' => 'application/json' }

      request = Net::HTTP::Get.new(uri.request_uri, get_headers(content_headers))
      http.request(request) # return response
    end

    #
    # generate common uri to docusign service
    #
    def build_uri(url)
      URI.parse("#{Hancock.endpoint}/#{Hancock.api_version}#{url}")
    end

    #
    # initialize instance of Net::HTTP(An HTTP client API)
    #
    def initialize_http(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http
    end

    #
    # get headers for requests with authentication parameters
    #
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

    #
    # get list of recipients from signature requests
    #
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

    #
    # format recipient type(symbol) for DocuSign
    #
    def docusign_recipient_type(type)
      type.to_s.camelize(:lower).pluralize
    end

    def get_content_type_for(format, document = {})
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
      tab.to_h.merge({ :documentId => (document_id || '0')})
    end
  end
end