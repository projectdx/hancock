require_relative '../spec_helper'

describe Hancock::Document do
  include_context "configs"
  include_context "variables"
  
  before do
    envelope.add_document(document)
    envelope.add_signature_request({ recipient: recipient, document: document, tabs: [tab] })
  end

  describe 'Default values' do
    it 'Should generate name if file given' do 
      params = {
        file: file
       }
       Hancock::Document.new(params).name.should_not be(nil)
    end

    it 'Should generate extension if file given' do 
      params = {
        file: file
       }
       Hancock::Document.new(params).extension.should_not be(nil)
    end
  end

  it 'Should reload documents' do
    envelope.save
    Hancock::Document.reload!(envelope).each do |document|
      document.data.should_not eq( nil )
    end
  end

end