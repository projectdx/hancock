module Hancock
  class Document
  	ATTRIBUTES = [:file, :data, :name, :extension, :identifier]
    
    ATTRIBUTES.each do |attr|
      self.send(:attr_accessor, attr)
    end

    def initialize(attributes = {})
      ATTRIBUTES.each do |attr|
        self.send("#{attr}=", attributes[attr])
      end
    end
  end
end