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
import ballerina/lang.'string as sutils;

# Configuration for an Azure active directory authenticator provider
# 
# + tenantId - Tenant ID for the active directory
# + clientId - Client ID for the client credentials grant authentication
# + clientSecret - Client secret for the client credentials grant authentication
# + scopes - Scope(s) of the access request
public type InboundUserAuthenticatorProviderConfig record {|
    string tenantId;
    string clientId;
    string clientSecret?;
    string|string[] scopes = "";
|};

# An inbound authentication provider, which validates the used directory against the active one when the basic auth token is provided.
public type InboundUserAuthenticatorProvider object {

    *auth:InboundAuthProvider;

    private string tenantId;
    private string clientId;
    private string? clientSecret;
    private string|string[] scopes;

    # Provides authentication based on the provided introspection configurations.
    #
    # + tenantId - Tenant ID for the active directory
    # + clientId - Client ID for the client credentials grant authentication
    # + clientSecret - Client secret for the client credentials grant authentication // TOOD: not required
    # + scopes - Scope(s) of the access request
    # + 'resource - The resource, in which the authentication occurs
    public function __init(InboundUserAuthenticatorProviderConfig providerConfig) {
        self.tenantId = providerConfig.tenantId;
        self.clientId = providerConfig.clientId;
        self.clientSecret = providerConfig?.clientSecret;
        self.scopes = providerConfig.scopes;
    }

    # Use the OAuth2 password grant type to authenticate users based on their basic auth tokens.
    # 
    # + credential - The user's basic auth token
    # + return - `true` if authenticated, `false` if not authenticated, `error` if an error occurred while authenticating
    public function authenticate(string credential) returns boolean|auth:Error {
        if (credential == "") {
            return false;
        }

        // Format scopes into a string.
        string|string[] oAuthScopes = self.scopes;
        string oAuthScopesFormatted;
        if (oAuthScopes is string) {
            oAuthScopesFormatted = oAuthScopes;
        } else {
            oAuthScopesFormatted = sutils:'join(" ", ...oAuthScopes);
        }

        [string, string] [username, password] = check auth:extractUsernameAndPassword(credential);

        PasswordGrantConfig passwordGrantConfig = {
            tenantId: self.tenantId,
            clientId: self.clientId,
            username: username,
            password: password
        };

        string? clientSecret = self.clientSecret;
        if (clientSecret is string) {
            passwordGrantConfig.clientSecret = clientSecret;
        }

        http:BearerAuthHandler bearerAuthHandler = getOutboundOAuth2BearerHandler(passwordGrantConfig);
        auth:OutboundAuthProvider provider = <auth:OutboundAuthProvider>bearerAuthHandler.authProvider;

        // Set the `AuthenticationContext`.
        string accessToken = check provider.generateToken();
        auth:setAuthenticationContext("oauth2", accessToken);

        // Set the `Principal`.
        if (oAuthScopes is string) {
            string[] oAuthScopeArray = [oAuthScopes];
            auth:setPrincipal(username, username, oAuthScopeArray);
        } else {
            auth:setPrincipal(username, username, oAuthScopes);
        }

        return true;
    }
};
