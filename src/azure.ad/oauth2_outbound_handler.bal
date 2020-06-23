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

# Creates an outbound auth handler which can be used by an http client.
# 
# + oAuth2Config - OAuth2 configuration for the client.
# + return - Outbound auth handler.
public function getAzureADOutboundOAuth2BearerHandler(ClientCredentialsGrantConfig|PasswordGrantConfig|DirectTokenConfig oAuth2Config) returns http:BearerAuthHandler {
    oauth2:OutboundOAuth2Provider oAuthProvider;
    if (oAuth2Config is ClientCredentialsGrantConfig) {
        oauth2:ClientCredentialsGrantConfig clientCredentialConfig = {
            tokenUrl: string `https://login.microsoftonline.com/${oAuth2Config.tenantID}/oauth2/v2.0/token`,
            clientId: oAuth2Config.clientId,
            clientSecret: oAuth2Config.clientSecret,
            clockSkewInSeconds: oAuth2Config.clockSkewInSeconds,
            retryRequest: oAuth2Config.retryRequest,
            credentialBearer: oAuth2Config.credentialBearer,
            clientConfig: oAuth2Config.clientConfig
        };

        string[]? scopes = oAuth2Config?.scopes;
        if (scopes is string[]) {
            clientCredentialConfig.scopes = scopes;
        }

        oAuthProvider = new oauth2:OutboundOAuth2Provider(clientCredentialConfig);
    } else if (oAuth2Config is PasswordGrantConfig) {
        oauth2:PasswordGrantConfig passwordConfig = {
            tokenUrl: string `https://login.microsoftonline.com/${oAuth2Config.tenantID}/oauth2/v2.0/token`,
            username: oAuth2Config.username,
            password: oAuth2Config.password,
            clientId: oAuth2Config.clientId,
            scopes: oAuth2Config.scopes,
            clockSkewInSeconds: oAuth2Config.clockSkewInSeconds,
            retryRequest: oAuth2Config.retryRequest,
            credentialBearer: oAuth2Config.credentialBearer,
            clientConfig: oAuth2Config.clientConfig
        };

        string? clientSecret = oAuth2Config?.clientSecret;
        if (clientSecret is string) {
            passwordConfig.clientSecret = clientSecret;
        }

        RefreshConfig? refreshConfig = oAuth2Config?.refreshConfig;
        if (refreshConfig is RefreshConfig) {
            oauth2:RefreshConfig oauth2RefreshConfig = {
                refreshUrl: "https://login.microsoftonline.com/common/oauth2/v2.0/token",
                credentialBearer: refreshConfig.credentialBearer,
                clientConfig: refreshConfig.clientConfig
            };
            passwordConfig.refreshConfig = oauth2RefreshConfig;
        }

        oAuthProvider = new oauth2:OutboundOAuth2Provider(passwordConfig);
    } else {
        oauth2:DirectTokenConfig directTokenConfig = {
            clockSkewInSeconds: oAuth2Config.clockSkewInSeconds,
            retryRequest: oAuth2Config.retryRequest,
            credentialBearer: oAuth2Config.credentialBearer
        };

        string? accessToken = oAuth2Config?.accessToken;
        if (accessToken is string) {
            directTokenConfig.accessToken = accessToken;
        }

        DirectTokenRefreshConfig? refreshConfig = oAuth2Config?.refreshConfig;
        if (refreshConfig is DirectTokenRefreshConfig) {
            oauth2:DirectTokenRefreshConfig oauth2DirectRefreshConfig = {
                refreshUrl: "https://login.microsoftonline.com/common/oauth2/v2.0/token",
                refreshToken: refreshConfig.refreshToken,
                clientId: refreshConfig.clientId,
                clientSecret: refreshConfig.clientSecret,
                credentialBearer: refreshConfig.credentialBearer,
                clientConfig: refreshConfig.clientConfig
            };

            string[]? scopes = refreshConfig?.scopes;
            if (scopes is string[]) {
                oauth2DirectRefreshConfig.scopes = scopes;
            }

            directTokenConfig.refreshConfig = oauth2DirectRefreshConfig;
        }

        oAuthProvider = new oauth2:OutboundOAuth2Provider(directTokenConfig);
    }

    http:BearerAuthHandler bearerHandler = new(oAuthProvider);
    return bearerHandler;
}
