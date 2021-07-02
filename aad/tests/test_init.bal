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

import ballerina/io;
import ballerina/jballerina.java;
import ballerina/lang.runtime;
import ballerina/log;
import ballerina/os;
import ballerina/regex;
import ballerina/test;

configurable string & readonly refreshUrl = os:getEnv("REFRESH_URL");
configurable string & readonly refreshToken = os:getEnv("REFRESH_TOKEN");
configurable string & readonly clientId = os:getEnv("CLIENT_ID");
configurable string & readonly clientSecret = os:getEnv("CLIENT_SECRET");

Configuration configuration = {
    clientConfig: {
        refreshUrl: refreshUrl,
        refreshToken : refreshToken,
        clientId : clientId,
        clientSecret : clientSecret,
        scopes: ["offline_access","https://graph.microsoft.com/.default"]
    }
};


Client oneDriveClient = check new(configuration);

string newUserId = "";

var randomString = createRandomUUIDWithoutHyphens();

@test:Config {
    enable: true
}
function testCreateUser() {
    log:printInfo("client->createUser()");
    runtime:sleep(2);

    string userPricipalName = string `${randomString}.pirate@chethya.onmicrosoft.com`;

    NewUser info = {
        accountEnabled: true,
        displayName: string `CrewMember ${randomString}`,
        userPrincipalName: userPricipalName,
        mailNickname: randomString,
        passwordProfile: {
            password: "xWwvJ]6NMw+bWH-d",
            forceChangePasswordNextSignIn: true
        },
        surname: "Rasinga"
    };

    User|error user = oneDriveClient->createUser(info);
    if (user is User) {
        newUserId = user?.id.toString();
        log:printInfo("User created " + user?.id.toString());
    } else {
        test:assertFail(msg = user.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testCreateUser]
}
function testGetUser() {
    log:printInfo("client->getUser()");
    runtime:sleep(2);

    string userId = newUserId;
    User|error user = oneDriveClient->getUser(userId);
    if (user is User) {
        log:printInfo("User " + user.toString());
    } else {
        test:assertFail(msg = user.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testGetUser]
}
function testUpdateUser() {
    log:printInfo("client->updateUser()");
    runtime:sleep(2);

    string userId = newUserId;
    UpdateUser info = {
    };
    Error? result = oneDriveClient->updateUser(userId, info);
    if (result is ()) {
        log:printInfo("Sucessfully updated");
    } else {
        test:assertFail(msg = result.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: false,
    dependsOn: [testUpdateUser]
}
function testDeleteUser() {
    log:printInfo("client->deleteUser()");
    runtime:sleep(2);

    string userId = newUserId;

    Error? result = oneDriveClient->deleteUser(userId);
    if (result is ()) {
        log:printInfo("Sucessfully deleted");
    } else {
        test:assertFail(msg = result.message());
    }
    io:println("\n\n");
}

# Create a random UUID removing the unnecessary hyphens which will interrupt querying opearations.
# 
# + return - A string UUID without hyphens
function createRandomUUIDWithoutHyphens() returns string {
    string? stringUUID = java:toString(createRandomUUID());
    if (stringUUID is string) {
        stringUUID = 'string:substring(regex:replaceAll(stringUUID, "-", ""), 1, 4);
        return stringUUID;
    } else {
        return EMPTY_STRING;
    }
}

function createRandomUUID() returns handle = @java:Method {
    name: "randomUUID",
    'class: "java.util.UUID"
} external;