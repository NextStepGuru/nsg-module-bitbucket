component name="bitbucketExtends" hint="The Default bitbucket Setup for all Related Objects" accessors=true singleton {

	property name="oauthService" inject="oauthV1Service@oauth";
	property name="bitbucketCredentials" inject="coldbox:setting:bitbucket";
	property name="oauthToken";
	property name="oauthSecret";
	property name="consumerKey";
	property name="consumerSecret";

	function setup(required string oauthToken="",required string oauthSecret=""){
		setOAuthToken(arguments.oauthToken);
		setOAuthSecret(arguments.oauthSecret)
		setConsumerKey(getbitbucketCredentials()['oauth']['consumerKey']);
		setConsumerSecret(getbitbucketCredentials()['oauth']['consumerSecret']);
	}

	function checkResponse(any data){
		if(arguments.data['status_code'] == 200){
			var myData = deserializeJSON(arguments.data['fileContent']);

			if( structKeyExists(myData,'dateLastActivity') ){
				myData['modifiedAt'] = lsParseDateTime(myData['dateLastActivity']);
			}

			return myData;
		}else if(arguments.data['status_code'] == 429){
			throw("Rate-Limit Error","bitbucket.service");
		}else if(arguments.data['status_code'] == 401){
			throw("Unauthorized Access","bitbucket.service");
		}else{
			throw(data['fileContent'],"bitbucket.error",data['status_code'])
		}
	}

}