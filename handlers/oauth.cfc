component {

	property name="oauthService" inject="oauthV1Service@oauth";
	property name="bitbucketService" inject="bitbucketService@bitbucket";

	function preHandler(event,rc,prc){

		if( !structKeyExists(getSetting('bitbucket'),'oauth') ){
			throw('You must define the OAuth setting in your Coldbox.cfc','bitbucket.setup');
		}
		prc.bitbucketCredentials = getSetting('bitbucket')['oauth'];
		prc.bitbucketSetting = getModuleSettings( module=event.getCurrentModule(), setting="oauth" );

		if(!structKeyExists(session,'bitbucketOAuth')){
			session['bitbucketOAuth'] = structNew();
		}
	}

	function index(event,rc,prc){

		if( event.getValue('id','') == 'announceUser' ){
			var results = duplicate(session['bitbucketOAuth']);

			bitbucketService.setup(results['oauth_token'],results['oauth_token_secret'])
abort;
			var data = bitbucketService.getUser().show(userID=results['user_id']);

			// add the user data to the announceInterception
			structAppend(results,data);

			structKeyRename(results,'user_id','referenceID');

			results['socialservice'] = 'bitbucket';

			announceInterception( state='bitbucketLoginSuccess', interceptData=results );
			announceInterception( state='loginSuccess', interceptData=results );
			setNextEvent(view=prc.bitbucketCredentials['loginSuccess'],ssl=( cgi.server_port == 443 ? true : false ));

		}else if( event.valueExists('oauth_token') ){
			session['bitbucketOAuth']['oauth_token'] = event.getValue('oauth_token');
			session['bitbucketOAuth']['oauth_verifier'] = event.getValue('oauth_verifier');

			oauthService.init();
			oauthService.setConsumerKey(prc.bitbucketCredentials['consumerKey']);
			oauthService.setConsumerSecret(prc.bitbucketCredentials['consumerSecret']);
			oauthService.setRequestURL(prc.bitbucketSetting['accessRequestURL']);
			oauthService.setRequestMethod('POST');
			oauthService.addParam(name="oauth_token",value=session['bitbucketOAuth']['oauth_token']);
			oauthService.addParam(name="oauth_verifier",value=session['bitbucketOAuth']['oauth_verifier']);

			var results = oauthService.send();
writedump(results);abort;
			if( results['status_code'] == 200 ){
				var myFields = listToArray(results['fileContent'],'&');

				for(var i=1;i<=arrayLen(myFields);i++){
					session['bitbucketOAuth'][listFirst(myFields[i],'=')] = listLast(myFields[i],'=');
				}
				// redirect to hide any url/code data
				setNextEvent('bitbucket/oauth/announceUser');
			}else{
				announceInterception( state='bitbucketLoginFailure', interceptData={'request':results} );
				announceInterception( state='loginFailure', interceptData=results );
				throw('Unknown bitbucket OAuth Error','bitbucket.access');
			}

		}else{

			oauthService.init();
			oauthService.setConsumerKey(prc.bitbucketCredentials['consumerKey']);
			oauthService.setConsumerSecret(prc.bitbucketCredentials['consumerSecret']);
			oauthService.setRequestURL(prc.bitbucketSetting['tokenRequestURL']);
			oauthService.setRequestMethod('POST');

			oauthService.addParam(name="oauth_callback",value=prc.bitbucketCredentials['callbackURL']);

			var results = oauthService.send();

			if( results['status_code'] == 200 ){
				var myFields = listToArray(toString(results['fileContent']),'&');

				for(var i=1;i<=arrayLen(myFields);i++){
					session['bitbucketOAuth'][listFirst(myFields[i],'=')] = listLast(myFields[i],'=');
				}

				location(url=prc.bitbucketSetting['authorizeRequestURL'] & "?oauth_token=#session['bitbucketOAuth']['oauth_token']#",addToken=false);

			}else{
				announceInterception( state='bitbucketLoginFailure', interceptData={'request':results} );
				throw('Unknown Bitbucket OAuth Error','bitbucket.request');
			}
		}
	}

	function structKeyRename(mStruct,mTarget,mKey){
		arguments.mStruct[mKey] = arguments.mStruct[mTarget];
		structDelete(arguments.mStruct,mTarget);

		return arguments.mStruct;
	}
}