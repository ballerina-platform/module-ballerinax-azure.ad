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

ConnectionConfig configuration = {
    auth: {
        refreshUrl: refreshUrl,
        refreshToken : refreshToken,
        clientId : clientId,
        clientSecret : clientSecret
    }
};

Client aadClient = check new(configuration);

string newUserId = "";
string newGroupId = "";
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
        displayName: string `CrewMember${randomString}`,
        userPrincipalName: userPricipalName,
        mailNickname: string `user${randomString}`,
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
    User|error user = aadClient->getUser(userId);
    if (user is User) {
        log:printInfo("User " + user.toString());
    } else {
        test:assertFail(msg = user.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testCreateUser]
}
function testGetUserWithQueryParams() {
    log:printInfo("client->getUserWithParams()");
    runtime:sleep(2);

    string userId = newUserId;
    string params = "$select=displayName,givenName,onPremisesExtensionAttributes,ageGroup,responsibilities";

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
    dependsOn: [testGetUser, testGetUserWithQueryParams]
}
function testUpdateUser() {
    log:printInfo("client->updateUser()");
    runtime:sleep(2);

    string userId = newUserId;
    UpdateUser info = {
    };
    error? userInfo = aadClient->updateUser(userId, info);
    if (userInfo is ()) {
        log:printInfo("Sucessfully updated");
    } else {
        test:assertFail(msg = userInfo.message());
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

    stream<User,error?>|error userStream = aadClient->listUsers();
    if (userStream is stream<User,error?>) {
        error? e = userStream.forEach(isolated function (User item) {
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

    string params = "$count=true";

    stream<User,error?>|error userStream = aadClient->listUsers(params);
    if (userStream is stream<User,error?>) {
        error? e = userStream.forEach(isolated function (User item) {
            log:printInfo(item.toString());
        });    
    } else {
        test:assertFail(msg = userStream.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testCreateUser]
}
function testCreateGroup() {
    log:printInfo("client->createGroup()");
    runtime:sleep(2);

    NewGroup info = {
        description: "Self help community for library",
        displayName: "Library Assist",
        groupTypes:["Unified"],
        mailEnabled: true,
        mailNickname: string `group${randomString}`,
        securityEnabled: false
        //ownerIds: [newUserId], // we can add owners and members at the group creation itself too
        //memberIds: [newUserId]
    };

    Group|error group = aadClient->createGroup(info);
    if (group is Group) {
        newGroupId = group?.id.toString();
        log:printInfo("Group created " + group?.id.toString());
    } else {
        test:assertFail(msg = group.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testCreateGroup]
}
function testGetGroup() {
    log:printInfo("client->getGroup()");
    runtime:sleep(2);

    string groupId = newGroupId;

    Group|error group = aadClient->getGroup(groupId);
    if (group is Group) {
        log:printInfo("Group " + group.toString());
    } else {
        test:assertFail(msg = group.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testCreateGroup]
}
function testUpdateGroup() {
    log:printInfo("client->updateGroup()");
    runtime:sleep(2);

    string groupId = newGroupId;
    UpdateGroup info = {
        mailNickname: string `grouprename${randomString}`
    };
    error? result = aadClient->updateGroup(groupId, info);
    if (result is ()) {
        log:printInfo("Sucessfully updated");
    } else {
        test:assertFail(msg = result.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true
}
function testListGroups() {
    log:printInfo("client->listGroups()");
    runtime:sleep(2);

    string query = "$top=1";

    stream<Group,error?>|error groupStream = aadClient->listGroups(query);
    if (groupStream is stream<Group,error?>) {
        error? e = groupStream.forEach(isolated function (Group item) {
            log:printInfo(item.toString());
        });    
    } else {
        test:assertFail(msg = groupStream.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testCreateGroup]
}
function testRenewGroup() {
    log:printInfo("client->renewGroup()");
    runtime:sleep(2);

    string groupId = newGroupId;

    error? result = aadClient->renewGroup(groupId);
    if (result is ()) {
        log:printInfo("Sucessfully renewed");
    } else {
        test:assertFail(msg = result.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testCreateGroup]
}
function testListParentGroups() { //test this for groups and users
    log:printInfo("client->listParentGroups()");
    runtime:sleep(2);

    string groupId = newGroupId;

    stream<Group,error?>|error groupStream = aadClient->listParentGroups("group", groupId);
    if (groupStream is stream<Group,error?>) {
        error? e = groupStream.forEach(isolated function (Group item) {
            log:printInfo(item.toString());
        });    
    } else {
        test:assertFail(msg = groupStream.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testCreateGroup]
}
function testListTransitiveParentGroups() { //test this for groups and users
    log:printInfo("client->listParentGroups()");
    runtime:sleep(2);

    string groupId = newGroupId;

    stream<Group,error?>|error groupStream = aadClient->listTransitiveParentGroups("group", groupId);
    if (groupStream is stream<Group,error?>) {
        error? e = groupStream.forEach(isolated function (Group item) {
            log:printInfo(item.toString());
        });    
    } else {
        test:assertFail(msg = groupStream.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testCreateUser, testCreateGroup]
}
function testAddMemberToGroup() {
    log:printInfo("client->addGroupMember()");
    runtime:sleep(2);

    string groupId = newGroupId;
    string memberId = newUserId;

    error? result = aadClient->addGroupMember(groupId, memberId);
    if (result is ()) {
        log:printInfo("Sucessfully added group member");
    } else {
        test:assertFail(msg = result.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testAddMemberToGroup, testCreateGroup]
}
function testListMembers() {
    log:printInfo("client->listGroupMembers()");
    runtime:sleep(2);

    string groupId = newGroupId;

    stream<User,error?>|error groupStream = aadClient->listGroupMembers(groupId);
    if (groupStream is stream<User,error?>) {
        error? e = groupStream.forEach(isolated function (User item) {
            log:printInfo(item.toString());
        });    
    } else {
        test:assertFail(msg = groupStream.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testAddMemberToGroup, testCreateGroup]
}
function testListTransitiveMembers() {
    log:printInfo("client->listTransitiveGroupMembers()");
    runtime:sleep(2); 

    string groupId = newGroupId;

    stream<User,error?>|error groupStream = aadClient->listTransitiveGroupMembers(groupId);
    if (groupStream is stream<User,error?>) {
        error? e = groupStream.forEach(isolated function (User item) {
            log:printInfo(item.toString());
        });    
    } else {
        test:assertFail(msg = groupStream.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testAddMemberToGroup, testCreateGroup]
}
function testRemoveMember() {
    log:printInfo("client->removeGroupMember()");
    runtime:sleep(2);

    string groupId = newGroupId;
    string memberId = newUserId;

    error? result = aadClient->removeGroupMember(groupId, memberId);
    if (result is ()) {
        log:printInfo("Sucessfully removed");
    } else {
        test:assertFail(msg = result.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testCreateUser, testCreateGroup]
}
function testAddOwnerToGroup() {
    log:printInfo("client->addGroupOwner()");
    runtime:sleep(2);

    string groupId = newGroupId;
    string ownerId = newUserId;

    error? result = aadClient->addGroupOwner(groupId, ownerId);
    if (result is ()) {
        log:printInfo("Sucessfully added group owner");
    } else {
        test:assertFail(msg = result.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testAddOwnerToGroup, testCreateGroup]
}
function testListOwners() {
    log:printInfo("client->listGroupOwners()");
    runtime:sleep(2);

    string groupId = newGroupId;

    stream<User,error?>|error groupStream = aadClient->listGroupOwners(groupId);
    if (groupStream is stream<User,error?>) {
        error? e = groupStream.forEach(isolated function (User item) {
            log:printInfo(item.toString());
        });    
    } else {
        test:assertFail(msg = groupStream.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testAddOwnerToGroup, testCreateGroup]
}
function testRemoveOwner() {
    log:printInfo("client->removeGroupOwner()");
    runtime:sleep(2);

    string groupId = newGroupId;
    string ownerId = newUserId;

    error? result = aadClient->removeGroupOwner(groupId, ownerId);
    if (result is ()) {
        log:printInfo("Sucessfully deleted");
    } else {
        test:assertFail(msg = result.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testCreateGroup]
}
function testListPermissionGrants() {
    log:printInfo("client->listPermissionGrants()");
    runtime:sleep(2);

    string groupId = newGroupId;

    stream<PermissionGrant, error?>|error grantStream = aadClient->listPermissionGrants(groupId);
    if (grantStream is stream<PermissionGrant, error?>) {
        error? e = grantStream.forEach(isolated function (PermissionGrant item) {
            log:printInfo(item.toString());
        });    
    } else {
        test:assertFail(msg = grantStream.message());
    }
    io:println("\n\n");
}

@test:AfterSuite {}
function testDeleteUserAndGroup() {
    runtime:sleep(2);

    string userId = newUserId;
    string groupId = newGroupId;

    log:printInfo("client->deleteUser()");
    error? userDeleteResult = aadClient->deleteUser(userId);
    if (userDeleteResult is ()) {
        log:printInfo("Sucessfully deleted the user");
    } else {
        test:assertFail(msg = userDeleteResult.message());
    }

    log:printInfo("client->deleteGroup()");
    error? groupDeleteResult = aadClient->deleteGroup(groupId);
    if (userDeleteResult is ()) {
        log:printInfo("Sucessfully deleted group");
    } else {
        test:assertFail(msg = userDeleteResult.message());
    }
}

# Create a random UUID removing the unnecessary hyphens which will interrupt querying opearations.
# 
# + return - A string UUID without hyphens
function createRandomUUIDWithoutHyphens() returns string {
    string? stringUUID = java:toString(createRandomUUID());
    if (stringUUID is string) {
        return 'string:substring(regex:replaceAll(stringUUID, "-", ""), 1, 4);
    } else {
        return EMPTY_STRING;
    }
}

function createRandomUUID() returns handle = @java:Method {
    name: "randomUUID",
    'class: "java.util.UUID"
} external;