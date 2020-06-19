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

const AD_GRAPH_API_URL = "https://graph.microsoft.com/v1.0";

# The Client endpoint configuration for Azure Active Directory.
#
# + authHandler - Access token for the graph API or a handler for outbound traffic.
public type ClientConfiguration record {|
    http:OutboundAuthHandler authHandler;
|};

# Azure Active Directory Client
public type Client client object {
    private ClientConfiguration config;
    private http:Client graphClient;

    # Initialize a client.
    # 
    # + config - The configuration of the active directory client
    public function __init(ClientConfiguration config) {
        self.config = config;
        self.graphClient = new(AD_GRAPH_API_URL, {
            auth: {
                authHandler: config.authHandler
            }
        });
    }

    # Creates a new user in the active directory.
    # 
    # + newUser - New user entry
    # + return - Newly created User or error when creating it
    public remote function createUser(NewUser newUser) returns @tainted User|ADClientError {
        json newUserJson = checkpanic json.constructFrom(newUser);
        http:Response|error newUserResponseOrError = self.graphClient->post("/users/", newUserJson);
        if newUserResponseOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unable to connect to azure active directory", cause = newUserResponseOrError);
            return <@untainted>clientErr;
        }

        http:Response newUserResponse = <http:Response>newUserResponseOrError;
        json|error userJsonOrError = newUserResponse.getJsonPayload();

        if userJsonOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unknown payload format recieved", cause = userJsonOrError);
            return <@untainted>clientErr;
        }

        json userJson = <json>userJsonOrError;
        if newUserResponse.statusCode != 201 {
            GraphAPIError|InvalidErrorPayload graphAPIError = parseError(userJson);
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "error occurred creating user", cause = graphAPIError);
            return clientErr;
        }

        User|error userOrError = User.constructFrom(userJson);

        if userOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "error occurred converting user", cause = userOrError);
            return <@untainted>clientErr;
        }

        return <User>userOrError;
    }

    # Get users in the active directory.
    # 
    # + top - Maximum number of users to return
    # + filter - Filter users based on odata filtering
    # + return - The users or error when retrieving users
    public remote function getUsers(int top = 100, string filter = "") returns @tainted User[]|ADClientError {
        http:Response|error getUsersResponseOrError = self.graphClient->get(string `/users?$top=${top}&$filter=${filter}`);
        if getUsersResponseOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unable to connect to azure active directory", cause = getUsersResponseOrError);
            return <@untainted>clientErr;
        }

        http:Response getUsersResponse = <http:Response>getUsersResponseOrError;
        json|error usersJsonOrError = getUsersResponse.getJsonPayload();

        if usersJsonOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unknown payload format recieved", cause = usersJsonOrError);
            return <@untainted>clientErr;
        }

        json usersJson = <json>usersJsonOrError;
        if getUsersResponse.statusCode != 200 {
            GraphAPIError|InvalidErrorPayload graphAPIError = parseError(usersJson);
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "error occurred getting users", cause = graphAPIError);
            return clientErr;
        }

        json[] usersJsons = <json[]>checkpanic usersJson.value;
        User[] users = [];
        foreach json userJson in usersJsons {
            User|error userOrError = User.constructFrom(userJson);

            if userOrError is error {
                ADClientError clientErr = error(AD_CLIENT_ERROR, message = "error occurred converting user", cause = userOrError);
                return <@untainted>clientErr;
            }

            User user = <User>userOrError;
            users.push(user);
        }
        return <@untainted>users;
    }

    # Gets user from their ID.
    # 
    # + userID - Directory ID or User Principal Name of the user
    # + select - Additional fields to select from the user
    # + return - The user or error when retrieving the user
    public remote function getUser(string userID, string select = "") returns @tainted User|ADClientError {
        http:Response|error getUserResponseOrError = self.graphClient->get(string `/users/${userID}`);
        if getUserResponseOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unable to connect to azure active directory", cause = getUserResponseOrError);
            return <@untainted>clientErr;
        }

        http:Response getUserResponse = <http:Response>getUserResponseOrError;
        json|error userJsonOrError = getUserResponse.getJsonPayload();

        if userJsonOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unknown payload format recieved", cause = userJsonOrError);
            return <@untainted>clientErr;
        }

        json userJson = <json>userJsonOrError;
        if getUserResponse.statusCode != 200 {
            GraphAPIError|InvalidErrorPayload graphAPIError = parseError(userJson);
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "error occurred getting user", cause = graphAPIError);
            return clientErr;
        }

        json userSelectJson = {};
        if (select != "") {
            http:Response|error getUserSelectResponseOrError = self.graphClient->get(string `/users/${userID}?$select=${select}`);
            if getUserSelectResponseOrError is error {
                ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unable to connect to azure active directory", cause = getUserSelectResponseOrError);
                return <@untainted>clientErr;
            }

            http:Response getUserSelectResponse = <http:Response>getUserSelectResponseOrError;
            json|error userSelectJsonOrError = getUserSelectResponse.getJsonPayload();

            if userSelectJsonOrError is error {
                ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unknown payload format recieved", cause = userSelectJsonOrError);
                return <@untainted>clientErr;
            }

            userSelectJson = <json>userSelectJsonOrError;
            if getUserSelectResponse.statusCode != 200 {
                GraphAPIError|InvalidErrorPayload graphAPIError = parseError(userSelectJson);
                ADClientError clientErr = error(AD_CLIENT_ERROR, message = "error occurred getting user", cause = graphAPIError);
                return clientErr;
            }
        }

        User|error userOrError = User.constructFrom(checkpanic userJson.mergeJson(userSelectJson));

        if userOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "error occurred converting user", cause = userOrError);
            return <@untainted>clientErr;
        }

        return <User>userOrError;
    }

    # Get the current user.
    # 
    # + select - Additional fields to retrieve
    # + return - The current user or error when retrieve
    public remote function getCurrentUser(string select = "") returns @tainted User|ADClientError {
        http:Response|error getUserResponseOrError = self.graphClient->get("/me");
        if getUserResponseOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unable to connect to azure active directory", cause = getUserResponseOrError);
            return <@untainted>clientErr;
        }

        http:Response getUserResponse = <http:Response>getUserResponseOrError;
        json|error userJsonOrError = getUserResponse.getJsonPayload();

        if userJsonOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unknown payload format recieved", cause = userJsonOrError);
            return <@untainted>clientErr;
        }

        json userJson = <json>userJsonOrError;
        if getUserResponse.statusCode != 200 {
            GraphAPIError|InvalidErrorPayload graphAPIError = parseError(userJson);
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "error occurred getting current user", cause = graphAPIError);
            return clientErr;
        }

        json userSelectJson = {};
        if (select != "") {
            http:Response|error getUserSelectResponseOrError = self.graphClient->get(string `/me?$select=${select}`);
            if getUserSelectResponseOrError is error {
                ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unable to connect to azure active directory", cause = getUserSelectResponseOrError);
                return <@untainted>clientErr;
            }

            http:Response getUserSelectResponse = <http:Response>getUserSelectResponseOrError;
            json|error userSelectJsonOrError = getUserSelectResponse.getJsonPayload();

            if userSelectJsonOrError is error {
                ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unknown payload format recieved", cause = userSelectJsonOrError);
                return <@untainted>clientErr;
            }

            userSelectJson = <json>userSelectJsonOrError;
            if getUserSelectResponse.statusCode != 200 {
                GraphAPIError|InvalidErrorPayload graphAPIError = parseError(userSelectJson);
                ADClientError clientErr = error(AD_CLIENT_ERROR, message = "error occurred getting current user", cause = graphAPIError);
                return clientErr;
            }
        }

        User|error userOrError = User.constructFrom(checkpanic userJson.mergeJson(userSelectJson));

        if userOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "error occurred converting user", cause = userOrError);
            return <@untainted>clientErr;
        }

        return <User>userOrError;
    }

    # Assigns a manager to a user.
    # 
    # + user - The user
    # + manager - Manager of the user
    # + return - Error if occurred
    public remote function assignManagerToUser(User user, User manager) returns @tainted ADClientError? {
        json managerIDJson = {
            "@odata.id": string `https://graph.microsoft.com/v1.0/users/${manager.id}`
        };
        http:Response|error assignManagerResponseOrError = self.graphClient->put(string `/users/${user.id}/manager/$ref`, managerIDJson);

        if assignManagerResponseOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unable to connect to azure active directory", cause = assignManagerResponseOrError);
            return <@untainted>clientErr;
        }

        http:Response assignManagerResponse = <http:Response>assignManagerResponseOrError;
        if (assignManagerResponse.statusCode == 204) {
            return;
        }

        json|error assignManagerErrorJsonOrError = assignManagerResponse.getJsonPayload();

        if assignManagerErrorJsonOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unknown payload format recieved", cause = assignManagerErrorJsonOrError);
            return <@untainted>clientErr;
        }

        json assignErrorJson = <json>assignManagerErrorJsonOrError;
        GraphAPIError|InvalidErrorPayload graphAPIError = parseError(assignErrorJson);
        ADClientError clientErr = error(AD_CLIENT_ERROR, message = "error occurred assigning manager to user", cause = graphAPIError);
        return clientErr;
    }
    
    # Get the manager of a user.
    # 
    # + user - The user
    # + return - The manager or error when retrieve
    public remote function getManagerOfUser(User user) returns @tainted User|ADClientError {
        http:Response|error getManagerResponseOrError = self.graphClient->get(string `/users/${user.userPrincipalName}/manager`);
        if getManagerResponseOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unable to connect to azure active directory", cause = getManagerResponseOrError);
            return <@untainted>clientErr;
        }

        http:Response getManagerResponse = <http:Response>getManagerResponseOrError;
        json|error managerJsonOrError = getManagerResponse.getJsonPayload();

        if managerJsonOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unknown payload format recieved", cause = managerJsonOrError);
            return <@untainted>clientErr;
        }

        json managerJson = <json>managerJsonOrError;
        if getManagerResponse.statusCode != 200 {
            GraphAPIError|InvalidErrorPayload graphAPIError = parseError(managerJson);
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "error occurred getting manager of user", cause = graphAPIError);
            return clientErr;
        }

        User|error managerOrError = User.constructFrom(managerJson);

        if managerOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "error occurred converting user", cause = managerOrError);
            return <@untainted>clientErr;
        }

        return <User>managerOrError;
    }

    # Update the user.
    # 
    # + user - The User
    # + return - Error if occurred when retrieving
    public remote function updateUser(User user) returns @tainted ADClientError? {
        json userJson = checkpanic json.constructFrom(user);
        http:Response|error udpateUserResponseOrError = self.graphClient->patch(string `/users/${user.userPrincipalName}`, userJson);
        if udpateUserResponseOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unable to connect to azure active directory", cause = udpateUserResponseOrError);
            return <@untainted>clientErr;
        }

        http:Response udpateUserResponse = <http:Response>udpateUserResponseOrError;
        if (udpateUserResponse.statusCode == 204) {
            return;
        }

        json|error updateErrorJsonOrError = udpateUserResponse.getJsonPayload();

        if updateErrorJsonOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unknown payload format recieved", cause = updateErrorJsonOrError);
            return <@untainted>clientErr;
        }

        json updateErrorJson = <json>updateErrorJsonOrError;
        GraphAPIError|InvalidErrorPayload graphAPIError = parseError(updateErrorJson);
        ADClientError clientErr = error(AD_CLIENT_ERROR, message = "error occurred updating user", cause = graphAPIError);
        return clientErr;
    }

    # Delete the user.
    # 
    # + user - The user
    # + return - Error if occurred when retrieving
    public remote function deleteUser(User user) returns @tainted ADClientError? {
        http:Response|error deleteUserResponseOrError = self.graphClient->delete(string `/users/${user.userPrincipalName}`);

        if deleteUserResponseOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unable to connect to azure active directory", cause = deleteUserResponseOrError);
            return <@untainted>clientErr;
        }

        http:Response deleteUserResponse = <http:Response>deleteUserResponseOrError;
        if (deleteUserResponse.statusCode == 204) {
            return;
        }

        json|error deleteErrorJsonOrError = deleteUserResponse.getJsonPayload();

        if deleteErrorJsonOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unknown payload format recieved", cause = deleteErrorJsonOrError);
            return <@untainted>clientErr;
        }

        json deleteErrorJson = <json>deleteErrorJsonOrError;
        GraphAPIError|InvalidErrorPayload graphAPIError = parseError(deleteErrorJson);
        ADClientError clientErr = error(AD_CLIENT_ERROR, message = "error occurred deleting user", cause = graphAPIError);
        return clientErr;
    }

    # Creates a group
    # 
    # + newGroup - The new group to add
    # + return - The group or error when retrieving
    public remote function createGroup(NewGroup newGroup) returns @tainted Group|ADClientError {
        json newGroupJson = checkpanic json.constructFrom(newGroup);
        http:Response|error newGroupResponseOrError = self.graphClient->post("/groups/", newGroupJson);
        if newGroupResponseOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unable to connect to azure active directory", cause = newGroupResponseOrError);
            return <@untainted>clientErr;
        }

        http:Response newGroupResponse = <http:Response>newGroupResponseOrError;
        json|error groupJsonOrError = newGroupResponse.getJsonPayload();

        if groupJsonOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unknown payload format recieved", cause = groupJsonOrError);
            return <@untainted>clientErr;
        }

        json groupJson = <json>groupJsonOrError;
        if newGroupResponse.statusCode != 201 {
            GraphAPIError|InvalidErrorPayload graphAPIError = parseError(groupJson);
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "error occurred creating group", cause = graphAPIError);
            return clientErr;
        }

        Group|error groupOrError = Group.constructFrom(groupJson);

        if groupOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "error occurred converting group", cause = groupOrError);
            return <@untainted>clientErr;
        }

        return <Group>groupOrError;
    }

    # Get groups in active directory
    # 
    # + top - Number of results
    # + filter - OData filtering
    # + return - Groups or error when retrieving
    public remote function getGroups(int top = 100, string filter = "") returns @tainted Group[]|ADClientError {
        http:Response|error getGroupsResponseOrError = self.graphClient->get(string `/groups?$top=${top}&$filter=${filter}`);
        if getGroupsResponseOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unable to connect to azure active directory", cause = getGroupsResponseOrError);
            return <@untainted>clientErr;
        }

        http:Response getGroupsResponse = <http:Response>getGroupsResponseOrError;
        json|error groupsJsonOrError = getGroupsResponse.getJsonPayload();

        if groupsJsonOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unknown payload format recieved", cause = groupsJsonOrError);
            return <@untainted>clientErr;
        }

        json groupsJson = <json>groupsJsonOrError;
        if getGroupsResponse.statusCode != 200 {
            GraphAPIError|InvalidErrorPayload graphAPIError = parseError(groupsJson);
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "error occurred getting groups", cause = graphAPIError);
            return clientErr;
        }

        json[] groupsJsons = <json[]>checkpanic groupsJson.value;
        Group[] groups = [];
        foreach json groupJson in groupsJsons {
            Group|error grouprOrError = Group.constructFrom(groupJson);

            if grouprOrError is error {
                ADClientError clientErr = error(AD_CLIENT_ERROR, message = "error occurred converting group", cause = grouprOrError);
                return <@untainted>clientErr;
            }

            Group group = <Group>grouprOrError;
            groups.push(group);
        }
        return <@untainted>groups;
    }

    # Get Group by ID
    # 
    # + groupID - The group ID
    # + select - Additional fields to select
    # + return - The group or error when retrieving
    public remote function getGroup(string groupID, string select = "") returns @tainted Group|ADClientError {
        http:Response|error getGroupResponseOrError = self.graphClient->get(string `/groups/${groupID}`);
        if getGroupResponseOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unable to connect to azure active directory", cause = getGroupResponseOrError);
            return <@untainted>clientErr;
        }

        http:Response getGroupResponse = <http:Response>getGroupResponseOrError;
        json|error groupJsonOrError = getGroupResponse.getJsonPayload();

        if groupJsonOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unknown payload format recieved", cause = groupJsonOrError);
            return <@untainted>clientErr;
        }

        json groupJson = <json>groupJsonOrError;
        if getGroupResponse.statusCode != 200 {
            GraphAPIError|InvalidErrorPayload graphAPIError = parseError(groupJson);
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "error occurred getting group", cause = graphAPIError);
            return clientErr;
        }

        json groupSelectJson = {};
        if (select != "") {
            http:Response|error getGroupSelectResponseOrError = self.graphClient->get(string `/groups/${groupID}?$select=${select}`);
            if getGroupSelectResponseOrError is error {
                ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unable to connect to azure active directory", cause = getGroupSelectResponseOrError);
                return <@untainted>clientErr;
            }

            http:Response getGroupSelectResponse = <http:Response>getGroupSelectResponseOrError;
            json|error groupSelectJsonOrError = getGroupSelectResponse.getJsonPayload();

            if groupSelectJsonOrError is error {
                ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unknown payload format recieved", cause = groupSelectJsonOrError);
                return <@untainted>clientErr;
            }

            groupSelectJson = <json>groupSelectJsonOrError;
            if getGroupSelectResponse.statusCode != 200 {
                GraphAPIError|InvalidErrorPayload graphAPIError = parseError(groupSelectJson);
                ADClientError clientErr = error(AD_CLIENT_ERROR, message = "error occurred getting group", cause = graphAPIError);
                return clientErr;
            }
        }
        json finalGroupJson = checkpanic groupJson.mergeJson(groupSelectJson);
        Group|error groupOrError = Group.constructFrom(checkpanic groupJson.mergeJson(groupSelectJson));

        if groupOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "error occurred converting group", cause = groupOrError);
            return <@untainted>clientErr;
        }

        return <Group>groupOrError;
    }

    # Update a group
    # 
    # + group - The group to update
    # + return - Error if occurred when retrieving
    public remote function updateGroup(Group group) returns @tainted ADClientError? {
        json groupJson = checkpanic json.constructFrom(group);
        http:Response|error udpateGroupResponseOrError = self.graphClient->patch(string `/groups/${group.id}`, groupJson);
        if udpateGroupResponseOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unable to connect to azure active directory", cause = udpateGroupResponseOrError);
            return <@untainted>clientErr;
        }

        http:Response udpateGroupResponse = <http:Response>udpateGroupResponseOrError;
        if (udpateGroupResponse.statusCode == 204) {
            return;
        }

        json|error updateErrorJsonOrError = udpateGroupResponse.getJsonPayload();

        if updateErrorJsonOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unknown payload format recieved", cause = updateErrorJsonOrError);
            return <@untainted>clientErr;
        }

        json updateErrorJson = <json>updateErrorJsonOrError;
        GraphAPIError|InvalidErrorPayload graphAPIError = parseError(updateErrorJson);
        ADClientError clientErr = error(AD_CLIENT_ERROR, message = "error occurred updating group", cause = graphAPIError);
        return clientErr;
    }

    # Delete a group
    # 
    # + group - Group to delete
    # + return - Error if occurred when retrieving
    public remote function deleteGroup(Group group) returns @tainted ADClientError? {
        http:Response|error deleteGroupResponseOrError = self.graphClient->delete(string `/groups/${group.id}`);

        if deleteGroupResponseOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unable to connect to azure active directory", cause = deleteGroupResponseOrError);
            return <@untainted>clientErr;
        }

        http:Response deleteGroupResponse = <http:Response>deleteGroupResponseOrError;
        if (deleteGroupResponse.statusCode == 204) {
            return;
        }

        json|error deleteErrorJsonOrError = deleteGroupResponse.getJsonPayload();

        if deleteErrorJsonOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unknown payload format recieved", cause = deleteErrorJsonOrError);
            return <@untainted>clientErr;
        }

        json deleteErrorJson = <json>deleteErrorJsonOrError;
        GraphAPIError|InvalidErrorPayload graphAPIError = parseError(deleteErrorJson);
        ADClientError clientErr = error(AD_CLIENT_ERROR, message = "error occurred deleting group", cause = graphAPIError);
        return clientErr;
    }

    # Add a member to a group
    # 
    # + group - The group
    # + member - The member to be added to the group
    # + return - Error if occurred when retrieving
    public remote function addMemberToGroup(Group group, User|Group|Device member) returns @tainted ADClientError? {
        json memberIDJson = {
            "@odata.id": string `https://graph.microsoft.com/v1.0/directoryObjects/${member.id}`
        };
        http:Response|error addMemberResponseOrError = self.graphClient->post(string `/groups/${group.id}/members/$ref`, memberIDJson);

        if addMemberResponseOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unable to connect to azure active directory", cause = addMemberResponseOrError);
            return <@untainted>clientErr;
        }

        http:Response addMemberResponse = <http:Response>addMemberResponseOrError;
        if (addMemberResponse.statusCode == 204) {
            return;
        }

        json|error addMemberErrorJsonOrError = addMemberResponse.getJsonPayload();

        if addMemberErrorJsonOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unknown payload format recieved", cause = addMemberErrorJsonOrError);
            return <@untainted>clientErr;
        }

        json addMemberErrorJson = <json>addMemberErrorJsonOrError;
        GraphAPIError|InvalidErrorPayload graphAPIError = parseError(addMemberErrorJson);
        ADClientError clientErr = error(AD_CLIENT_ERROR, message = "error occurred adding member to group", cause = graphAPIError);
        return clientErr;
    }

    # Get members of a group.
    # 
    # + group - The group
    # + top - The number of results
    # + filter - OData filtering
    # + return - The members of the group or error when retrieving
    public remote function getGroupMembers(Group group, int top = 100, string filter = "") returns @tainted (User|Group|Device)[]|ADClientError {
        http:Response|error getMembersResponseOrError = self.graphClient->get(string `/groups/${group.id}/members?$top=${top}&$filter=${filter}`);
        if getMembersResponseOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unable to connect to azure active directory", cause = getMembersResponseOrError);
            return <@untainted>clientErr;
        }

        http:Response getMembersResponse = <http:Response>getMembersResponseOrError;
        json|error membersJsonOrError = getMembersResponse.getJsonPayload();

        if membersJsonOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unknown payload format recieved", cause = membersJsonOrError);
            return <@untainted>clientErr;
        }

        json membersJson = <json>membersJsonOrError;
        if getMembersResponse.statusCode != 200 {
            GraphAPIError|InvalidErrorPayload graphAPIError = parseError(membersJson);
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "error occurred getting users", cause = graphAPIError);
            return clientErr;
        }

        json[] membersJsons = <json[]>checkpanic membersJson.value;
        (User|Group|Device)[] members = [];
        foreach json memberJson in membersJsons {
            if (memberJson is map<json>) {
                if (memberJson["@odata.type"] == "#microsoft.graph.user") {
                    User|error userOrError = User.constructFrom(memberJson);

                    if userOrError is error {
                        ADClientError clientErr = error(AD_CLIENT_ERROR, message = "error occurred converting user", cause = userOrError);
                        return <@untainted>clientErr;
                    }

                    User user = <User>userOrError;
                    members.push(user);
                } else if (memberJson["@odata.type"] == "#microsoft.graph.group") {
                    Group|error groupOrError = Group.constructFrom(memberJson);

                    if groupOrError is error {
                        ADClientError clientErr = error(AD_CLIENT_ERROR, message = "error occurred converting group", cause = groupOrError);
                        return <@untainted>clientErr;
                    }

                    Group groupMember = <Group>groupOrError;
                    members.push(groupMember);
                } else if (memberJson["@odata.type"] == "#microsoft.graph.device") {
                    Device|error deviceOrError = Device.constructFrom(memberJson);

                    if deviceOrError is error {
                        ADClientError clientErr = error(AD_CLIENT_ERROR, message = "error occurred converting device", cause = deviceOrError);
                        return <@untainted>clientErr;
                    }

                    Device device = <Device>deviceOrError;
                    members.push(device);
                }
            }
        }
        return <@untainted>members;
    }

    # Remove a member of a group
    # 
    # + group - The group
    # + member - The emember to be removed
    # + return - Error if occurred
    public remote function removeMemberFromGroup(Group group, User|Group|Device member) returns @tainted ADClientError? {
        http:Response|error removeMemberResponseOrError = self.graphClient->delete(string `/groups/${group.id}/members/${member.id}/$ref`);

        if removeMemberResponseOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unable to connect to azure active directory", cause = removeMemberResponseOrError);
            return <@untainted>clientErr;
        }

        http:Response removeMemberResponse = <http:Response>removeMemberResponseOrError;
        if (removeMemberResponse.statusCode == 204) {
            return;
        }

        json|error removeMemberErrorJsonOrError = removeMemberResponse.getJsonPayload();

        if removeMemberErrorJsonOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unknown payload format recieved", cause = removeMemberErrorJsonOrError);
            return <@untainted>clientErr;
        }

        json removeMemberErrorJson = <json>removeMemberErrorJsonOrError;
        GraphAPIError|InvalidErrorPayload graphAPIError = parseError(removeMemberErrorJson);
        ADClientError clientErr = error(AD_CLIENT_ERROR, message = "error occurred deleting group", cause = graphAPIError);
        return clientErr;
    }

    # Add owner to a group.
    # 
    # + group - The group
    # + owner - New owner to be added
    # + return - Error if occurred
    public remote function addOwnerToGroup(Group group, User owner) returns @tainted ADClientError? {
        json ownerIDJson = {
            "@odata.id": string `https://graph.microsoft.com/v1.0/users/${owner.id}`
        };
        http:Response|error addOwnerResponseOrError = self.graphClient->post(string `/groups/${group.id}/owners/$ref`, ownerIDJson);

        if addOwnerResponseOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unable to connect to azure active directory", cause = addOwnerResponseOrError);
            return <@untainted>clientErr;
        }

        http:Response addOwnerResponse = <http:Response>addOwnerResponseOrError;
        if (addOwnerResponse.statusCode == 204) {
            return;
        }

        json|error addOwnerErrorJsonOrError = addOwnerResponse.getJsonPayload();

        if addOwnerErrorJsonOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unknown payload format recieved", cause = addOwnerErrorJsonOrError);
            return <@untainted>clientErr;
        }

        json addOwnerErrorJson = <json>addOwnerErrorJsonOrError;
        GraphAPIError|InvalidErrorPayload graphAPIError = parseError(addOwnerErrorJson);
        ADClientError clientErr = error(AD_CLIENT_ERROR, message = "error occurred adding owner to group", cause = graphAPIError);
        return clientErr;
    }

    # Get owners of a group.
    # 
    # + group - The group
    # + top - The number of owners
    # + filter - OData filering
    # + return - The owners or error occurred when retrieving
    public remote function getGroupOwners(Group group, int top = 100, string filter = "") returns @tainted User[]|ADClientError {
        http:Response|error getOwnersResponseOrError = self.graphClient->get(string `/groups/${group.id}/owners?$top=${top}&$filter=${filter}`);
        if getOwnersResponseOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unable to connect to azure active directory", cause = getOwnersResponseOrError);
            return <@untainted>clientErr;
        }

        http:Response getOwnersResponse = <http:Response>getOwnersResponseOrError;
        json|error ownersJsonOrError = getOwnersResponse.getJsonPayload();

        if ownersJsonOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unknown payload format recieved", cause = ownersJsonOrError);
            return <@untainted>clientErr;
        }

        json ownersJson = <json>ownersJsonOrError;
        if getOwnersResponse.statusCode != 200 {
            GraphAPIError|InvalidErrorPayload graphAPIError = parseError(ownersJson);
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "error occurred getting group owners", cause = graphAPIError);
            return clientErr;
        }

        json[] ownersJsonsMap = <json[]>checkpanic ownersJson.value;
        User[] owners = [];
        foreach json ownerJson in ownersJsonsMap {
            User|error userOrError = User.constructFrom(ownerJson);

            if userOrError is error {
                ADClientError clientErr = error(AD_CLIENT_ERROR, message = "error occurred converting user", cause = userOrError);
                return <@untainted>clientErr;
            }

            User owner = <User>userOrError;
            owners.push(owner);
        }
        return <@untainted>owners;
    }

    # Remove owner from a group.
    # 
    # + group - The group.
    # + owner - The owner to be removed
    # + return - Error if occurred when retriving
    public remote function removeOwnerFromGroup(Group group, User owner) returns @tainted ADClientError? {
        http:Response|error removeOwnerResponseOrError = self.graphClient->delete(string `/groups/${group.id}/owners/${owner.id}/$ref`);

        if removeOwnerResponseOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unable to connect to azure active directory", cause = removeOwnerResponseOrError);
            return <@untainted>clientErr;
        }

        http:Response removeOwnerResponse = <http:Response>removeOwnerResponseOrError;
        if (removeOwnerResponse.statusCode == 204) {
            return;
        }

        json|error removeOwnerErrorJsonOrError = removeOwnerResponse.getJsonPayload();

        if removeOwnerErrorJsonOrError is error {
            ADClientError clientErr = error(AD_CLIENT_ERROR, message = "unknown payload format recieved", cause = removeOwnerErrorJsonOrError);
            return <@untainted>clientErr;
        }

        json removeOwnerErrorJson = <json>removeOwnerErrorJsonOrError;
        GraphAPIError|InvalidErrorPayload graphAPIError = parseError(removeOwnerErrorJson);
        ADClientError clientErr = error(AD_CLIENT_ERROR, message = "error occurred deleting group owner", cause = graphAPIError);
        return clientErr;
    }
};
