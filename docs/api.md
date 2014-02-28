# rPace Signature Service

API Definition:

Input:
  - Word/PDF documents

### Request Signatures

**POST**: `/signatures/create`

	{
	  email: {
	  	subject: text,
	  	body: text,
	  	html: boolean,     # true: default
	  },
	  signers: [signer],
	  documents: [document],
	}

	signer: {
	  id_check: boolean,   # true: default for online (Signers#idCheckInformationInput, idCheckConfigurationName)
	  media: (online|offline|print),
	  email: text,
	  name: text,	  
	  tabs: [tab],					# anchor tabs, applies to all documents
	}
	
	document: {
	  identifier: text,
	  name: text,
	  body: text,
	  file_extension: text,
	}
	
	tab: {
	  type: (),						# sign_here_tabs, date_signed_tabs
	  page: number,					# applies only to specified page
	  position: {
	  	mode: anchor|absolute,
	    anchor: string,
	    x: integer,
	    y: integer
	  },
	  document_identifiers: [],
	  
	}

`/signatures/:id`


