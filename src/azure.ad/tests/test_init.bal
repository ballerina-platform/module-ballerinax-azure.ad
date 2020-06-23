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

import ballerina/config;

final string TENANT_ID = config:getAsString("tenantID");
final string CLIENT_ID = config:getAsString("clientId");
final string CLIENT_SECRET = config:getAsString("clientSecret");
final string TENANT_DOMAIN = config:getAsString("tenantDomain");

Client adClient = getClient();

public function getClient() returns Client {
    ClientCredentialsGrantConfig clientCredentialOAuth2Config = {
        tenantID: TENANT_ID,
        clientId: CLIENT_ID,
        clientSecret: CLIENT_SECRET
    };

    ClientConfiguration clientConfig = {
        authHandler: getAzureADOutboundOAuth2BearerHandler(clientCredentialOAuth2Config)
    };

    Client adClient = new(clientConfig);
    return adClient;
}