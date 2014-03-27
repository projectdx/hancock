Hancock Signature Gem
=========================
Gem for submitting documents to DocuSign with electronic signature tabs.


Interface Specification
------------------

<a name=".configure"/>
#### 1. Configuration

```ruby
Hancock.configure do |c|
  c.event_notification = {
    :logging_enabled => true,
    :uri => 'http://callback.com', 
    :envelope => [:delivered, :completed], 
    :recepient => [:completed]
  }
  c.email_template = {
    :subject => 'sign me',
    :body => 'whatever ',
    :html => true|false
  }
  c.anchors => {
    :sign_name => {
      :format => ':name Signature',
      :vertical_offset => 2,
      :horizontal_offset => -10
    },
    :intial_name => {
      :format => ':name Initial',
      :vertical_offset => -1,
      :horizontal_offset => 2
    }
  }
end

  -- OR --

Hancock.event_notification = {}
Hancock.email_template = {}
Hancock.anchors = {}
```

##### Description

DocuSign has the ability to make callbacks to a specified URI and provide status on an envelope and recepient.
This method will allow the client to register a callback uri and select which event to listen to. 
[See eventNotification for details](https://www.docusign.com/p/RESTAPIGuide/RESTAPIGuide.htm#REST%20API%20References/Send%20an%20Envelope.htm%3FTocPath%3DREST%20API%20References%7CSend%20an%20Envelope%20or%20Create%20a%20Draft%20Envelope%7C_____0)

Key                | Description
---                | ---
event_notifcation  | `logging_enabled`: (default: false) Flag on eventNotification to enable logging to DocuSign console.
                   | Register event notification callback uri, and events of interest.
                   | `uri`: Endpoint where DocuSign will call upon changes in envelope status
                   | `envelope`: a list of events to register for each envelope.  `possible values`: sent, delivered, sigend, completed, declined, voided
                   | `recepient`: a list of events to register for each recepient. `possible values`: authentication_failed, auto_responded, completed, declined, delivered, sent
email_fields       | components necessary to create outgoing email to signers.
                   | `subject`: subject of email
                   | `body`: body of email; this could be plain text or html.
                   | `html`: `false`: plain text body; `true`: html body.

___


1. Create and send documents for signing
-----

```ruby
envelope = Hancock::Envelop.new

#######
# 1. create documents and add them to envelope
document1 = Hancock::Document.new(..)
document2 = Hancock::Document.new(..)
envelope.add_document(document1)
envelope.add_document(document2)

# create signers and add them to envelope
signer1 = Hancock::Signer.new(..)
signer1.sign(:sign_name, document1, document2)
signer1.inital(:initial_name, document1, document2)
envelope.add_signer(signer1)

signer2 = Hancock::Signer.new(..)
signer2.sign(:sign_name, document2)
envelope.add_signer(signer2)

# send envelope
envelope.send!


######
# 2. request envelope information from docusign
envelope = Hancock::Envelope.new('i-am-the-envelope-id-which-i-saved-last-time')

# returns colleciton of Document objects within the envelope
envelope.documents  

# returns collection of Signer objects for this envelope
envelope.signers

# returns envelope status
envelope.status
```

Envelope class
----
```ruby
Envelope.new(docusign_envelope_id = nil)
```

Creates a new envelope.  An optional `docusign_envelope_id` allows for requesting envelope information from DocuSign.


```ruby
Envelope#add_document(document)
```

Add a Document to the envelope

```ruby
Envelope#documents
```

Returns the list of documents for this envelope. For an existing envelope, this list is retrieved from DocuSign.

```ruby
Envelope#add_signer(singer)
```

Add a Signer to the envelope

```ruby
Envelope#signers
```

Returns the list of signers for this envelope. For an existing envelope, the list is retrieved from DocuSign.


```ruby
Envelope#send!
```

Submit the envelope to DocuSign for signatures.

```ruby
Envelope#identifer
Envelope#status
```

Upon submittal to DocuSign, this reader will contain the DocuSign envelope id and status (and possibly other envelope information).

Document class
---
```ruby
Document.new(identifier, name, extension, ios|base64)
```

argument   | description
---        | ---
identifier | (string) unique identifier for the document
name       | (string) filename `bob_hope_contract`
extension  | (string [default: pdf]) file extension `docx                    | pdf..`
ios        | (IO stream object) binary stream of file content
base64     | (string) content encoded as base64

Signer class
---
```ruby
Signer.new(name, email, id_check, media, routing_order)
```

Key           | Description
---           | ---
name          | (string) Name of signer
email         | (string) Email address of signer
id_check      | (boolean [default: true]) true to enable [ID Check functionality](http://www.docusign.com/partner/docusign-id-check-powered-by-lexisnexis-risk-solutions)
media         | (string [default: online]) media for delivery;
              | `online`: send through email and sign online
              | `offline`: sign offline on tablet
              | `print`: print physical copy and snail-mail
routing_order | (integer [default 1]) routing order of recepient in the envelope.  If missing, then all recepients have the same routing order

```ruby
Signer#sign_here(format, *documents)
```

Adds a `sign_here` tab.

Key       | Description
---       | ---
format    | (symbol or string) a key in the configuration block `anchors` list.
documents | (one or more Document) document where tab should be added


```ruby
Signer#initial_here(format, *documents)
```

Adds a `initial_here` tab.

Key       | Description
---       | ---
format    | (symbol or string) a key in the configuration block `anchors` list.
documents | (one or more Document) document where tab should be added


2. Process Event Notification payload

When event notification callback url is specified, DocuSign will post envelope and recepient events to the specefied url.
The payload is XML specified by the following [RecepientStatus and EnvelopeStatus](https://github.com/docusign/DocuSign-eSignature-SDK/blob/ae414f6abd81bb0c6629ef49c2a880026b3b3899/MS.NET/CodeSnippets/CodeSnippets/Service%20References/DocuSignWeb/api.wsdl)

EnvelopeStatus
----

```ruby
EnvelopeStatus.new(xml)
```

This will extract the recipient events information from the xml and provide readers to the information.  

For example:

```ruby
#recipient_statuses: collection of RecepientStatus objects
#documents: colleciton of Document objects as attachment (with their statuses)
#

RecepientStatus.new(xml)
----

Similarly, it exposes the information as readers on the object.

