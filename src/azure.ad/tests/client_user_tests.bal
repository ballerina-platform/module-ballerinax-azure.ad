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

User? testUser1 = ();
User? testUser2 = ();
User? testUser3 = ();

@test:BeforeSuite
function createUserTest() {
    record { string jobTitle; string postalCode; } additionalUser1Attributes = { 
        jobTitle: "DevOps Engineer",
        postalCode: "10100"
    };

    NewUser newUser1 = {
        accountEnabled: true,
        displayName: "Garfield Lynns",
        mailNickname: "garfieldlynns",
        passwordProfile: {
            forceChangePasswordNextSignIn: false,
            password: "Apple*83"
        },
        userPrincipalName: "garfieldlynns@" + TENANT_DOMAIN,
        ...additionalUser1Attributes
    };

    record { string jobTitle; } additionalUser2Attributes = { jobTitle: "Software Quality Manager" };

    NewUser newUser2 = {
        accountEnabled: true,
        displayName: "Sandra Woosan",
        mailNickname: "sandrawoosan",
        passwordProfile: {
            forceChangePasswordNextSignIn: false,
            password: "Dragon*83"
        },
        userPrincipalName: "sandrawoosan@" + TENANT_DOMAIN,
        ...additionalUser2Attributes
    };

    NewUser newUser3 = {
        accountEnabled: true,
        displayName: "Foo Bar",
        mailNickname: "foobar",
        passwordProfile: {
            forceChangePasswordNextSignIn: false,
            password: config:getAsString("ad.users.user1.password")
        },
        userPrincipalName: config:getAsString("ad.users.user1.username"),
        ...additionalUser2Attributes
    };

    User createdUser = checkpanic adClient->createUser(newUser1);
    test:assertEquals(createdUser.displayName, "Garfield Lynns");
    test:assertEquals(createdUser["jobTitle"], "DevOps Engineer");

    testUser1 = <@untainted>createdUser;

    createdUser = checkpanic adClient->createUser(newUser2);
    test:assertEquals(createdUser.displayName, "Sandra Woosan");
    test:assertEquals(createdUser["jobTitle"], "Software Quality Manager");

    testUser2 = <@untainted>createdUser;

    createdUser = checkpanic adClient->createUser(newUser3);
    testUser3 = <@untainted>createdUser;
}

@test:Config {}
function createUserWithInvalidFieldsTest() {
    record { string middleName; } additionalAttributes = { middleName: "Tikka" };

    NewUser newUser = {
        accountEnabled: true,
        displayName: "Jamie Oliver",
        mailNickname: "jamieoliver",
        passwordProfile: {
            forceChangePasswordNextSignIn: false,
            password: "Steak*45"
        },
        userPrincipalName: "jamie@" + TENANT_DOMAIN,
        ...additionalAttributes
    };

    User|AdClientError createdUser = adClient->createUser(newUser);
    if (createdUser is AdClientError) {
        error? adError = createdUser.cause();
        if (adError is GraphAPIError) {
            test:assertEquals(adError.message(), "One or more property values specified are invalid.");
            test:assertEquals(adError.detail()["code"], "Request_BadRequest");
        } else {
            test:assertFail("Invalid error type found");
        }
    } else {
        test:assertFail("User was not supposed to get created");
    }
}

@test:Config {}
function getUsersTest() {
    User[] adUsers = checkpanic adClient->getUsers();

    boolean foundGarfield = false;
    foreach User adUser in adUsers {
        if (adUser.displayName == "Garfield Lynns") {
            foundGarfield = true;
        }
    }

    test:assertTrue(foundGarfield);
}

@test:Config {}
function getUserTest() {
    User adUser = checkpanic adClient->getUser("garfieldlynns@" + TENANT_DOMAIN);
    test:assertEquals(adUser.displayName, "Garfield Lynns");

    adUser = checkpanic adClient->getUser("garfieldlynns@" + TENANT_DOMAIN, additionalFields = ["postalCode"]);
    test:assertEquals(adUser["postalCode"], "10100");
}

@test:Config {
    dependsOn: ["getUsersTest", "getUserTest"]
}
function updateUserTest() {
    User user = checkpanic adClient->getUser("garfieldlynns@" + TENANT_DOMAIN);
    user.jobTitle = "Senior DevOps Engineer";
    checkpanic adClient->updateUser(<@untainted>user);

    user = checkpanic adClient->getUser("garfieldlynns@" + TENANT_DOMAIN);
    test:assertEquals(user?.jobTitle, "Senior DevOps Engineer");
}

@test:Config {}
function assignManagerToUser() {
    User user = checkpanic adClient->getUser("garfieldlynns@" + TENANT_DOMAIN);
    User manager = checkpanic adClient->getUser("sandrawoosan@" + TENANT_DOMAIN);
    checkpanic adClient->assignManagerToUser(<@untainted>user, <@untainted>manager);
    User retrievedManager = checkpanic adClient->getManagerOfUser(<@untainted>user);
    test:assertEquals(retrievedManager.userPrincipalName, "sandrawoosan@" + TENANT_DOMAIN);
}

@test:Config {}
function deleteNonExistingUser() {
    User invalidUser = {
        displayName: "Arnold Wesker",
        userPrincipalName: "arnoldwesker@" + TENANT_DOMAIN,
        id: "648d7dae-f87d-44a4-b92f-eb2fd85ac52a"
    };
     AdClientError? deleteError = adClient->deleteUser(invalidUser);
     if (deleteError is AdClientError) {
        error? adError = deleteError.cause();
        if (adError is GraphAPIError) {
            test:assertEquals(adError.message(), "Resource 'arnoldwesker@" + TENANT_DOMAIN + "' does not " + 
                                                            "exist or one of its queried reference-property objects" +
                                                            " are not present.");
            test:assertEquals(adError.detail()["code"], "Request_ResourceNotFound");
        } else {
            test:assertFail("Invalid error type found");
        }
    } else {
        test:assertFail("User was not supposed to get created");
    }
}

@test:AfterSuite
function deleteTestUsersTest()  {
    User? createdUser1 = testUser1;
    if (createdUser1 is User) {
        checkpanic adClient->deleteUser(createdUser1);
    } else {
        test:assertFail("Test user1 was not created");
    }

    User? createdUser2 = testUser2;
    if (createdUser2 is User) {
        checkpanic adClient->deleteUser(createdUser2);
    } else {
        test:assertFail("Test user2 was not created");
    }

    User? createdUser3 = testUser3;
    if (createdUser3 is User) {
        checkpanic adClient->deleteUser(createdUser3);
    } else {
        test:assertFail("Test user3 was not created");
    }
}
