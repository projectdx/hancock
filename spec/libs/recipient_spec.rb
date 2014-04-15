require_relative '../spec_helper'

describe Hancock::Recipient do
  include_context "configs"
  include_context "variables"
  
  before do
    envelope.add_document(document)
    envelope.add_signature_request({ recipient: recipient, document: document, tabs: [tab] })
  end

  describe 'Defaults' do
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
    it 'Should generate recipient_type if not given' do 
      params = {
        name:            'name',
        email:           'email', 
        id_check:        true,
        delivery_method: :email, 
        routing_order:   1
       }
       Hancock::Recipient.new(params).recipient_type.should_not be(nil)
    end

    it 'Should reload recipients' do
      envelope.save
      recipients = envelope.recipients
      envelope.add_signature_request({ recipient: recipient2, document: document, tabs: [tab] })
      envelope.save

      recipients.size.should_not eq( Hancock::Recipient.reload!(envelope).size )
    end
  end
  

end