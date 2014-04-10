require_relative '../spec_helper'

describe Hancock::Recipient do
  include_context "configs"
  include_context "variables"

  it 'Should generate identifier if not given' do 
    params = {
      name:            'name',
      email:           'email', 
      id_check:        true,
      delivery_method: :email, 
      routing_order:   1
     }
     Hancock::Recipient.new(params).identifier.should_not be(nil)
  end

end