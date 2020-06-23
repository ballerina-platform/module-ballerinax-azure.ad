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


import ballerina/test;

Group? testGroup1 = ();
Group? testGroup2 = ();

@test:BeforeSuite
function createGroupTest() {
    NewGroup newgroup1 = {
        description: "Beeper cars managers group",
        displayName: "Beeper Cars - Managers",
        mailNickname: "bcmanagers",
        groupTypes: ["Unified"],
        mailEnabled: true,
        securityEnabled: false
    };

    NewGroup newgroup2 = {
        description: "Beeper cars employees group",
        displayName: "Beeper Cars - Employees",
        mailNickname: "bcemps",
        groupTypes: ["Unified"],
        mailEnabled: true,
        securityEnabled: false
    };

    Group createdGroup = checkpanic adClient->createGroup(newgroup1);
    test:assertEquals(createdGroup.displayName, "Beeper Cars - Managers");

    testGroup1 = <@untainted>createdGroup;

    createdGroup = checkpanic adClient->createGroup(newgroup2);
    test:assertEquals(createdGroup.displayName, "Beeper Cars - Employees");

    testGroup2 = <@untainted>createdGroup;
}

@test:Config {}
function getGroupsTest() {
    Group[] adGroups = checkpanic adClient->getGroups();

    boolean foundManagerGroup = false;
    foreach Group adGroup in adGroups {
        if (adGroup.displayName == "Beeper Cars - Managers") {
            foundManagerGroup = true;
        }
    }

    test:assertTrue(foundManagerGroup);
}

@test:Config {}
function getGroupTest() {
    Group? group = testGroup1;
    if (group is Group) {
        Group adGroup = checkpanic adClient->getGroup(group.id);
        test:assertEquals(adGroup.securityIdentifier, group.securityIdentifier);
    } else {
        test:assertFail("group1 was not created");
    }
}

@test:Config {}
function groupMemberTest() {
    User? user1 = testUser1;
    Group? group1 = testGroup1;
    if (group1 is Group && user1 is User) {
        checkpanic adClient->addMemberToGroup(group1, <@untainted>user1);

        (User|Group|Device)[] members = checkpanic adClient->getGroupMembers(group1);
        test:assertEquals(members.length(), 1);
        User? assertUserMember = ();
        foreach User|Group|Device member in members {
            if (member is User) {
                assertUserMember = member;
            }
        }
        test:assertNotEquals(assertUserMember, ());

        checkpanic adClient->removeMemberFromGroup(group1, <@untainted>user1);
        members = checkpanic adClient->getGroupMembers(group1);
        test:assertEquals(members.length(), 0);
    } else {
        test:assertFail("group1 or user1 was not created");
    }
}

@test:Config {}
function groupOwnerTest() {
    User? user2 = testUser2;
    Group? group1 = testGroup1;
    if (group1 is Group && user2 is User) {
        checkpanic adClient->addOwnerToGroup(group1, <@untainted>user2);

        User[] owners = checkpanic adClient->getGroupOwners(group1);
        test:assertEquals(owners.length(), 1);
        test:assertEquals(owners[0].displayName, "Sandra Woosan");

        checkpanic adClient->removeOwnerFromGroup(group1, <@untainted>user2);
        owners = checkpanic adClient->getGroupOwners(group1);
        test:assertEquals(owners.length(), 0);
    } else {
        test:assertFail("group1 and user2 was not created");
    }
}

@test:AfterSuite
function deleteGroupTest() {
    Group? groupToDelete1 = testGroup1;
    if (groupToDelete1 is Group) {
        checkpanic adClient->deleteGroup(groupToDelete1);
    } else {
        test:assertFail("group1 was not created");
    }

    Group? groupToDelete2 = testGroup2;
    if (groupToDelete2 is Group) {
        checkpanic adClient->deleteGroup(groupToDelete2);
    } else {
        test:assertFail("group2 was not created");
    }
}
