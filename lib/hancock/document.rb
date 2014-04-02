module Hancock
  class Document

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
      raise 'error' unless data.is_a? File
      @file = file
    end

    def data= data
      raise 'error' unless @attributes[:file] && data
      raise 'error' if data.is_a? File
      @data = data
    end

    def name= name
      raise 'error' unless @attributes[:file] && name
      @name = name
      @name ||= File.basename(@attributes[:file])
    end

    def extension= extension
      raise 'error' unless @attributes[:file] && extension
      @name = name
      @name ||= File.basename(@attributes[:file])
    end

    def identifier= identifier
      @identifier = identifier 
      @identifier ||= generate_identifier
    end

    def initialize(attributes = {})
      @attributes = attributes
      ATTRIBUTES.each do |attr|
        self.send(attr, attributes[attr])
      end
    end

    private
      def generate_identifier
        0
      end
  end
end