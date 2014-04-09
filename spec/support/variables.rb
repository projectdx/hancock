shared_context "variables" do
  let(:envelope) { Hancock::Envelope.new }

  let(:doc) { File.open("#{SPEC_ROOT}/fixtures/test.pdf") }

  let(:document) { Hancock::Document.new( file: doc, name: "test", extension: "pdf", identifier: 123 ) }
  
  let(:recipient) { Hancock::Recipient.new(name: "Owner", email: "kolya.bokhonko@gmail.com", routing_order: 1, delivery_method: :email) }
  
  let(:tab) { Hancock::Tab.new(type: "sign_here", label: "Vas", coordinates: [2, 100], page_number: 1) }

  let(:file) { File.new("#{SPEC_ROOT}/fixtures/test.pdf") }
end