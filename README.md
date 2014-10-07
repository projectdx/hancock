Hancock Signature Gem
=========================
Gem for submitting documents to DocuSign with electronic signature tabs.

## TODO:

* Allow sending of previously saved envelopes (right now `#save` followed by `#send!` just generates a new envelope)

## Interface Specification

<a name=".configure"/>
### 1. Configuration

```
Hancock.configure do |c|
   c.oauth_token     = 'MY-REALLY-LONG-TOKEN'
   c.account_id      = '999999'
   #c.endpoint       = 'https://www.docusign.net/restapi'
   #c.api_version    = 'v2'

  c.email_template = {
    :subject => 'sign me',
    :blurb => 'whatever '
  }
end
```

#### Description

DocuSign has the ability to make callbacks to a specified URI and provide status on an envelope and recepient.
This method will allow the client to register a callback uri and select which event to listen to.
[See eventNotification for details](https://www.docusign.com/p/RESTAPIGuide/RESTAPIGuide.htm#REST%20API%20References/Send%20an%20Envelope.htm%3FTocPath%3DREST%20API%20References%7CSend%20an%20Envelope%20or%20Create%20a%20Draft%20Envelope%7C_____0)

Key                | Description
---                | ---
oauth_token        | OAuth token generated via Docusign
account_id         | Docusign account id
endpoint           | Docusign endpoint (demo vs live)
api_version        | Docusign api version (v1, v2)
email_fields       | components necessary to create outgoing email to signers.
                   | `subject`: subject of email
                   | `blurb`: instruction blurb sent in the email to the recepient

***

### Create an envelope for sending or saving

Create the base Envelope object.

```
envelope = Hancock::Envelope.new
```

Create all the documents and add them to the base object. This has to be done because these need to be uploaded as part of the multi-part form.

```
document1 = Hancock::Document.new({
  file: #<File:/tmp/whatever.pdf>,
  # data: 'Base64 Encoded String', # required if no file, invalid if file
  # name: 'whatever.pdf', # optional if file, defaults to basename
  # extension: 'pdf', # optional if file, defaults to path extension
})

envelope.documents = [document1]
```

Create the recipients and tabs (sign here, date here, etc.) and add them via `#add_signature_request`.

**NOTE: Anchored tabs affect the entire envelope, not just a single document. Do not add the same anchored tab in multiple signature requests or you will see them stack in DocuSign (which is hard to even see, but you won't be able to submit because a bunch of fields are incomplete).**

```
recipient1 = Hancock::Recipient.new({
  name: 'Owner 1',
  email: 'whoever@whereever.com',
  # id_check: true,
  # delivery_method: email, # email, embedded, offline, paper
  # routing_order: 1
})

tab1 = Hancock::AnchoredTab.new({
  type: 'sign_here',
  label: '{{recipient.name}} Signature',
  coordinates: [2, 100]
  # anchor_text: 'Owner 1 Signature', # defaults to label
})

tab2 = Hancock::Tab.new({
  type: 'initial_here',
  label: 'Absolutely Positioned Initials',
  coordinates: [160, 400]
})

envelope.add_signature_request({
  recepient: recepient1,
  document: document1,
  tabs: [tab1, tab2]
})
```

Send or save the documents. Reload isn't necessary after `#send!` and `#save`.

```
envelope.send!    # sends to DocuSign and sets status to "sent," which sends email
envelope.save     # sends to DocuSign but sets status to "created," which makes it a draft
envelope.reload!  # if envelope has identifier, requests envelope from DocuSign.  Automatically done when 'send!' or 'save' is called
```

### Retrieve an envelope using a docusign envelope id

```
envelope = Hancock::Envelope.find(envelope_id)
```

Useful methods when you've found an envelope.

```
envelope.documents
envelope.recipients
envelope.status
```

### One call does it all

```
envelope = Hancock::Envelope.new({
  documents: [document1, document2],
  signature_requests: [
    {
      recipient: recipient1,
      document: document1,
      tabs: [tab1, tab2],
    },
    {
      recipient: recipient1,
      document: document2,
      tabs: [tab1],
    },
    {
      recipient: recipient2,
      document: document2,
      tabs: [tab1],
    },
  ],
  email: {
    subject: 'Hello there',
    blurb: 'Please sign this!'
  }
})

```

### Full example

Check out `example/example.rb` for a full and complete example with anchored tabs, multiple documents, etc. 

## Envelope class

```
Envelope.new(options = {})
```

Creates a new envelope.  An optional hash can be passed in to initialize the envelope with the following keys:

key                | description
---                | ---
documents          | colleciton of Document objects
signature_requests | collection of signature request hashes:
                   | `recepient`: Recepient object
                   | `document`: Document object which should be signed by recpient
                   | `tabs`: Tab objects for signature by recpient in the documnet
email              | email hash:
                   | `subject`; subject of email to send
                   | `blurb`: email blurb


```ruby
Envelope.find(envelope_id)
```

Retrieves envelope information from DocuSign

```ruby
Envelope#documents
```

```ruby
Envelope#recepients
```

Returns the list of recepients for the envelope.

```ruby
envelope.add_signature_request({
  recepient: recepient1,
  document: document1,
  tabs: [tab1, tab2]
})
```

Adds signature request to the envelope.  Signatrue request is hash with the following keys:

key          | description
---          | ---
 recepient | Recepient object
 document  | Document object which should be signed by recpient
 tabs      | Tab objects for signature by recpient in the documnet


```ruby
Envelope#send!
```

Submit the envelope to DocuSign for signatures and sets `send` status.  Once sent, the envelope should
be populated with Docusign envelope information (similar to `#reload!``)


```ruby
Envelope#save
```

Submit the envelope to DocuSign for signatures and sets `created` status which makes it a `draft`.  Once sent, the envelope should
be populated with Docusign envelope information (similar to `#reload!``)

```ruby
Envelope#reload!
```

If the envelope has a Docusign identifier, the request envelope information from Docusign.

```ruby
Envelope#identifer
Envelope#status
```

Upon submittal to DocuSign, this reader will contain the DocuSign envelope id and status and other envelope information.

Document class
---
```ruby
document1 = Hancock::Document.new({
  file: #<File:/tmp/whatever.pdf>,
  # data: 'Base64 Encoded String', # required if no file, invalid if file
  # name: 'whatever.pdf', # optional if file, defaults to basename
  # extension: 'pdf', # optional if file, defaults to path extension
})
```

A Document object can be created using a `File` object or by providing the acutal content through `data, name, extension` to describe the data.

argument   | description
---        | ---
file | (File object) which would contain the data, respond to `basename` and `extension`.
data | (string Required if `file` is missing) Base64 encoded string.
name       | (string) filename `bob_hope_contract`
extension  | (string [default: pdf]) file extension `docx                    | pdf..`

Recipient class
---
```ruby
recipient1 = Hancock::Recipient.new({
  name: 'Owner 1',
  email: 'whoever@whereever.com',
  # id_check: true,
  # delivery_method: email, # email, embedded, offline, paper
  # routing_order: 1
})
```

Key           | Description
---           | ---
name          | (string) Name of signer
email         | (string) Email address of signer
id_check      | (boolean [default: true]) true to enable [ID Check functionality](http://www.docusign.com/partner/docusign-id-check-powered-by-lexisnexis-risk-solutions)
delivery_method | (string [default: email])
              | `email`: send through email and sign online
              | `embedded`: embedded iframe
              | `offline`: sign offline on tablet
              | `paper`: print physical copy and snail-mail
routing_order | (integer [default 1]) routing order of recepient in the envelope.  If missing, then all recepients have the same routing order

***

2. Process Event Notification payload
-----

When event notification callback url is specified, DocuSign will post envelope and recepient events to the specefied url.
The payload is XML specified by the following [RecepientStatus and EnvelopeStatus](https://github.com/docusign/DocuSign-eSignature-SDK/blob/ae414f6abd81bb0c6629ef49c2a880026b3b3899/MS.NET/CodeSnippets/CodeSnippets/Service%20References/DocuSignWeb/api.wsdl)

EnvelopeStatus class
----

```ruby
EnvelopeStatus.new(xml)
```

This will extract the recipient events information from the xml and provide readers to the information.

For example:

```ruby
#recipient_statuses: collection of RecepientStatus objects
#documents: colleciton of Document objects as attachment (with their statuses)
```

RecepientStatus class
----

```ruby
RecepientStatus.new(xml)
```

Similarly, it exposes the information as readers on the object.

