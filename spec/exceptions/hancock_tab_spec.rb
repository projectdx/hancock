require_relative '../spec_helper'

describe Hancock::Tab do
  include_context "configs"

  it 'type, label are required' do 
    params = {
      coordinates: [2, 4]
    }
    expect { Hancock::Tab.new(params) }.to raise_error(Hancock::ArgumentError)
    params = {
      type:        'type',
      coordinates: [2, 4]
    }
    expect { Hancock::Tab.new(params) }.to raise_error(Hancock::ArgumentError)
    params = {
      type:        'type',
      coordinates: [2, 4]
    }
    expect { Hancock::Tab.new(params) }.to raise_error(Hancock::ArgumentError)
  end

  it 'should not raise an exception if valid params given' do 
    params = {
      label:       'label',
      type:        'type',
      coordinates: [2, 1234]
    }
    expect { Hancock::Tab.new(params) }.to_not raise_error()
  end

  it 'page_number should have default value of 1 it not supplied' do 
    params = {
      label:       'label',
      type:        'type',
      coordinates: [2, 1234]
    }
    h = Hancock::Tab.new(params)
    h.page_number.should eq(1)
  end

end