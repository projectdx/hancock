shared_context "variables" do
  let(:envelope) { Hancock::Envelope.new }

  let(:doc) { File.open("#{SPEC_ROOT}/fixtures/test.pdf") }
  let(:doc2) { File.open("#{SPEC_ROOT}/fixtures/test2.pdf") }

  let(:document) { Hancock::Document.new( file: doc, name: "test", extension: "pdf", identifier: 123 ) }
  let(:document2) { Hancock::Document.new( file: doc2, name: "test2", extension: "pdf", identifier: 1234 ) }

  
  let(:recipient) { Hancock::Recipient.new({identifier: 222, name: "Owner", email: "kolya.bokhonko@gmail.com", routing_order: 1, delivery_method: :email, recipient_type: :signer}) }
  let(:recipient2) { Hancock::Recipient.new({identifier: 2222, name: "Owner2", email: "kolya2.bokhonko@gmail.com", routing_order: 1, delivery_method: :email, recipient_type: :signer}) }
  
  let(:tab) { Hancock::Tab.new(type: "sign_here", label: "Vas", coordinates: [2, 100], page_number: 1) }

  let(:file) { File.new("#{SPEC_ROOT}/fixtures/test.pdf") }

  let (:header) { { 'Accept' => 'json', 'X-DocuSign-Authentication' => 
        { 'Username' => Hancock.username, 'Password' => Hancock.password, 'IntegratorKey' => Hancock.integrator_key }.to_json 
      } }

  let (:bad_header) { { 'Accept' => 'json', 'X-DocuSign-Authentication' => 
        { 'Username' => Hancock.username, 'Password' => "123456", 'IntegratorKey' => Hancock.integrator_key }.to_json 
      } }

  let(:callback_xml) { File.open("#{SPEC_ROOT}/fixtures/callback.xml", "rb").read }

end