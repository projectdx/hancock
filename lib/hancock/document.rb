module Hancock
  class Document < Hancock::Base
    attr_accessor :file, :data, :name, :extension, :identifier

    validates :name, :extension, :presence => true
    validate :has_either_data_or_file

    def has_either_data_or_file
      unless (file.blank? && data.present?) || (data.blank? && file.present?)
        errors.add(:base, 'must have either data or file but not both')
      end
    end

    def initialize(attributes = {})
      @file       = attributes[:file]
      @data       = attributes[:data]
      @name       = attributes[:name]       || generate_name()
      @extension  = attributes[:extension]  || generate_extension()
      @identifier = attributes[:identifier]
    end

    def to_request
      { documentId: identifier, name: name }
    end

    def data_for_request
      file.nil? ? data : IO.read(file)
    end

    def content_type_and_disposition
      case extension
      when 'pdf'
        "Content-Type: application/pdf\r\n"\
        "Content-Disposition: file; filename=#{name}; documentid=#{identifier}\r\n\r\n"
      when 'docx'
        "Content-Type: application/vnd.openxmlformats-officedocument.wordprocessingml.document\r\n"\
        "Content-Disposition: file; filename=#{name}; documentid=#{identifier}\r\n\r\n"
      end
    end

    def multipart_form_part
      content_type_and_disposition + data_for_request
    end

    def self.fetch_for_envelope(envelope)
      connection = Hancock::DocuSignAdapter.new(envelope.identifier)
      connection.documents.map do |document|
        document_data = connection.document(document["documentId"])
        new(name: document["name"], extension: "pdf", data: document_data)
      end
    end

    private
      def generate_name
        File.basename(@file) if @file
      end

      def generate_extension
        File.basename(@file).split('.').last if @file
      end

  end
end