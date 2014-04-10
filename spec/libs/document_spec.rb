require_relative '../spec_helper'

describe Hancock::Document do
  include_context "configs"
  include_context "variables"

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

end