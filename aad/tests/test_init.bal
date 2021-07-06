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


Client aadClient = check new(configuration);

string newUserId = "";

var randomString = createRandomUUIDWithoutHyphens();

@test:Config {
    enable: false
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

    User|error user = aadClient->createUser(info);
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
    //string userId = "b3bbe751-6c6c-4614-81b8-5e569130eb8b";
    User|error user = aadClient->getUser(userId);
    if (user is User) {
        log:printInfo("User " + user.toString());
    } else {
        test:assertFail(msg = user.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true
    dependsOn: [testCreateUser]
}
function testGetUserWithQueryParams() {
    log:printInfo("client->getUserWithParams()");
    runtime:sleep(2);

    string userId = newUserId;
    //string userId = "b3bbe751-6c6c-4614-81b8-5e569130eb8b";
    string[] params = ["$select=displayName,givenName,onPremisesExtensionAttributes,ageGroup,responsibilities"];

    User|error user = aadClient->getUser(userId, params);
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
    Error? result = aadClient->updateUser(userId, info);
    if (result is ()) {
        log:printInfo("Sucessfully updated");
    } else {
        test:assertFail(msg = result.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testGetUser]
}
function testListUsers() {
    log:printInfo("client->listUsers()");
    runtime:sleep(2);

    stream<User,Error>|Error userStream = aadClient->listUsers();
    if (userStream is stream<User,Error>) {
        Error? e = userStream.forEach(isolated function (User item) {
            log:printInfo(item.toString());
        });    
    } else {
        test:assertFail(msg = userStream.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testGetUser]
}
function testListUsersQueryParams() {
    log:printInfo("client->listUsersWithParams()");
    runtime:sleep(2);

    string[] params = ["$count"];

    stream<User,Error>|Error userStream = aadClient->listUsers(params);
    if (userStream is stream<User,Error>) {
        Error? e = userStream.forEach(isolated function (User item) {
            log:printInfo(item.toString());
        });    
    } else {
        test:assertFail(msg = userStream.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testUpdateUser]
}
function testDeleteUser() {
    log:printInfo("client->deleteUser()");
    runtime:sleep(2);

    string userId = newUserId;

    Error? result = aadClient->deleteUser(userId);
    if (result is ()) {
        log:printInfo("Sucessfully deleted");
    } else {
        test:assertFail(msg = result.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: false
}
function testCreateGroup() {
    log:printInfo("client->createGroup()");
    runtime:sleep(2);

    string userPricipalName = string `${randomString}.pirate@chethya.onmicrosoft.com`;

    NewGroup info = {
        description: "Self help community for library",
        displayName: "Library Assist",
        groupTypes:["Unified"],
        mailEnabled: true,
        mailNickname: "lib",
        securityEnabled: false
    };

    Group|error group = aadClient->createGroup(info);
    if (group is Group) {
        newUserId = group?.id.toString();
        log:printInfo("User created " + group?.id.toString());
    } else {
        test:assertFail(msg = group.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: false
}
function testGetGroup() {
    log:printInfo("client->getGroup()");
    runtime:sleep(2);

    string groupId = "55199f19-1e43-4dd8-a25d-89428656eefb";
    Group|Error group = aadClient->getGroup(groupId);
    if (group is Group) {
        log:printInfo("Group " + group.toString());
    } else {
        test:assertFail(msg = group.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: false
}
function testUpdateGroup() {
    log:printInfo("client->updateGroup()");
    runtime:sleep(2);

    string groupId = "55199f19-1e43-4dd8-a25d-89428656eefb";
    UpdateGroup info = {
        mailNickname: "Up"
    };
    Error? result = aadClient->updateGroup(groupId, info);
    if (result is ()) {
        log:printInfo("Sucessfully updated");
    } else {
        test:assertFail(msg = result.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: false
}
function testListGroups() {
    log:printInfo("client->listGroups()");
    runtime:sleep(2);

    stream<Group,Error>|Error groupStream = aadClient->listGroups();
    if (groupStream is stream<Group,Error>) {
        Error? e = groupStream.forEach(isolated function (Group item) {
            log:printInfo(item.toString());
        });    
    } else {
        test:assertFail(msg = groupStream.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: false
}
function testDeleteGroup() {
    log:printInfo("client->deleteGroup()");
    runtime:sleep(2);

    string groupId = "55199f19-1e43-4dd8-a25d-89428656eefb";

    Error? result = aadClient->deleteGroup(groupId);
    if (result is ()) {
        log:printInfo("Sucessfully deleted");
    } else {
        test:assertFail(msg = result.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: false
}
function testRenewGroup() {
    log:printInfo("client->renewGroup()");
    runtime:sleep(2);

    string groupId = "55199f19-1e43-4dd8-a25d-89428656eefb";

    Error? result = aadClient->renewGroup(groupId);
    if (result is ()) {
        log:printInfo("Sucessfully renewed");
    } else {
        test:assertFail(msg = result.message());
    }
    io:println("\n\n");
}

// @test:Config {
//     enable: false
// }
// function testListParentGroups() { //test this for groups and users
//     log:printInfo("client->listParentGroups()");
//     runtime:sleep(2);

//     string groupId = "55199f19-1e43-4dd8-a25d-89428656eefb";

//     stream<Group,Error>|Error groupStream = aadClient->listParentGroups("group", groupId);
//     if (groupStream is stream<Group,Error>) {
//         Error? e = groupStream.forEach(isolated function (Group item) {
//             log:printInfo(item.toString());
//         });    
//     } else {
//         test:assertFail(msg = groupStream.message());
//     }
//     io:println("\n\n");
// }

// @test:Config {
//     enable: false
// }
// function testListTransitiveParentGroups() { //test this for groups and users
//     log:printInfo("client->listParentGroups()");
//     runtime:sleep(2);

//     string groupId = "55199f19-1e43-4dd8-a25d-89428656eefb";

//     stream<Group,Error>|Error groupStream = aadClient->listTransitiveParentGroups("group", groupId);
//     if (groupStream is stream<Group,Error>) {
//         Error? e = groupStream.forEach(isolated function (Group item) {
//             log:printInfo(item.toString());
//         });    
//     } else {
//         test:assertFail(msg = groupStream.message());
//     }
//     io:println("\n\n");
// }

@test:Config {
    enable: false
}
function testAddMemberToGroup() {
    log:printInfo("client->addGroupMember()");
    runtime:sleep(2);

    string groupId = "1e7a4360-0a8a-4ec4-9b3d-9ffdcf1cb92f";
    string memberId = "8323de12-2bba-4658-a115-1fcb86d5f4f5";

    Error? result = aadClient->addGroupMember(groupId, memberId);
    if (result is ()) {
        log:printInfo("Sucessfully added group member");
    } else {
        test:assertFail(msg = result.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: false
}
function testListMembers() { //test this for groups and users
    log:printInfo("client->listGroupMembers()");
    runtime:sleep(2);

    string groupId = "1e7a4360-0a8a-4ec4-9b3d-9ffdcf1cb92f";

    stream<User,Error>|Error groupStream = aadClient->listGroupMembers(groupId);
    if (groupStream is stream<User,Error>) {
        Error? e = groupStream.forEach(isolated function (User item) {
            log:printInfo(item.toString());
        });    
    } else {
        test:assertFail(msg = groupStream.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: false
}
function testListTransitiveMembers() { //test this for groups and users
    log:printInfo("client->listTransitiveGroupMembers()");
    runtime:sleep(2); 

    string groupId = "1e7a4360-0a8a-4ec4-9b3d-9ffdcf1cb92f";

    stream<User,Error>|Error groupStream = aadClient->listTransitiveGroupMembers(groupId);
    if (groupStream is stream<User,Error>) {
        Error? e = groupStream.forEach(isolated function (User item) {
            log:printInfo(item.toString());
        });    
    } else {
        test:assertFail(msg = groupStream.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: false
}
function testRemoveMember() {
    log:printInfo("client->removeGroupMember()");
    runtime:sleep(2);

    string groupId = "fd1b4442-4c0d-472b-b87e-dc9155200ce5";
    string memberId = "b3bbe751-6c6c-4614-81b8-5e569130eb8b";

    Error? result = aadClient->removeGroupMember(groupId, memberId);
    if (result is ()) {
        log:printInfo("Sucessfully deleted");
    } else {
        test:assertFail(msg = result.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: false
}
function testAddOwnerToGroup() {
    log:printInfo("client->addGroupOwner()");
    runtime:sleep(2);

    string groupId = "1e7a4360-0a8a-4ec4-9b3d-9ffdcf1cb92f";
    string ownerId = "8323de12-2bba-4658-a115-1fcb86d5f4f5";

    Error? result = aadClient->addGroupOwner(groupId, ownerId);
    if (result is ()) {
        log:printInfo("Sucessfully added group owner");
    } else {
        test:assertFail(msg = result.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: false
}
function testListOwners() {
    log:printInfo("client->listGroupOwners()");
    runtime:sleep(2);

    string groupId = "1e7a4360-0a8a-4ec4-9b3d-9ffdcf1cb92f";

    stream<User,Error>|Error groupStream = aadClient->listGroupOwners(groupId);
    if (groupStream is stream<User,Error>) {
        Error? e = groupStream.forEach(isolated function (User item) {
            log:printInfo(item.toString());
        });    
    } else {
        test:assertFail(msg = groupStream.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: false
}
function testRemoveOwner() {
    log:printInfo("client->removeGroupOwner()");
    runtime:sleep(2);

    string groupId = "fd1b4442-4c0d-472b-b87e-dc9155200ce5";
    string ownerId = "73a77e1e-31c0-4a99-ac1d-733053b16cbe";

    Error? result = aadClient->removeGroupOwner(groupId, ownerId);
    if (result is ()) {
        log:printInfo("Sucessfully deleted");
    } else {
        test:assertFail(msg = result.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: false
}
function testListPermissionGrants() {
    log:printInfo("client->listPermissionGrants()");
    runtime:sleep(2);

    string groupId = "fd1b4442-4c0d-472b-b87e-dc9155200ce5";

    stream<PermissionGrant,Error>|Error grantStream = aadClient->listPermissionGrants(groupId);
    if (grantStream is stream<PermissionGrant,Error>) {
        Error? e = grantStream.forEach(isolated function (PermissionGrant item) {
            log:printInfo(item.toString());
        });    
    } else {
        test:assertFail(msg = grantStream.message());
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