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
import ballerina/system;

final string TENANT_ID = getConfigValue("TENANTID");
final string CLIENT_ID = getConfigValue("CLIENTID");
final string CLIENT_SECRET = getConfigValue("CLIENTSECRET");
final string TENANT_DOMAIN = getConfigValue("TENANTDOMAIN");

Client adClient = getClient();

public function getClient() returns Client {
    ClientCredentialsGrantConfig clientCredentialOAuth2Config = {
        tenantId: TENANT_ID,
        clientId: CLIENT_ID,
        clientSecret: CLIENT_SECRET
    };

    ClientConfiguration clientConfig = {
        authHandler: getOutboundOAuth2BearerHandler(clientCredentialOAuth2Config)
    };

    Client adClient = new(clientConfig);
    return adClient;
}

function getConfigValue(string key) returns string {
    return (system:getEnv(key) != "") ? system:getEnv(key) : config:getAsString(key);
}
