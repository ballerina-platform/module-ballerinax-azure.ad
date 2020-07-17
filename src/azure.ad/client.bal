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
import ballerina/lang.'string as sutils;

public const AD_GRAPH_API_URL = "https://graph.microsoft.com/v1.0";

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
    public function init(ClientConfiguration config) {
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
    public remote function createUser(NewUser newUser) returns @tainted User|AdClientError {
        json newUserJson = checkpanic newUser.cloneWithType(json);
        http:Response|error newUserResponseOrError = self.graphClient->post("/users/", newUserJson);
        if newUserResponseOrError is error {
            return AdClientError("unable to connect to azure active directory", newUserResponseOrError);
        }

        http:Response newUserResponse = <http:Response>newUserResponseOrError;
        json|error userJsonOrError = newUserResponse.getJsonPayload();

        if userJsonOrError is error {
            return AdClientError("unknown payload format recieved", userJsonOrError);
        }

        json userJson = <json>userJsonOrError;
        if newUserResponse.statusCode != 201 {
            return AdClientError("error occurred creating user", parseError(userJson));
        }

        User|error userOrError = userJson.cloneWithType(User);

        if userOrError is error {
            return AdClientError("error occurred converting user", userOrError);
        }

        return <User>userOrError;
    }

    # Get users in the active directory.
    # 
    # // Pagination implementation
    # + top - Maximum number of users to return
    # + filter - Filter users based on odata filtering
    # + return - The users or error when retrieving users
    public remote function getUsers(public int top = 100, public string filter = "") returns @tainted User[]|AdClientError {
        http:Response|error getUsersResponseOrError = self.graphClient->get(string `/users?$top=${top}&$filter=${filter}`);
        if getUsersResponseOrError is error {
            return AdClientError("unable to connect to azure active directory", getUsersResponseOrError);
        }

        http:Response getUsersResponse = <http:Response>getUsersResponseOrError;
        json|error usersJsonOrError = getUsersResponse.getJsonPayload();

        if usersJsonOrError is error {
            return AdClientError("unknown payload format recieved", usersJsonOrError);
        }

        json usersJson = <json>usersJsonOrError;
        if getUsersResponse.statusCode != 200 {
            GraphAPIError|InvalidPayloadError graphAPIError = parseError(usersJson);
            return AdClientError("error occurred getting users", graphAPIError);
        }

        json[] usersJsons = <json[]>checkpanic usersJson.value;
        User[] users = [];
        foreach json userJson in usersJsons {
            User|error userOrError = userJson.cloneWithType(User);

            if userOrError is error {
                return AdClientError("error occurred converting user", userOrError);
            }

            User user = <User>userOrError;
            users.push(user);
        }
        return <@untainted>users;
    }

    # Gets user from their ID.
    # 
    # + userID - User ID or User Principal Name of the user
    # + additionalFields - Additional fields to select from the user
    # + return - The user or error when retrieving the user
    public remote function getUser(string userID, public string[] additionalFields = []) returns @tainted User|AdClientError {
        http:Response|error getUserResponseOrError = self.graphClient->get(string `/users/${userID}`);
        if getUserResponseOrError is error {
            return AdClientError("unable to connect to azure active directory", getUserResponseOrError);
        }

        http:Response getUserResponse = <http:Response>getUserResponseOrError;
        json|error userJsonOrError = getUserResponse.getJsonPayload();

        if userJsonOrError is error {
            return AdClientError("unknown payload format recieved", userJsonOrError);
        }

        json userJson = <json>userJsonOrError;
        if getUserResponse.statusCode != 200 {
            GraphAPIError|InvalidPayloadError graphAPIError = parseError(userJson);
            return AdClientError("error occurred getting user", graphAPIError);
        }

        json userSelectJson = {};
        if (additionalFields != []) {
            string selectFields = sutils:'join(",", ...additionalFields);

            http:Response|error getUserSelectResponseOrError = self.graphClient->get(string `/users/${userID}?$select=${selectFields}`);
            if getUserSelectResponseOrError is error {
                return AdClientError("unable to connect to azure active directory", getUserSelectResponseOrError);
            }

            http:Response getUserSelectResponse = <http:Response>getUserSelectResponseOrError;
            json|error userSelectJsonOrError = getUserSelectResponse.getJsonPayload();

            if userSelectJsonOrError is error {
                return AdClientError("unknown payload format recieved", userSelectJsonOrError);
            }

            userSelectJson = <json>userSelectJsonOrError;
            if getUserSelectResponse.statusCode != 200 {
                GraphAPIError|InvalidPayloadError graphAPIError = parseError(userSelectJson);
                return AdClientError("error occurred getting user", graphAPIError);
            }
            map<json> userSelectJsonMap = <map<json>>userSelectJson;
            _ = userSelectJsonMap.remove("@odata.context");
            userSelectJson = userSelectJsonMap;
        }

        User|error userOrError = (checkpanic userJson.mergeJson(userSelectJson)).cloneWithType(User);

        if userOrError is error {
            return AdClientError("error occurred converting user", userOrError);
        }

        return <User>userOrError;
    }

    # Get the current user.
    # 
    # + additionalFields - Additional fields to retrieve
    # + return - The current user or error when retrieve
    public remote function getCurrentUser(public string[] additionalFields = []) returns @tainted User|AdClientError {
        http:Response|error getUserResponseOrError = self.graphClient->get("/me");
        if getUserResponseOrError is error {
            return AdClientError("unable to connect to azure active directory", getUserResponseOrError);
        }

        http:Response getUserResponse = <http:Response>getUserResponseOrError;
        json|error userJsonOrError = getUserResponse.getJsonPayload();

        if userJsonOrError is error {
            return AdClientError("unknown payload format recieved", userJsonOrError);
        }

        json userJson = <json>userJsonOrError;
        if getUserResponse.statusCode != 200 {
            GraphAPIError|InvalidPayloadError graphAPIError = parseError(userJson);
            return AdClientError("error occurred getting current user", graphAPIError);
        }

        json userSelectJson = {};
        if (additionalFields != []) {
            string selectFields = sutils:'join(",", ...additionalFields);

            http:Response|error getUserSelectResponseOrError = self.graphClient->get(string `/me?$select=${selectFields}`);
            if getUserSelectResponseOrError is error {
                return AdClientError("unable to connect to azure active directory", getUserSelectResponseOrError);
            }

            http:Response getUserSelectResponse = <http:Response>getUserSelectResponseOrError;
            json|error userSelectJsonOrError = getUserSelectResponse.getJsonPayload();

            if userSelectJsonOrError is error {
                return AdClientError("unknown payload format recieved", userSelectJsonOrError);
            }

            userSelectJson = <json>userSelectJsonOrError;
            if getUserSelectResponse.statusCode != 200 {
                GraphAPIError|InvalidPayloadError graphAPIError = parseError(userSelectJson);
                return AdClientError("error occurred getting current user", graphAPIError);
            }

            map<json> userSelectJsonMap = <map<json>>userSelectJson;
            _ = userSelectJsonMap.remove("@odata.context");
            userSelectJson = userSelectJsonMap;
        }
        User|error userOrError = (checkpanic userJson.mergeJson(userSelectJson)).cloneWithType(User);

        if userOrError is error {
            return AdClientError("error occurred converting user", userOrError);
        }

        return <User>userOrError;
    }

    # Assigns a manager to a user.
    # 
    # + user - The user
    # + manager - Manager of the user
    # + return - Error if occurred
    public remote function assignManagerToUser(User user, User manager) returns @tainted AdClientError? {
        json managerIDJson = {
            "@odata.id": string `https://graph.microsoft.com/v1.0/users/${manager.id}`
        };
        http:Response|error assignManagerResponseOrError = self.graphClient->put(string `/users/${user.id}/manager/$ref`, managerIDJson);

        if assignManagerResponseOrError is error {
            return AdClientError("unable to connect to azure active directory", assignManagerResponseOrError);
        }

        http:Response assignManagerResponse = <http:Response>assignManagerResponseOrError;
        if (assignManagerResponse.statusCode == 204) {
            return;
        }

        json|error assignManagerErrorJsonOrError = assignManagerResponse.getJsonPayload();

        if assignManagerErrorJsonOrError is error {
            return AdClientError("unknown payload format recieved", assignManagerErrorJsonOrError);
        }

        json assignErrorJson = <json>assignManagerErrorJsonOrError;
        GraphAPIError|InvalidPayloadError graphAPIError = parseError(assignErrorJson);
        return AdClientError("error occurred assigning manager to user", graphAPIError);
    }
    
    # Get the manager of a user.
    # 
    # + user - The user
    # + return - The manager or error when retrieve
    public remote function getManagerOfUser(User user) returns @tainted User|AdClientError {
        http:Response|error getManagerResponseOrError = self.graphClient->get(string `/users/${user.userPrincipalName}/manager`);
        if getManagerResponseOrError is error {
            return AdClientError("unable to connect to azure active directory", getManagerResponseOrError);
        }

        http:Response getManagerResponse = <http:Response>getManagerResponseOrError;
        json|error managerJsonOrError = getManagerResponse.getJsonPayload();

        if managerJsonOrError is error {
            return AdClientError("unknown payload format recieved", managerJsonOrError);
        }

        json managerJson = <json>managerJsonOrError;
        if getManagerResponse.statusCode != 200 {
            GraphAPIError|InvalidPayloadError graphAPIError = parseError(managerJson);
            return AdClientError("error occurred getting manager of user", graphAPIError);
        }

        User|error managerOrError = managerJson.cloneWithType(User);

        if managerOrError is error {
            return AdClientError("error occurred converting user", managerOrError);
        }

        return <User>managerOrError;
    }

    # Update the user.
    # 
    # + user - The User
    # + return - Error if occurred when retrieving
    public remote function updateUser(User user) returns @tainted AdClientError? {
        json userJson = checkpanic user.cloneWithType(json);
        http:Response|error udpateUserResponseOrError = self.graphClient->patch(string `/users/${user.userPrincipalName}`, userJson);
        if udpateUserResponseOrError is error {
            return AdClientError("unable to connect to azure active directory", udpateUserResponseOrError);
        }

        http:Response udpateUserResponse = <http:Response>udpateUserResponseOrError;
        if (udpateUserResponse.statusCode == 204) {
            return;
        }

        json|error updateErrorJsonOrError = udpateUserResponse.getJsonPayload();

        if updateErrorJsonOrError is error {
            return AdClientError("unknown payload format recieved", updateErrorJsonOrError);
        }

        json updateErrorJson = <json>updateErrorJsonOrError;
        GraphAPIError|InvalidPayloadError graphAPIError = parseError(updateErrorJson);
        return AdClientError("error occurred updating user", graphAPIError);
    }

    # Delete the user.
    # 
    # + user - The user
    # + return - Error if occurred when retrieving
    public remote function deleteUser(User user) returns @tainted AdClientError? {
        http:Response|error deleteUserResponseOrError = self.graphClient->delete(string `/users/${user.userPrincipalName}`);

        if deleteUserResponseOrError is error {
            return AdClientError("unable to connect to azure active directory", deleteUserResponseOrError);
        }

        http:Response deleteUserResponse = <http:Response>deleteUserResponseOrError;
        if (deleteUserResponse.statusCode == 204) {
            return;
        }

        json|error deleteErrorJsonOrError = deleteUserResponse.getJsonPayload();

        if deleteErrorJsonOrError is error {
            return AdClientError("unknown payload format recieved", deleteErrorJsonOrError);
        }

        json deleteErrorJson = <json>deleteErrorJsonOrError;
        GraphAPIError|InvalidPayloadError graphAPIError = parseError(deleteErrorJson);
        return AdClientError("error occurred deleting user", graphAPIError);
    }

    # Creates a group
    # 
    # + newGroup - The new group to add
    # + return - The group or error when retrieving
    public remote function createGroup(NewGroup newGroup) returns @tainted Group|AdClientError {
        json newGroupJson = checkpanic newGroup.cloneWithType(json);
        http:Response|error newGroupResponseOrError = self.graphClient->post("/groups/", newGroupJson);
        if newGroupResponseOrError is error {
            return AdClientError("unable to connect to azure active directory", newGroupResponseOrError);
        }

        http:Response newGroupResponse = <http:Response>newGroupResponseOrError;
        json|error groupJsonOrError = newGroupResponse.getJsonPayload();

        if groupJsonOrError is error {
            return AdClientError("unknown payload format recieved", groupJsonOrError);
        }

        json groupJson = <json>groupJsonOrError;
        if newGroupResponse.statusCode != 201 {
            GraphAPIError|InvalidPayloadError graphAPIError = parseError(groupJson);
            return AdClientError("error occurred creating group", graphAPIError);
        }

        Group|error groupOrError = groupJson.cloneWithType(Group);

        if groupOrError is error {
            return AdClientError("error occurred converting group", groupOrError);
        }

        return <Group>groupOrError;
    }

    # Get groups in active directory
    # 
    # + top - Number of results
    # + filter - OData filtering
    # + return - Groups or error when retrieving
    public remote function getGroups(public int top = 100, public string filter = "") returns @tainted Group[]|AdClientError {
        http:Response|error getGroupsResponseOrError = self.graphClient->get(string `/groups?$top=${top}&$filter=${filter}`);
        if getGroupsResponseOrError is error {
            return AdClientError("unable to connect to azure active directory", getGroupsResponseOrError);
        }

        http:Response getGroupsResponse = <http:Response>getGroupsResponseOrError;
        json|error groupsJsonOrError = getGroupsResponse.getJsonPayload();

        if groupsJsonOrError is error {
            return AdClientError("unknown payload format recieved", groupsJsonOrError);
        }

        json groupsJson = <json>groupsJsonOrError;
        if getGroupsResponse.statusCode != 200 {
            GraphAPIError|InvalidPayloadError graphAPIError = parseError(groupsJson);
            return AdClientError("error occurred getting groups", graphAPIError);
        }

        json[] groupsJsons = <json[]>checkpanic groupsJson.value;
        Group[] groups = [];
        foreach json groupJson in groupsJsons {
            Group|error grouprOrError = groupJson.cloneWithType(Group);

            if grouprOrError is error {
                return AdClientError("error occurred converting group", grouprOrError);
            }

            Group group = <Group>grouprOrError;
            groups.push(group);
        }
        return <@untainted>groups;
    }

    # Get Group by ID
    # 
    # + groupID - The group ID
    # + additionalFields - Additional fields to select
    # + return - The group or error when retrieving
    public remote function getGroup(string groupID, public string[] additionalFields = []) returns @tainted Group|AdClientError {
        http:Response|error getGroupResponseOrError = self.graphClient->get(string `/groups/${groupID}`);
        if getGroupResponseOrError is error {
            return AdClientError("unable to connect to azure active directory", getGroupResponseOrError);
        }

        http:Response getGroupResponse = <http:Response>getGroupResponseOrError;
        json|error groupJsonOrError = getGroupResponse.getJsonPayload();

        if groupJsonOrError is error {
            return AdClientError("unknown payload format recieved", groupJsonOrError);
        }

        json groupJson = <json>groupJsonOrError;
        if getGroupResponse.statusCode != 200 {
            GraphAPIError|InvalidPayloadError graphAPIError = parseError(groupJson);
            return AdClientError("error occurred getting group", graphAPIError);
        }

        json groupSelectJson = {};
        if (additionalFields != []) {
            string selectFields = sutils:'join(",", ...additionalFields);

            http:Response|error getGroupSelectResponseOrError = self.graphClient->get(string `/groups/${groupID}?$select=${selectFields}`);
            if getGroupSelectResponseOrError is error {
                return AdClientError("unable to connect to azure active directory", getGroupSelectResponseOrError);
            }

            http:Response getGroupSelectResponse = <http:Response>getGroupSelectResponseOrError;
            json|error groupSelectJsonOrError = getGroupSelectResponse.getJsonPayload();

            if groupSelectJsonOrError is error {
                return AdClientError("unknown payload format recieved", groupSelectJsonOrError);
            }

            groupSelectJson = <json>groupSelectJsonOrError;
            if getGroupSelectResponse.statusCode != 200 {
                GraphAPIError|InvalidPayloadError graphAPIError = parseError(groupSelectJson);
                return AdClientError("error occurred getting group", graphAPIError);
            }
            map<json> groupSelectJsonMap = <map<json>>groupSelectJson;
            _ = groupSelectJsonMap.remove("@odata.context");
            groupSelectJson = groupSelectJsonMap;
        }

        Group|error groupOrError = (checkpanic groupJson.mergeJson(groupSelectJson)).cloneWithType(Group);

        if groupOrError is error {
            return AdClientError("error occurred converting group", groupOrError);
        }

        return <Group>groupOrError;
    }

    # Update a group
    # 
    # + group - The group to update
    # + return - Error if occurred when retrieving
    public remote function updateGroup(Group group) returns @tainted AdClientError? {
        json groupJson = checkpanic group.cloneWithType(json);
        http:Response|error udpateGroupResponseOrError = self.graphClient->patch(string `/groups/${group.id}`, groupJson);
        if udpateGroupResponseOrError is error {
            return AdClientError("unable to connect to azure active directory", udpateGroupResponseOrError);
        }

        http:Response udpateGroupResponse = <http:Response>udpateGroupResponseOrError;
        if (udpateGroupResponse.statusCode == 204) {
            return;
        }

        json|error updateErrorJsonOrError = udpateGroupResponse.getJsonPayload();

        if updateErrorJsonOrError is error {
            return AdClientError("unknown payload format recieved", updateErrorJsonOrError);
        }

        json updateErrorJson = <json>updateErrorJsonOrError;
        GraphAPIError|InvalidPayloadError graphAPIError = parseError(updateErrorJson);
        return AdClientError("error occurred updating group", graphAPIError);
    }

    # Delete a group
    # 
    # + group - Group to delete
    # + return - Error if occurred when retrieving
    public remote function deleteGroup(Group group) returns @tainted AdClientError? {
        http:Response|error deleteGroupResponseOrError = self.graphClient->delete(string `/groups/${group.id}`);

        if deleteGroupResponseOrError is error {
            return AdClientError("unable to connect to azure active directory", deleteGroupResponseOrError);
        }

        http:Response deleteGroupResponse = <http:Response>deleteGroupResponseOrError;
        if (deleteGroupResponse.statusCode == 204) {
            return;
        }

        json|error deleteErrorJsonOrError = deleteGroupResponse.getJsonPayload();

        if deleteErrorJsonOrError is error {
            return AdClientError("unknown payload format recieved", deleteErrorJsonOrError);
        }

        json deleteErrorJson = <json>deleteErrorJsonOrError;
        GraphAPIError|InvalidPayloadError graphAPIError = parseError(deleteErrorJson);
        return AdClientError("error occurred deleting group", graphAPIError);
    }

    # Add a member to a group
    # 
    # + group - The group
    # + member - The member to be added to the group
    # + return - Error if occurred when retrieving
    public remote function addMemberToGroup(Group group, User|Group|Device member) returns @tainted AdClientError? {
        json memberIDJson = {
            "@odata.id": string `https://graph.microsoft.com/v1.0/directoryObjects/${member.id}`
        };
        http:Response|error addMemberResponseOrError = self.graphClient->post(string `/groups/${group.id}/members/$ref`, memberIDJson);

        if addMemberResponseOrError is error {
            return AdClientError("unable to connect to azure active directory", addMemberResponseOrError);
        }

        http:Response addMemberResponse = <http:Response>addMemberResponseOrError;
        if (addMemberResponse.statusCode == 204) {
            return;
        }

        json|error addMemberErrorJsonOrError = addMemberResponse.getJsonPayload();

        if addMemberErrorJsonOrError is error {
            return AdClientError("unknown payload format recieved", addMemberErrorJsonOrError);
        }

        json addMemberErrorJson = <json>addMemberErrorJsonOrError;
        GraphAPIError|InvalidPayloadError graphAPIError = parseError(addMemberErrorJson);
        return AdClientError("error occurred deleting group", graphAPIError);
    }

    # Get members of a group.
    # 
    # + group - The group
    # + top - The number of results
    # + filter - OData filtering
    # + return - The members of the group or error when retrieving
    public remote function getGroupMembers(Group group, public int top = 100, public string filter = "") returns @tainted (User|Group|Device)[]|AdClientError {
        http:Response|error getMembersResponseOrError = self.graphClient->get(string `/groups/${group.id}/members?$top=${top}&$filter=${filter}`);
        if getMembersResponseOrError is error {
            return AdClientError("unable to connect to azure active directory", getMembersResponseOrError);
        }

        http:Response getMembersResponse = <http:Response>getMembersResponseOrError;
        json|error membersJsonOrError = getMembersResponse.getJsonPayload();

        if membersJsonOrError is error {
            return AdClientError("unknown payload format recieved", membersJsonOrError);
        }

        json membersJson = <json>membersJsonOrError;
        if getMembersResponse.statusCode != 200 {
            GraphAPIError|InvalidPayloadError graphAPIError = parseError(membersJson);
            return AdClientError("error occurred getting users", graphAPIError);
        }

        json[] membersJsons = <json[]>checkpanic membersJson.value;
        (User|Group|Device)[] members = [];
        foreach json memberJson in membersJsons {
            if (memberJson is map<json>) {
                if (memberJson["@odata.type"] == "#microsoft.graph.user") {
                    User|error userOrError = memberJson.cloneWithType(User);

                    if userOrError is error {
                        return AdClientError("error occurred converting user", userOrError);
                    }

                    User user = <User>userOrError;
                    members.push(user);
                } else if (memberJson["@odata.type"] == "#microsoft.graph.group") {
                    Group|error groupOrError = memberJson.cloneWithType(Group);

                    if groupOrError is error {
                        return AdClientError("error occurred converting group", groupOrError);
                    }

                    Group groupMember = <Group>groupOrError;
                    members.push(groupMember);
                } else if (memberJson["@odata.type"] == "#microsoft.graph.device") {
                    Device|error deviceOrError = memberJson.cloneWithType(Device);

                    if deviceOrError is error {
                        return AdClientError("error occurred converting device", deviceOrError);
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
    # + member - The member to be removed
    # + return - Error if occurred
    public remote function removeMemberFromGroup(Group group, User|Group|Device member) returns @tainted AdClientError? {
        http:Response|error removeMemberResponseOrError = self.graphClient->delete(string `/groups/${group.id}/members/${member.id}/$ref`);

        if removeMemberResponseOrError is error {
            return AdClientError("unable to connect to azure active directory", removeMemberResponseOrError);
        }

        http:Response removeMemberResponse = <http:Response>removeMemberResponseOrError;
        if (removeMemberResponse.statusCode == 204) {
            return;
        }

        json|error removeMemberErrorJsonOrError = removeMemberResponse.getJsonPayload();

        if removeMemberErrorJsonOrError is error {
            return AdClientError("unknown payload format recieved", removeMemberErrorJsonOrError);
        }

        json removeMemberErrorJson = <json>removeMemberErrorJsonOrError;
        GraphAPIError|InvalidPayloadError graphAPIError = parseError(removeMemberErrorJson);
        return AdClientError("error occurred deleting group", graphAPIError);
    }

    # Add owner to a group.
    # 
    # + group - The group
    # + owner - New owner to be added
    # + return - Error if occurred
    public remote function addOwnerToGroup(Group group, User owner) returns @tainted AdClientError? {
        json ownerIDJson = {
            "@odata.id": string `https://graph.microsoft.com/v1.0/users/${owner.id}`
        };
        http:Response|error addOwnerResponseOrError = self.graphClient->post(string `/groups/${group.id}/owners/$ref`, ownerIDJson);

        if addOwnerResponseOrError is error {
            return AdClientError("unable to connect to azure active directory", addOwnerResponseOrError);
        }

        http:Response addOwnerResponse = <http:Response>addOwnerResponseOrError;
        if (addOwnerResponse.statusCode == 204) {
            return;
        }

        json|error addOwnerErrorJsonOrError = addOwnerResponse.getJsonPayload();

        if addOwnerErrorJsonOrError is error {
            return AdClientError("unknown payload format recieved", addOwnerErrorJsonOrError);
        }

        json addOwnerErrorJson = <json>addOwnerErrorJsonOrError;
        GraphAPIError|InvalidPayloadError graphAPIError = parseError(addOwnerErrorJson);
        return AdClientError("error occurred adding owner to group", graphAPIError);
    }

    # Get owners of a group.
    # 
    # + group - The group
    # + top - The number of owners
    # + filter - OData filtering
    # + return - The owners or error occurred when retrieving
    public remote function getGroupOwners(Group group, public int top = 100, public string filter = "") returns @tainted User[]|AdClientError {
        http:Response|error getOwnersResponseOrError = self.graphClient->get(string `/groups/${group.id}/owners?$top=${top}&$filter=${filter}`);
        if getOwnersResponseOrError is error {
            return AdClientError("unable to connect to azure active directory", getOwnersResponseOrError);
        }

        http:Response getOwnersResponse = <http:Response>getOwnersResponseOrError;
        json|error ownersJsonOrError = getOwnersResponse.getJsonPayload();

        if ownersJsonOrError is error {
            return AdClientError("unknown payload format recieved", ownersJsonOrError);
        }

        json ownersJson = <json>ownersJsonOrError;
        if getOwnersResponse.statusCode != 200 {
            GraphAPIError|InvalidPayloadError graphAPIError = parseError(ownersJson);
            return AdClientError("error occurred getting group owners", graphAPIError);
        }

        json[] ownersJsonsMap = <json[]>checkpanic ownersJson.value;
        User[] owners = [];
        foreach json ownerJson in ownersJsonsMap {
            User|error userOrError = ownerJson.cloneWithType(User);

            if userOrError is error {
                return AdClientError("error occurred converting user", userOrError);
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
    # + return - Error if occurred when retrieving
    public remote function removeOwnerFromGroup(Group group, User owner) returns @tainted AdClientError? {
        http:Response|error removeOwnerResponseOrError = self.graphClient->delete(string `/groups/${group.id}/owners/${owner.id}/$ref`);

        if removeOwnerResponseOrError is error {
            return AdClientError("unable to connect to azure active directory", removeOwnerResponseOrError);
        }

        http:Response removeOwnerResponse = <http:Response>removeOwnerResponseOrError;
        if (removeOwnerResponse.statusCode == 204) {
            return;
        }

        json|error removeOwnerErrorJsonOrError = removeOwnerResponse.getJsonPayload();

        if removeOwnerErrorJsonOrError is error {
            return AdClientError("unknown payload format recieved", removeOwnerErrorJsonOrError);
        }

        json removeOwnerErrorJson = <json>removeOwnerErrorJsonOrError;
        GraphAPIError|InvalidPayloadError graphAPIError = parseError(removeOwnerErrorJson);
        return AdClientError("error occurred deleting group owner", graphAPIError);
    }
};
