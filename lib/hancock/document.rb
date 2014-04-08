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

    attr_accessor :file, :data, :name, :extension, :identifier

    supplies_default_value_for :identifier, value: :random
    supplies_default_value_for(:name, value: :file){ |file| File.basename(file, '.*') }
    supplies_default_value_for(:extension, value: :file){ |file| File.basename(file).split('.').last }
    validates_type_of :file, type: [File], allow_nil: true
    validates_type_of :data, type: [String], allow_nil: true
    validates_presence_of :data, :name, :extension, unless: :file

    def initialize(attributes = {})
      ATTRIBUTES.each do |attr|
        self.send("#{attr}=", attributes[attr])
      end
      self.supply_defaults!
      self.validate!
    end

    def to_request
      { documentId: identifier, name: name }
    end

    def data_for_request
      file.nil? ? data : IO.read(file)      
    end

  end
end