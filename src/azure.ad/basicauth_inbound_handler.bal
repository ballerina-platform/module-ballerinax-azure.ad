// Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/auth;
import ballerina/http;
import ballerina/mime;
import ballerina/lang.'string as sutils;

# Creates an inbound auth handler which authenticates users against the active directory based on basic auth headers.
# 
# + tenantId - Tenant ID for the active directory
# + clientId - Client ID for the client credentials grant authentication
# + clientSecret - Client secret for the client credentials grant authentication
# + scopes - Scope(s) of the access request
# + return - Inbound basic auth handler
public function getAzureADInboundBasicAuthHandler(string tenantId, string clientId, string clientSecret, string|string[] scopes = ["https://graph.microsoft.com/.default"]) returns http:BasicAuthHandler { 
    InboundAzureADUserAuthenticatorProvider userAuthProvider = new(tenantId, clientId, clientSecret, scopes);
    http:BasicAuthHandler basicAuthHandler = new(userAuthProvider);
    return basicAuthHandler;
}

# An inbound authentication provider which validates used against the active directory when basis auth token is provided.
public type InboundAzureADUserAuthenticatorProvider object {

    *auth:InboundAuthProvider;

    private string clientId;
    private string clientSecret;
    private string 'resource;
    private string|string[] scopes;
    private http:Client msOAuth2Client;

    # Provides authentication based on the provided introspection configurations.
    #
    # + tenantId - Tenant ID for the active directory
    # + clientId - Client ID for the client credentials grant authentication
    # + clientSecret - Client secret for the client credentials grant authentication
    # + scopes - Scope(s) of the access request
    # + 'resource - The resource which the authentication occurrs
    public function __init(string tenantId, string clientId, string clientSecret, string|string[] scopes, string 'resource = "https://graph.microsoft.com") {
        self.clientId = clientId;
        self.clientSecret = clientSecret;
        self.'resource = 'resource;
        self.scopes = scopes;
        self.msOAuth2Client = new(string `https://login.microsoftonline.com/${tenantId}/oauth2`);
    }

    # Use OAuth2 password grant type to authenticate user based on their basic auth token.
    # 
    # + credential - The user's basic auth token
    # + return - `true` if authenticated, `false` if not authenticated, `error` if error occurred while authenticating
    public function authenticate(string credential) returns boolean|auth:Error {
        // Format scopes into a string.
        string|string[] oAuthScopes = self.scopes;
        string oAuthScopesFormatted;
        if (oAuthScopes is string) {
            oAuthScopesFormatted = oAuthScopes;
        } else {
            oAuthScopesFormatted = sutils:'join(" ", ...oAuthScopes);
        }

        [string, string] [username, password] = check auth:extractUsernameAndPassword(credential);

        string payload = "grant_type=password&" +
                         "client_id=" + self.clientId + "&" +
                         "client_secret=" + self.clientSecret + "&" + 
                         "resource=" + self.'resource + "&" + 
                         "username=" + username + "&" +
                         "password=" + password + "&" +
                         "scope=" + oAuthScopesFormatted;

        // Send OAuth2 request.
        http:Request oAuthRequest = new;
        oAuthRequest.setTextPayload(<@untainted>payload, mime:APPLICATION_FORM_URLENCODED);
        http:Response|error loginResponseOrError = self.msOAuth2Client->post("/token", oAuthRequest);

        if (loginResponseOrError is error) {
            return false;
        }

        http:Response loginResponse = <http:Response>loginResponseOrError;
        json loginJson = checkpanic loginResponse.getJsonPayload();

        // Set AuthenticationContext
        string accessToken = loginJson.access_token.toString();
        auth:setAuthenticationContext("oauth2", accessToken);

        // Set Principal
        if (oAuthScopes is string) {
            string[] oAuthScopeArray = [oAuthScopes];
            auth:setPrincipal(username, username, oAuthScopeArray);
        } else {
            auth:setPrincipal(username, username, oAuthScopes);
        }

        return loginResponse.statusCode == 200;
    }
};
