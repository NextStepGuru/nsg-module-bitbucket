Coldbox Module to allow Social Login via bitbucket
================

Setup & Installation
---------------------

####Add the following structure to Coldbox.cfc

    bitbucket = {
        oauth = {
            loginSuccess        = "login.success",
            loginFailure        = "login.failure",
            consumerKey         = "{{bitbucket_provided_clientID}}",
            consumerSecret      = "{{bitbucket_provided_clientSecret}}",
            callbackURL         = "{{where_the_user_will_land_after_redirect}}"
        }
    }

Interception Point
---------------------
If you want to capture any data from a successful login, use the interception point bitbucketLoginSuccess. Inside the interceptData structure will contain all the provided data from bitbucket for the specific user.

####An example interception could look like this

    component {
        function bitbucketLoginSuccess(event,interceptData){
            var queryService = new query(sql="SELECT roles,email,password FROM user WHERE bitbucketUserID = :id;");
                queryService.addParam(name="id",value=interceptData['id']);
            var lookup = queryService.execute().getResult();
            if( lookup.recordCount ){
                login {
                    loginuser name=lookup.email password=lookup.password roles=lookup.roles;
                };
            }else{
                // create new user
            }
        }
    }

