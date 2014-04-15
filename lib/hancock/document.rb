module Hancock
  class Document < Hancock::Base

    #
    # file:       #<File:/tmp/whatever.pdf>,
    # data:       'Base64 Encoded String', # required if no file, invalid if file
    # name:       'whatever.pdf', # optional if file, defaults to basename
    # extension:  'pdf', # optional if file, defaults to path extension
    # identifier: 'my_document_3', # optional, generates if not given
    # 

    attr_accessor :file, :data, :name, :extension, :identifier

    validates :identifier, default: lambda{ |inst| inst.generate_identifier }
    validates :name, default: lambda{ |inst| File.basename(inst.file, '.*') if inst.file}, presence: true
    validates :extension, default: lambda{ |inst| File.basename(inst.file).split('.').last if inst.file}, presence: true
    validates :file, type: :file, allow_nil: true
    validates :data, type: :string, presence: lambda{ |inst| !inst.file }


    #
    # skip validations if 'run_validations' is false
    #
    def initialize(attributes = {}, run_validations = true) 
      @file       = attributes[:file] 
      @data       = attributes[:data]
      @name       = attributes[:name]
      @extension  = attributes[:extension]
      @identifier = attributes[:identifier]

      self.validate! if run_validations
    end

    def to_request
      { documentId: identifier, name: name }
    end

    def data_for_request
      file.nil? ? data : IO.read(file)      
    end

    def self.reload!(envelope)
      documents_array = []

      connection = Hancock::DocuSignAdapter.new(envelope.identifier)
      connection.documents.map do |document|
        document_data = connection.document(document["documentId"])
        documents_array << new(identifier: document["documentId"], name: document["name"], extension: "pdf", data: document_data)
      end
      documents_array
    end

  end
end