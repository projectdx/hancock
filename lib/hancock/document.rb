module Hancock
  class Document < Hancock::Base
    attr_accessor :file, :data, :name, :extension, :identifier

    validates :name, :extension, :presence => true
    validate :has_either_data_or_file
    validate :data_meets_minimum_size_requirement

    def has_either_data_or_file
      unless file.present? ^ data.present? # XOR
        errors.add(:base, 'must have either data or file but not both')
      end
    end

    def data_meets_minimum_size_requirement
      unless data_size > min_document_data_size || !data.present?
        errors.add(:base, 'Data size of file #{name} is: #{data_size}. Minimum size is: #{min_document_data_size}')
      end
    end

    def initialize(attributes = {})
      @file       = attributes[:file]
      @data       = attributes[:data]
      @name       = attributes[:name]       || generate_name
      @extension  = attributes[:extension]  || generate_extension
      @identifier = attributes[:identifier]
    end

    def to_request
      { :documentId => identifier, :name => name }
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

    def self.fetch_all_for_envelope(envelope, options = {})
      options[:types] ||= ['content']
      connection = Hancock::DocuSignAdapter.new(envelope.identifier)
      connection.documents.map do |document|
        next unless options[:types].include?(document['type'])
        identifier = document['documentId']
        document_data = connection.document(identifier)
        identifier = identifier.to_i if identifier =~ /\A[0-9]+\z/
        new(:name => document['name'], :extension => 'pdf', :data => document_data, :identifier => identifier)
      end.compact
    end

    private

    def generate_name
      File.basename(@file) if @file
    end

    def generate_extension
      return File.basename(@file).split('.').last if @file
      return File.basename(@name).split('.').last if @name
    end

    def data_size
      data.bytesize
    end
  end
end
