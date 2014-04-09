require_relative '../spec_helper'

describe Hancock::Recipient do
  include_context "configs"

  it 'should not raise an exception if valid params given' do 
     params = {
      name:            'name',
      email:           'email', 
      id_check:        true,
      delivery_method: :email, 
      routing_order:   1, 
      identifier:      1234
     }
     lambda { Hancock::Recipient.new(params) }.should_not raise_error()

     params = {
      name:            'name',
      email:           'email',
      delivery_method: :email
     }
     lambda { Hancock::Recipient.new(params) }.should_not raise_error()
  end

  it 'should raise if delivery_method is not inclusion of [:email, :embedded, :offline, :paper]' do 
    params = {
      name:            'name',
      email:           'email', 
      routing_order:   1,
      delivery_method: :unvalid
     }
     lambda { Hancock::Recipient.new(params) }.should raise_error(Hancock::ArgumentError)
  end

end