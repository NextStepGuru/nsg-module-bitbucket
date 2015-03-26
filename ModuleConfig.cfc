component {

	// Module Properties
	this.title 				= "bitbucket";
	this.author 			= "Jeremy R DeYoung";
	this.webURL 			= "http://www.nextstep.guru";
	this.description 		= "Coldbox Module to allow Social Login via bitbucket";
	this.version			= "1.0.0";
	// If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
	this.viewParentLookup 	= true;
	// If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
	this.layoutParentLookup = true;
	// Module Entry Point
	this.entryPoint			= "bitbucket";
	// Model Namespace
	this.modelNamespace		= "bitbucket";
	// CF Mapping
	this.cfmapping			= "bitbucket";
	// Module Dependencies
	this.dependencies 		= ["nsg-module-security","nsg-module-oauth"];

	function configure(){

		// parent settings
		parentSettings = {

		};

		// module settings - stored in modules.name.settings
		settings = {
			oauth = {
				oauthVersion 		= 1,
				tokenRequestURL 	= "https://bitbucket.org/api/1.0/oauth/request_token",
				authorizeRequestURL = "https://bitbucket.org/api/1.0/oauth/authenticate",
				accessRequestURL 	= "https://bitbucket.org/api/1.0/oauth/access_token"
			}
		};

		// Layout Settings
		layoutSettings = {
		};

		// datasources
		datasources = {

		};

		// SES Routes
		routes = [
			// Module Entry Point
			{pattern="/", handler="oauth",action="index"},
			{pattern="/oauth/:id?", handler="oauth",action="index"}
		];

		// Custom Declared Points
		interceptorSettings = {
			customInterceptionPoints = "bitbucketLoginFailure,bitbucketLoginSuccess"
		};

		// Custom Declared Interceptors
		interceptors = [
		];

		// Binder Mappings
		binder.mapDirectory( "#moduleMapping#.models" );

	}

	/**
	* Fired when the module is registered and activated.
	*/
	function onLoad(){
		var nsgSocialLogin = controller.getSetting('nsgSocialLogin',false,arrayNew());
			arrayAppend(nsgSocialLogin,{"name":"bitbucket","icon":"bitbucket","title":"bitbucket"});
			controller.setSetting('nsgSocialLogin',nsgSocialLogin);
	}

	/**
	* Fired when the module is unregistered and unloaded
	*/
	function onUnload(){

	}

}