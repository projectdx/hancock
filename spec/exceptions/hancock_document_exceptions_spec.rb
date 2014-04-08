require_relative '../spec_helper'

describe Hancock::Document do
  include_context "configs"
  include_context "variables"

  it 'Is valid when file suplied' do
     lambda { Hancock::Document.new({file: file}) }.should_not raise_error()
  end

  it 'Is valid when data, name, extension suplied' do 
    params = {
      data: 'string',
      name: 'test',
      extension: 'pdf'
    }
   lambda { Hancock::Document.new(params) }.should_not raise_error()
  end

  it 'data required if no file, invalid if file' do 
    params = {
      file: file,
      data: 'string',
      name: 'test',
      extension: 'pdf'
    }
   lambda { Hancock::Document.new(params) }.should raise_error(Hancock::ArgumentError)

    params = {
      name: 'test',
      extension: 'pdf'
    }
    lambda { Hancock::Document.new(params) }.should raise_error(Hancock::ArgumentError)
  end

  it 'data should not be file' do 
    params = {
      data: file,
      name: 'test',
      extension: 'pdf'
    }
    lambda { Hancock::Document.new(params) }.should raise_error(Hancock::ArgumentError)
  end

  it 'name, extension must be optional if file' do
    params = {
      data: 'string'
    }
    lambda { Hancock::Document.new(params) }.should raise_error(Hancock::ArgumentError)
  end
end