module Hancock
  class Document < Hancock::Base

    #
    # file:       #<File:/tmp/whatever.pdf>,
    # data:       'Base64 Encoded String', # required if no file, invalid if file
    # name:       'whatever.pdf', # optional if file, defaults to basename
    # extension:  'pdf', # optional if file, defaults to path extension
    # identifier: 'my_document_3', # optional, generates if not given
    # 

    ATTRIBUTES = [:file, :data, :name, :extension, :identifier]

    attr_reader :file, :data, :name, :extension, :identifier

    def file= file
      if file && !file.is_a?(File)
        raise Hancock::ArgumentUnvalidError.new(file.class, File)
      end
      @file = file
    end

    def data= data
      message = '"data" required if no file, invalid if file'
      if @attributes[:file] && data
        raise Hancock::NonadjacentArgumentError.new(message) 
      elsif !@attributes[:file] && !data
        raise Hancock::NonadjacentArgumentError.new(message)
      elsif data.is_a? File
        raise Hancock::ArgumentUnvalidError.new(file.class, String) 
      end
      @data = data
    end

    def name= name
      if !@attributes[:file] && !name
        message = '"name" optional if file'
        raise Hancock::NonadjacentArgumentError.new(message) 
      end
      @name = name
      @name ||= File.basename(@attributes[:file], '.*')
    end

    def extension= extension
      if !@attributes[:file] && !extension
        message = '"extension" optional if file'
        raise Hancock::NonadjacentArgumentError.new(message) 
      end
      @extension = extension
      @extension ||= File.basename(@attributes[:file]).split('.').last
    end

    def identifier= identifier
      @identifier = identifier 
      @identifier ||= generate_identifier
    end

    def initialize(attributes = {})
      @attributes = attributes
      ATTRIBUTES.each do |attr|
        self.send("#{attr}=", attributes[attr])
      end
    end

    def to_request
      { documentId: identifier, name: name }
    end

  end
end