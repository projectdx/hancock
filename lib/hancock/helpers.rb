require 'httparty'

module Hancock
  module Helpers

    def send_request(type, url, headers, body = nil)
      uri = build_uri(url)
      http = initialize_http(uri)
      options = { :headers => headers}
      options[:body] = body if body
      HTTParty.send(type, uri, options)
    end
    #
    # send post request to set uri with post body and headers
    #
    def send_post_request(url, body_post, headers)
      send_request(:post, url, headers, body_post)
    end

    #
    # send put request to set url
    #
    def send_put_request(url, body_post, headers)
      send_request(:put, url, headers, body_post)
    end

    #
    # send get request to set url
    #
    def send_get_request(url)
      send_request(:get, url, get_headers({ 'Content-Type' => 'application/json' }))
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
        'Authorization' => "bearer #{Hancock.oauth_token}"
      }

      default.merge!(user_defined_headers) if user_defined_headers
    end

    #
    # get list of recipients from signature requests
    #
    def get_recipients_for_request(signature_requests)      
      recipients = { }

      Hancock::Recipient::Types.each do |type|
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