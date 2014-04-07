require_relative '../spec_helper'

describe Hancock::Envelope do
  include_context "incorrect_configs"
  include_context "variables"

  it "should raise error because of bas configs" do
    envelope.add_document(document)
    envelope.add_signature_request(recipient, document, [tab])

    lambda { envelope.save }.should raise_error( Hancock::DocusignError )
  end
end