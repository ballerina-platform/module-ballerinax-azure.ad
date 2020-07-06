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
import ballerina/test;
import ballerina/http;
import ballerina/log;
import ballerina/runtime;


public function getAzureAdInboundBasicAuthHandler() returns http:BasicAuthHandler {
    InboundAzureAdUserAuthenticatorProviderConfig providerConfig = {
        tenantId: TENANT_ID,
        clientId: CLIENT_ID,
        clientSecret: CLIENT_SECRET
    };

    InboundAzureAdUserAuthenticatorProvider inboundAzureAdUserAuthenticatorProvider = new(providerConfig);
    http:BasicAuthHandler basicAuthHandler = new(inboundAzureAdUserAuthenticatorProvider);
    return basicAuthHandler;
}

public listener http:Listener shopEP = new(9090, {
    auth: {
        authHandlers: [getAzureAdInboundBasicAuthHandler()]
    },
    secureSocket: {
        keyStore: {
            path: "src/azure.ad/tests/resources/ballerinaKeystore.p12",
            password: "ballerina"
        }
    }
});

service shopService = @http:ServiceConfig {
    basePath: "/shop"
}
service {
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/cart"
    }
    resource function getCart(http:Caller caller, http:Request req) {
        runtime:AuthenticationContext? authContext = runtime:getInvocationContext()?.authenticationContext;
        string? authScheme = authContext?.scheme;
        test:assertEquals(authScheme, "oauth2");

        runtime:Principal? principal = runtime:getInvocationContext()?.principal;
        test:assertEquals(principal?.username, config:getAsString("ad.users.user1.username"));
        
        json cart = {
            items: [{
                    name: "eggs",
                    quantity: 10
                },{
                    name: "chocolate",
                    quantity: 2
                }
            ]
        };

        error? result = caller->respond(cart);
        if (result is error) {
            log:printError("error sending response", result);
        }
   }
};

@test:Config {}
public function basicAuthInboundHandlerTest() {
    var serviceOneAttachResult = shopEP.__attach(shopService);
    if (serviceOneAttachResult is error) {
        test:assertFail("error when attaching the service to the listener");
    } else {
        var serviceOneStartResult = shopEP.__start();
        if (serviceOneStartResult is error) {
            test:assertFail("error when starting the service");
        } else {
            http:Client customerClient = new("https://localhost:9090", {
                secureSocket: {
                    trustStore: {
                        path: "src/azure.ad/tests/resources/ballerinaTruststore.p12",
                        password: "ballerina"
                    }
                }
            });
            http:Request getCarRequest = new;
            string username = config:getAsString("ad.users.user1.username");
            string password = config:getAsString("ad.users.user1.password");
            getCarRequest.setHeader("Authorization", "Basic " + checkpanic getBasicAuthToken(username, password));
            http:Response cartResponse = checkpanic customerClient->get("/shop/cart", getCarRequest);
            json cartJson = checkpanic cartResponse.getJsonPayload();
            json[] items = <json[]>checkpanic cartJson.items;
            test:assertEquals(items.length(), 2);
            test:assertEquals(items[0].name, "eggs");
            test:assertEquals(items[0].quantity, 10);
            
            checkpanic shopEP.__gracefulStop();
        }
    }
}

function getBasicAuthToken(string username, string password) returns string|error {
    if (username == "" || password == "") {
        error authError = error("Username or password cannot be empty.");
        return authError;
    }
    string str = username + ":" + password;
    string token = str.toBytes().toBase64();
    return token;
}
