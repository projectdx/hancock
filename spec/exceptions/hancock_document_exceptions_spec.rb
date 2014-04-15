require_relative '../spec_helper'

describe Hancock::Document do
  include_context "configs"
  include_context "variables"

  it 'Is valid when file supplied' do
    expect { Hancock::Document.new({file: file}) }.to_not raise_error()
  end

  it 'Is valid when: file, name, extension, identifier supplied' do 
    expect { Hancock::Document.new( file: doc, name: "test", extension: "pdf", identifier: 123 )}.to_not raise_error()
  end

  it 'Is valid when data, name, extension supplied' do 
    params = {
      data: 'string',
      name: 'test',
      extension: 'pdf'
    }
   expect { Hancock::Document.new(params) }.to_not raise_error()
  end

  it 'data required if no file, invalid if file' do 
    params = {
      file: file,
      data: 'string',
      name: 'test',
      extension: 'pdf'
    }
   expect { Hancock::Document.new(params) }.to raise_error(Hancock::ArgumentError)

    params = {
      name: 'test',
      extension: 'pdf'
    }
    expect { Hancock::Document.new(params) }.to raise_error(Hancock::ArgumentError)
  end

  it 'data should not be file' do 
    params = {
      data: file,
      name: 'test',
      extension: 'pdf'
    }
    expect { Hancock::Document.new(params) }.to raise_error(Hancock::ArgumentError)
  end

  it 'name, extension must be optional if file' do
    params = {
      data: 'string'
    }
    expect { Hancock::Document.new(params) }.to raise_error(Hancock::ArgumentError)
  end

  it 'Should not run validations if appropriate param supplied' do
    params = {
      data: file,
      name: 'test',
      extension: 'pdf'
    }
    expect { Hancock::Document.new(params, false) }.to_not raise_error()
  end
end