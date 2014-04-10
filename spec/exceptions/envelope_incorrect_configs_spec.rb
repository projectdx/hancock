require_relative '../spec_helper'

describe Hancock::Envelope do
  include_context "incorrect_configs"
  include_context "variables"

  it "should raise error because of bad configs" do
    envelope.add_document(document)
    envelope.add_signature_request({ 
      recipient: recipient, 
      document:  document, 
      tabs:      [tab] 
    })

    lambda { envelope.save }.should raise_error( Hancock::DocusignError )
  end
end