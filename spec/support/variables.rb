shared_context "variables" do
  let(:envelope) { Hancock::Envelope.new }

  let(:document) { Hancock::Document.new( file: file, name: "test", extension: "pdf", identifier: 123 ) }

  let(:recipient) { Hancock::Recipient.new({identifier: 222, name: "Owner", email: "ravi@renewfund.com", routing_order: 1, delivery_method: :email, recipient_type: :signer}) }
  
  let(:tab) { Hancock::Tab.new(type: "sign_here", label: "Vas", coordinates: [2, 100], page_number: 1) }

  let(:file) { File.open(fixture_path('test.pdf')) }
end