Scenarios:

For flowing documents where the signature line cannot be determined, use
anchor tabs with a text anchor.

For such documents, it is best to have the same format.

### Global 'Owner 1 signature', 'Owner 2 signature'
	- Add anchor tab on signer level.
	- Use same format for signatures.
	
### Location specific


	{
  	  'email': {
  	  	'subject': 'Sign your life away',
  	  	'body': '<b>This is an email</b>',
  	  	'html': 'true'
  	  },
  	  'signers': [
  	  	{
  	  	  'id_check': 'true',
  	  	  'media': 'online',
  	  	  'email': 'recepient@mail.com',
  	  	  'name': 'Recepient Bob',
  	  	  'tabs': [
  	  	  	{
  	  	  	  'type': 'sign_here',
  	  	  	  'mode': 'anchor',
  	  	  	  'anchor': 'Owner 1 signature', 
  	  	  	  'x': '30',
  	  	  	  'y': '80',
  	  	  	  'document_identifiers': ['1234','44334']
  	  	  	},
  	  	  	{
  	  	  	  'type': 'date_signed',
  	  	  	  'mode': 'anchor',
  	  	  	  'anchor': 'date_signed_1',		# this could be text colored with same color as background. 
  	  	  	  'x': '30',
  	  	  	  'y': '80',
  	  	  	  'document_identifiers': ['1234','44334']
  	  	  	},
  	  	  	{
  	  	  	  'type': 'initial_here',
  	  	  	  'mode': 'absolute',
  	  	  	  'x': 400,
  	  	  	  'y': 300,
  	  	  	  'document_identifiers': ['233']
  	  	  	}
  	  	  ]
  	  	}
  	  ]
	}