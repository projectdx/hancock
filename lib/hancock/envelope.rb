require_relative 'envelope/docusign_envelope'

module Hancock
  class Envelope < Hancock::Base
    class InvalidEnvelopeError < StandardError; end
    class AlreadySavedError < StandardError; end
    class AlreadySentError < StandardError; end
    class NotSavedYet < StandardError; end

    attr_accessor :identifier, :status, :documents, :signature_requests, :email, :recipients, :status_changed_at

    validates :status, :presence => true
    validates :documents, :presence => true
    validates :recipients, :presence => true
    validate :document_validity, :if => :documents
    validate :recipient_validity, :if => :recipients

    def self.find(envelope_id)
      connection = Hancock::DocuSignAdapter.new(envelope_id)
      envelope_params = connection.envelope

      envelope = new(:status => envelope_params['status'], :identifier => envelope_params['envelopeId'])
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
      @reminder = attributes[:reminder]
      @expiration = attributes[:expiration]
    end

    def add_signature_request(attributes = {})
      @recipients << attributes[:recipient] unless @recipients.include? attributes[:recipient]
      @documents << attributes[:document] unless @documents.include? attributes[:document]

      @signature_requests << {
        :recipient => attributes[:recipient],
        :document => attributes[:document],
        :tabs => attributes[:tabs]
      }
    end

    #
    # sends to DocuSign and sets status to "sent," which sends email
    #
    def send!
      if identifier
        fail AlreadySentError if status == 'sent'
        change_status!('sent')
      else
        self.status = 'sent'
        send_envelope
      end
    end

    #
    # sends to DocuSign but sets status to "created," which makes it a draft
    #
    def save
      if identifier
        fail AlreadySavedError
      else
        self.status = 'created'
        send_envelope
      end
    end

    # TODO: Separate 1) assembly of envelope model, 2) sending via DocuSign,
    # and 3) fetching results from DocuSign post-send.  Ideally into completely
    # separate objects.
    def send_envelope
      fail InvalidEnvelopeError.new(errors.full_messages.join('; ')) unless valid?
      fail Hancock::ConfigurationMissing unless Hancock.configured?

      generate_document_ids!
      generate_recipient_ids!

      response = Hancock::Request.send_post_request("/envelopes", form_post_body, headers)

      self.identifier = response['envelopeId']
      reload!
    end

    #
    # tells DocuSign to change status of envelope (usually used to actually
    # send a draft envelope (status "created") by changing its status
    # to "sent")
    #
    def change_status!(status)
      fail NotSavedYet unless identifier
      put_body = { :status => status }.to_json
      response = Hancock::Request.send_put_request("/envelopes/#{identifier}", put_body)
      reload!
    end

    #
    # returns all summary (not content) documents for envelope
    #
    def summary_documents
      Document.fetch_all_for_envelope(self, :types => ['summary'])
    end

    #
    # reload information about envelope from DocuSign
    #
    def reload!
      if identifier
        response = Hancock::DocuSignAdapter.new(identifier).envelope

        @status = response['status']
        @status_changed_at = Time.parse(response['statusChangedDateTime'])
        @email = { :subject => response['emailSubject'], :blurb => response['emailBlurb'] }
        # FIXME: This shouldn't download all the docs every time. We need a better way!
        # @documents = Document.fetch_all_for_envelope(self)
        @recipients = Recipient.fetch_for_envelope(identifier)
      end
      self
    end

    def signature_requests_for_params
      # TODO: Refactor (and move to a new class with sending responsibility)
      recipients = signature_requests.reduce({}) do |hsh, request|
        recipient = request[:recipient]
        recipient_type = docusign_recipient_type(recipient.recipient_type)
        hsh[recipient_type] ||= []
        entry = hsh[recipient_type].find do |r|
          r[:recipientId] == recipient.identifier
        end
        unless entry
          entry = recipient.to_hash
          hsh[recipient_type] << entry
        end
        entry[:tabs] ||= {}
        request[:tabs].each do |tab|
          type = "#{tab.type}_tabs".camelize(:lower).to_sym
          entry[:tabs][type] ||= []
          entry[:tabs][type] << tab.to_h.merge(:documentId => request[:document].identifier)
        end
        hsh
      end
    end

    def notification_for_params
      {
        :useAccountDefaults => false,
        :reminders => reminder_for_params,
        :expirations => expiration_for_params
      }
    end

    def documents_for_params
      documents.map(&:to_request)
    end

    def documents_for_body
      documents.map(&:multipart_form_part)
    end

    def viewing_url
      docusign_envelope.viewing_url.parsed_response['url']
    end

    private

    def docusign_envelope
      @docusign_envelope ||= DocusignEnvelope.new(self)
    end

    def generate_document_ids!
      next_id = next_available_identifier_for(documents)
      documents.each_with_index do |document, index|
        document.identifier = index + next_id unless document.identifier.present?
      end
    end

    def generate_recipient_ids!
      next_id = next_available_identifier_for(recipients)
      recipients.each_with_index do |recipient, index|
        recipient.identifier = index + next_id unless recipient.identifier.present?
      end
    end

    def next_available_identifier_for(items)
      items.map(&:identifier).compact.max.to_i + 1
    end

    def headers
      { 'Content-Type' => "multipart/form-data; boundary=#{Hancock.boundary}" }
    end

    def form_post_body
      post_body =  "\r\n--#{Hancock.boundary}\r\n"
      post_body << "Content-Type: application/json\r\n"
      post_body << "Content-Disposition: form-data\r\n\r\n"
      post_body << get_post_params(status).to_json
      post_body << "\r\n--#{Hancock.boundary}\r\n"
      post_body << documents_for_body.join("\r\n--#{Hancock.boundary}\r\n")
      post_body << "\r\n--#{Hancock.boundary}--\r\n"
    end

    def reminder_for_params
      reminder = {
        :reminderEnabled => @reminder.present?
      }
      if @reminder
        reminder[:reminderDelay] = @reminder[:delay]
        reminder[:reminderFrequency] = @reminder[:frequency]
      end
      reminder
    end

    def expiration_for_params
      expiration = {
        :expireEnabled => @expiration.present?
      }
      if @expiration
        expiration[:expireAfter] = @expiration[:after]
        expiration[:expireWarn] = @expiration[:warn]
      end
      expiration
    end

    def get_post_params(status)
      {
        :emailBlurb => email[:blurb] || Hancock.email_template[:blurb],
        :emailSubject => email[:subject] || Hancock.email_template[:subject],
        :status => "#{status}",
        :documents => documents_for_params,
        :recipients => signature_requests_for_params,
        :notification => notification_for_params
      }
    end

    def check_collection_validity(field, klass)
      collection = send(field)
      errors.add(field, "can't be empty") if collection.empty?
      if collection.any? { |item| !(item.is_a?(klass)) }
        errors.add(field, "one of the #{field} is not a #{klass}")
      else
        # TODO: Consider making these one-liners (postfix conditional)
        unless collection.all?(&:valid?)
          errors.add(field, "one of the #{field} is not valid")
        end
      end
    end

    def recipient_validity
      check_collection_validity(:recipients, Recipient)
    end

    def document_validity
      check_collection_validity(:documents, Document)
    end

    #
    # format recipient type(symbol) for DocuSign
    #
    def docusign_recipient_type(type)
      type.to_s.camelize(:lower).pluralize
    end
  end
end
