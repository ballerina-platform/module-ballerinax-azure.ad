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

import ballerina/http;
import ballerina/oauth2;

# The data structure, which is used to configure the OAuth2 client credentials grant type.
#
# + tenantId - Tenant ID for the active directory
# + clientId - Client ID for the client credentials grant authentication
# + clientSecret - Client secret for the client credentials grant authentication
# + scopes - Scope(s) of the access request
# + clockSkewInSeconds - Clock skew in seconds
# + retryRequest - Retry the request if the initial request returns a 401 response
# + credentialBearer - Bearer of the authentication credentials, which is sent to the authorization endpoint
# + clientConfig - HTTP client configurations, which are used to call the authorization endpoint
public type ClientCredentialsGrantConfig record {|
    string tenantId;
    string clientId;
    string clientSecret;
    string[] scopes = ["https://graph.microsoft.com/.default"];
    int clockSkewInSeconds = 0;
    boolean retryRequest = true;
    http:CredentialBearer credentialBearer = http:AUTH_HEADER_BEARER;
    oauth2:ClientConfiguration clientConfig = {};
|};

# The data structure, which is used to configure the OAuth2 password grant type.
#
# + tenantId - Tenant ID for the active directory
# + username - Username for the password grant authentication
# + password - Password for the password grant authentication
# + clientId - Client ID for the password grant authentication
# + clientSecret - Client secret for the password grant authentication
# + scopes - Scope(s) of the access request
# + refreshConfig - Configurations for refreshing the access token
# + clockSkewInSeconds - Clock skew in seconds
# + retryRequest - Retry the request if the initial request returns a 401 response
# + credentialBearer - Bearer of the authentication credentials, which is sent to the authorization endpoint
# + clientConfig - HTTP client configurations, which are used to call the authorization endpoint
public type PasswordGrantConfig record {|
    string tenantId;
    string username;
    string password;
    string clientId;
    string clientSecret?;
    string[] scopes = ["https://graph.microsoft.com/.default"];
    RefreshConfig refreshConfig?;
    int clockSkewInSeconds = 0;
    boolean retryRequest = true;
    http:CredentialBearer credentialBearer = http:AUTH_HEADER_BEARER;
    oauth2:ClientConfiguration clientConfig = {};
|};

# The data structure, which is used to configure the OAuth2 access token directly.
#
# + tenantId - Tenant ID for the active directory
# + accessToken - Access token for the authorization endpoint
# + refreshConfig - Configurations for refreshing the access token
# + clockSkewInSeconds - Clock skew in seconds
# + retryRequest - Retry the request if the initial request returns a 401 response
# + credentialBearer - Bearer of the authentication credentials, which is sent to the authorization endpoint
public type DirectTokenConfig record {|
    string tenantId;
    string accessToken?;
    DirectTokenRefreshConfig refreshConfig?;
    int clockSkewInSeconds = 0;
    boolean retryRequest = true;
    oauth2:CredentialBearer credentialBearer = http:AUTH_HEADER_BEARER;
|};

# The data structure, which can be used to pass the configurations for refreshing the access token of
# the password grant type.
#
# + scopes - Scope(s) of the access request
# + credentialBearer - Bearer of the authentication credentials, which is sent to the authorization endpoint
# + clientConfig - HTTP client configurations, which are used to call the authorization endpoint
public type RefreshConfig record {|
    string[] scopes?;
    http:CredentialBearer credentialBearer = http:AUTH_HEADER_BEARER;
    oauth2:ClientConfiguration clientConfig = {};
|};

# The data structure, which can be used to pass the configurations for refreshing the access token directly.
#
# + refreshToken - Refresh token for the refresh token server
# + clientId - Client ID for authentication with the authorization endpoint
# + clientSecret - Client secret for authentication with the authorization endpoint
# + scopes - Scope(s) of the access request
# + credentialBearer - Bearer of authentication credentials, which is sent to the authorization endpoint
# + clientConfig - HTTP client configurations, which is used to call the authorization endpoint
public type DirectTokenRefreshConfig record {|
    string refreshToken;
    string clientId;
    string clientSecret;
    string[] scopes = ["https://graph.microsoft.com/.default"];
    http:CredentialBearer credentialBearer = http:AUTH_HEADER_BEARER;
    oauth2:ClientConfiguration clientConfig = {};
|};
