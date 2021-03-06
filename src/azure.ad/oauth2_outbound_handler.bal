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

# Creates an outbound auth handler, which can be used by an HTTP client.
# 
# + oauth2Config - OAuth2 configuration for the client.
# + return - Outbound auth handler.
public function getOutboundOAuth2BearerHandler(ClientCredentialsGrantConfig|PasswordGrantConfig|DirectTokenConfig oauth2Config) returns http:BearerAuthHandler {
    oauth2:OutboundOAuth2Provider oauthProvider = getOutboundOAuth2Provider(oauth2Config);
    http:BearerAuthHandler bearerHandler = new(oauthProvider);
    return bearerHandler;
}

function getOutboundOAuth2Provider(ClientCredentialsGrantConfig|PasswordGrantConfig|DirectTokenConfig oauth2Config) returns oauth2:OutboundOAuth2Provider {
    oauth2:OutboundOAuth2Provider oauthProvider;
    // use OAuth2 instead of OAuth2
    if (oauth2Config is ClientCredentialsGrantConfig) {
        oauth2:ClientCredentialsGrantConfig clientCredentialConfig = {
            tokenUrl: string `https://login.microsoftonline.com/${oauth2Config.tenantId}/oauth2/v2.0/token`,
            clientId: oauth2Config.clientId,
            clientSecret: oauth2Config.clientSecret,
            clockSkewInSeconds: oauth2Config.clockSkewInSeconds,
            retryRequest: oauth2Config.retryRequest,
            credentialBearer: oauth2Config.credentialBearer,
            clientConfig: oauth2Config.clientConfig
        };

        string[]? scopes = oauth2Config?.scopes;
        if (scopes is string[]) {
            clientCredentialConfig.scopes = scopes;
        }

        oauthProvider = new oauth2:OutboundOAuth2Provider(clientCredentialConfig);
    } else if (oauth2Config is PasswordGrantConfig) {
        oauth2:PasswordGrantConfig passwordConfig = {
            tokenUrl: string `https://login.microsoftonline.com/${oauth2Config.tenantId}/oauth2/v2.0/token`,
            username: oauth2Config.username,
            password: oauth2Config.password,
            clientId: oauth2Config.clientId,
            scopes: oauth2Config.scopes,
            clockSkewInSeconds: oauth2Config.clockSkewInSeconds,
            retryRequest: oauth2Config.retryRequest,
            credentialBearer: oauth2Config.credentialBearer,
            clientConfig: oauth2Config.clientConfig
        };

        string? clientSecret = oauth2Config?.clientSecret;
        if (clientSecret is string) {
            passwordConfig.clientSecret = clientSecret;
        }

        RefreshConfig? refreshConfig = oauth2Config?.refreshConfig;
        if (refreshConfig is RefreshConfig) {
            oauth2:RefreshConfig oauth2RefreshConfig = {
                refreshUrl: "https://login.microsoftonline.com/common/oauth2/v2.0/token",
                credentialBearer: refreshConfig.credentialBearer,
                clientConfig: refreshConfig.clientConfig
            };
            passwordConfig.refreshConfig = oauth2RefreshConfig;
        }

        oauthProvider = new oauth2:OutboundOAuth2Provider(passwordConfig);
    } else {
        oauth2:DirectTokenConfig directTokenConfig = {
            clockSkewInSeconds: oauth2Config.clockSkewInSeconds,
            retryRequest: oauth2Config.retryRequest,
            credentialBearer: oauth2Config.credentialBearer
        };

        string? accessToken = oauth2Config?.accessToken;
        if (accessToken is string) {
            directTokenConfig.accessToken = accessToken;
        }

        DirectTokenRefreshConfig? refreshConfig = oauth2Config?.refreshConfig;
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

        oauthProvider = new oauth2:OutboundOAuth2Provider(directTokenConfig);
    }

    return oauthProvider;
}
