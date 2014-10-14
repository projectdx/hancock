module Hancock
  class Envelope < Hancock::Base
    class InvalidEnvelopeError < StandardError; end
    class DocusignError < StandardError; end
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
      @reminder = attributes[:reminder]
      @expiration = attributes[:expiration]
    end

    def add_signature_request(attributes = {})
      @recipients << attributes[:recipient] unless @recipients.include? attributes[:recipient]
      @documents << attributes[:document] unless @documents.include? attributes[:document]

      @signature_requests << {
        recipient: attributes[:recipient],
        document: attributes[:document],
        tabs: attributes[:tabs]
      }
    end

    #
    # sends to DocuSign and sets status to "sent," which sends email
    #
    def send!
      if identifier
        raise AlreadySentError if status == 'sent'
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
        raise AlreadySavedError
      else
        self.status = 'created'
        send_envelope
      end
    end

    # TODO: Separate 1) assembly of envelope model, 2) sending via DocuSign,
    # and 3) fetching results from DocuSign post-send.  Ideally into completely
    # separate objects.
    def send_envelope
      raise InvalidEnvelopeError unless valid?
      raise Hancock::ConfigurationMissing unless Hancock.configured?

      generate_document_ids!
      generate_recipient_ids!

      response = send_post_request("/accounts/#{Hancock.account_id}/envelopes", form_post_body, headers)

      if response.success?
        self.identifier = response["envelopeId"]
        reload!
      else
        message = response["message"]
        raise DocusignError.new(message)
      end
    end

    #
    # tells DocuSign to change status of envelope (usually used to actually
    # send a draft envelope (status "created") by changing its status
    # to "sent")
    #
    def change_status!(status)
      raise NotSavedYet unless identifier
      headers = get_headers({'Content-Type' => 'application/json'})
      put_body = { :status => status }.to_json
      response = send_put_request("/accounts/#{Hancock.account_id}/envelopes/#{identifier}", put_body, headers)

      if response.success?
        reload!
      else
        message = response["message"]
        raise DocusignError.new(message)
      end
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
        @email = {subject: response['emailSubject'], blurb: response['emailBlurb']}
        @documents = Document.fetch_all_for_envelope(self)
        @recipients = Recipient.fetch_for_envelope(self)
      end
      self
    end

    def signature_requests_for_params
      # TODO: Refactor (and move to a new class with sending responsibility)
      recipients = signature_requests.inject({}) { |hsh, request|
        recipient = request[:recipient]
        recipient_type = docusign_recipient_type(recipient.recipient_type)
        hsh[recipient_type] ||= []
        entry = hsh[recipient_type].detect { |r|
          r[:recipientId] == recipient.identifier
        }
        unless entry
          entry = { :email => recipient.email, :name => recipient.name, :recipientId => recipient.identifier }
          hsh[recipient_type] << entry
        end
        entry[:tabs] ||= {}
        request[:tabs].each do |tab|
          type = "#{tab.type}_tabs".camelize(:lower).to_sym
          entry[:tabs][type] ||= []
          entry[:tabs][type] << tab.to_h.merge(:documentId => request[:document].identifier)
        end
        hsh
      }
    end

    def notification_for_params
      {
        useAccountDefaults: false,
        reminders: reminder_for_params,
        expirations: expiration_for_params
      }
    end

    def documents_for_params
      documents.map(&:to_request)
    end

    def documents_for_body
      documents.map(&:multipart_form_part)
    end

    private

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
      get_headers({'Content-Type' => "multipart/form-data; boundary=#{Hancock.boundary}"})
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
        reminderEnabled: @reminder.present?
      }
      if @reminder
        reminder[:reminderDelay] = @reminder[:delay]
        reminder[:reminderFrequency] = @reminder[:frequency]
      end
      reminder
    end

    def expiration_for_params
      expiration = {
        expireEnabled: @expiration.present?
      }
      if @expiration
        expiration[:expireAfter] = @expiration[:after]
        expiration[:expireWarn] = @expiration[:warn]
      end
      expiration
    end

    def get_post_params(status)
      {
        emailBlurb: email[:blurb] || Hancock.email_template[:blurb],
        emailSubject: email[:subject]|| Hancock.email_template[:subject],
        status: "#{status}",
        documents: documents_for_params,
        recipients: signature_requests_for_params,
        notification: notification_for_params,
      }
    end

    def check_collection_validity(field, klass)
      collection = send(field)
      errors.add(field, "can't be empty") if collection.empty?
      if collection.any? {|item| !(item.is_a?(klass)) }
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

      unless has_unique_emails?
        errors.add(:recipients, "must all have unique emails")
      end
    end

    def has_unique_emails?
      recipients.map { |r| r.try(:email) }.uniq.length == recipients.length
    end

    def document_validity
      check_collection_validity(:documents, Document)
    end
  end
end
