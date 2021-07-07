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
//import ballerina/io;

# Azure AD Client Object for executing drive operations.
# 
# + httpClient - the HTTP Client
@display {
    label: "Azure AD Client", 
    iconPath: "MSAzureADLogo.svg"
}
public client class Client {
    http:Client httpClient;

    public isolated function init(Configuration config) returns error? {
        http:BearerTokenConfig|http:OAuth2RefreshTokenGrantConfig clientConfig = config.clientConfig;
        http:ClientSecureSocket? socketConfig = config?.secureSocketConfig;
        self.httpClient = check new (BASE_URL, {
            auth: clientConfig,
            secureSocket: socketConfig
        });
    }

    // ************************************* Operations on a User resource *********************************************
    // Represents an Azure AD user account.

    # Create a new user.
    # 
    # + info - The basic information about a user
    # + return - A record of type `User` if sucess. Else `Error`.
    @display {label: "Create User"}
    remote isolated function createUser(@display {label: "New User Information"} NewUser info) returns 
                                        @tainted User|Error {
        string path = check createUrl([USERS]);
        json payload = check info.cloneWithType(json);
        return check self.httpClient->post(path, payload, targetType = User);
    }

    # Get information about a user.
    # 
    # + userId - The object ID if the user
    # + queryParams - Optional query parameters. This method support OData query parameters to customize the response.
    #                 It should be an array of type `string` in the format `<QUERY_PARAMETER_NAME>=<PARAMETER_VALUE>`
    #                 **Note:** For more information about query parameters, refer here: 
    #                   https://docs.microsoft.com/en-us/graph/query-parameters
    # + return - A record of type `User` if sucess. Else `Error`.
    @display {label: "Get User"}
    remote isolated function getUser(@display {label: "User ID"} string userId, 
                                     @display {label: "Optional Query Parameters"} string[] queryParams = []) 
                                     returns @tainted User|error {
        string path = check createUrl([USERS, userId], queryParams);   
        return check self.httpClient->get(path, targetType = User);
    }

    # Update information about a user.
    # 
    # + userId - The object ID if the user
    # + info - The information to update
    # + return - `nil` if sucess. Else `Error`.
    @display {label: "Update User"}
    remote isolated function updateUser(@display {label: "User ID"} string userId, 
                                        @display {label: "User Update Information"} UpdateUser info) 
                                        returns @tainted Error? {
        string path = check createUrl([USERS, userId]); 
        json payload = check info.cloneWithType(json);   
        http:Response response = check self.httpClient->patch(path, payload);
        _ = check handleResponse(response);
    }

    # List information about users.
    # 
    # + queryParams - Optional query parameters. This method support OData query parameters to customize the response.
    #                 It should be an array of type `string` in the format `<QUERY_PARAMETER_NAME>=<PARAMETER_VALUE>`
    #                 **Note:** For more information about query parameters, refer here: 
    #                   https://docs.microsoft.com/en-us/graph/query-parameters
    # + return - A stream of type `User` if sucess. Else `Error`.
    @display {label: "List Users"}
    remote isolated function listUsers(@display {label: "Optional Query Parameters"} string[] queryParams = []) 
                                       returns @tainted stream<User, Error>|Error {
        string path = check createUrl([USERS], queryParams);
        http:Response response = check self.httpClient->get(path);

        map<json>|string handledResponse = check handleResponse(response);
        UserStream objectInstance = check new (self.httpClient, path);
        stream<User, Error> finalStream = new (objectInstance);
        return finalStream; 
    }

    # Delete a user
    # 
    # + userId - The object ID if the user
    # + return - `nil` if sucess. Else `Error`.
    @display {label: "Delete User"}
    remote isolated function deleteUser(@display {label: "User ID"} string userId) returns @tainted Error? {
        string path = check createUrl([USERS, userId]); 
        http:Response response = check self.httpClient->delete(path);
        _ = check handleResponse(response);    
    }

    // ************************************* Operations on a Group resource ********************************************
    // Represents an Azure Active Directory (Azure AD) group, which can be a Microsoft 365 group, or a security group.

    # Create a new group.
    # 
    # + info - The basic information about a group
    # + return - A record of type `Group` if sucess. Else `Error`.
    @display {label: "Create Group"}
    remote isolated function createGroup(@display {label: "New Group Information"} NewGroup info) 
                                         returns @tainted Group|Error {
        string path = check createUrl([GROUPS]);
        json payload = check convertNewGroupToJson(info);
        return check self.httpClient->post(path, payload, targetType = Group);
    }

    # Get information about a group.
    # 
    # + groupId - The object ID if the group
    # + queryParams - Optional query parameters. This method support OData query parameters to customize the response.
    #                 It should be an array of type `string` in the format `<QUERY_PARAMETER_NAME>=<PARAMETER_VALUE>`
    #                 **Note:** For more information about query parameters, refer here: 
    #                   https://docs.microsoft.com/en-us/graph/query-parameters
    # + return - A record of type `User` if sucess. Else `Error`.
    @display {label: "Get Group"}
    remote isolated function getGroup(@display {label: "Group ID"} string groupId, 
                                      @display {label: "Optional Query Parameters"} string[] queryParams = []) 
                                      returns @tainted Group|error {
        string path = check createUrl([GROUPS, groupId], queryParams);   
        return check self.httpClient->get(path, targetType = Group);
    }

    # Update information about a group.
    # 
    # + groupId - The object ID if the group
    # + info - The information to update
    # + return - `nil` if sucess. Else `Error`.
    @display {label: "Update Group"}
    remote isolated function updateGroup(@display {label: "Group ID"} string groupId, 
                                         @display {label: "Group Update Information"}  UpdateGroup info) 
                                         returns @tainted Error? {
        string path = check createUrl([GROUPS, groupId]); 
        json payload = check info.cloneWithType(json); 
        http:Response response = check self.httpClient->patch(path, payload);
        _ = check handleResponse(response);
  
    }

    # List information about groups.
    # 
    # + queryParams - Optional query parameters. This method support OData query parameters to customize the response.
    #                 It should be an array of type `string` in the format `<QUERY_PARAMETER_NAME>=<PARAMETER_VALUE>`
    #                 **Note:** For more information about query parameters, refer here: 
    #                   https://docs.microsoft.com/en-us/graph/query-parameters
    # + return - A stream of type `User` if sucess. Else `Error`.
    @display {label: "List Groups"}
    remote isolated function listGroups(@display {label: "Optional Query Parameters"} string[] queryParams = []) 
                                        returns @tainted stream<Group, Error>|Error {
        string path = check createUrl([GROUPS], queryParams);   
        http:Response response = check self.httpClient->get(path);

        map<json>|string handledResponse = check handleResponse(response);
        GroupStream objectInstance = check new (self.httpClient, path);
        stream<Group, Error> finalStream = new (objectInstance);
        return finalStream; 
    }

    # Delete a group
    # 
    # + groupId - The object ID if the group
    # + return - `nil` if sucess. Else `Error`.
    @display {label: "Delete Group"}
    remote isolated function deleteGroup(@display {label: "Group ID"} string groupId) returns @tainted Error? {
        string path = check createUrl([GROUPS, groupId]); 
        http:Response response = check self.httpClient->delete(path);
        _ = check handleResponse(response);
   
    }

    # Renews a group's expiration. When a group is renewed, the group expiration is extended by the number of days 
    # defined in the policy.
    # 
    # + groupId - The object ID if the group
    # + return - `nil` if sucess. Else `Error`.
    @display {label: "Renew Group"}
    remote isolated function renewGroup(@display {label: "Group ID"} string groupId) returns @tainted Error? {
        string path = check createUrl([GROUPS, groupId, "renew"]); 
        http:Response response = check self.httpClient->post(path, {});
        _ = check handleResponse(response);    
    }

    # List groups that the group is a direct member of.
    # 
    # +'type - The type of directiry object
    # + objectId - The object ID
    # + queryParams - Optional query parameters. This method support OData query parameters to customize the response.
    #                 It should be an array of type `string` in the format `<QUERY_PARAMETER_NAME>=<PARAMETER_VALUE>`
    #                 **Note:** For more information about query parameters, refer here: 
    #                   https://docs.microsoft.com/en-us/graph/query-parameters
    # + return - A stream of type `Group` if sucess. Else `Error`.
    @display {label: "List Parent Groups"}
    remote isolated function listParentGroups(@display {label: "Directory Object Type"} DirctoryObject 'type, 
                                              @display {label: "Object ID"} string objectId, 
                                              @display {label: "Optional Query Parameters"} string[] queryParams = []) 
                                              returns @tainted stream<Group, Error>|Error {
        string path = EMPTY_STRING;
        if('type == USER) {
            path = check createUrl([USERS, objectId, MEMBER_OF], queryParams);   
        } else {
            path = check createUrl([GROUPS, objectId, MEMBER_OF], queryParams);   
        }
        
        http:Response response = check self.httpClient->get(path);
        map<json>|string handledResponse = check handleResponse(response);
        GroupStream objectInstance = check new (self.httpClient, path);
        stream<Group, Error> finalStream = new (objectInstance);
        return finalStream; 
    }

    # Get groups that the group is a member of. This operation is transitive and will also include all groups that this 
    # groups is a nested member of.
    # 
    # +'type - The type of directiry object
    # + objectId - The object ID
    # + queryParams - Optional query parameters. This method support OData query parameters to customize the response.
    #                 It should be an array of type `string` in the format `<QUERY_PARAMETER_NAME>=<PARAMETER_VALUE>`
    #                 **Note:** For more information about query parameters, refer here: 
    #                   https://docs.microsoft.com/en-us/graph/query-parameters
    # + return - A stream of type `Group` if sucess. Else `Error`.
    @display {label: "List Transitive Parent Groups"}
    remote isolated function listTransitiveParentGroups(@display {label: "Directory Object Type"} DirctoryObject 'type, 
                                                        @display {label: "Object ID"} string objectId, 
                                                        @display {label: "Optional Query Parameters"} 
                                                        string[] queryParams = []) returns 
                                                        @tainted stream<Group, Error>|Error {
        string path = EMPTY_STRING;
        if('type == "user") {
            path = check createUrl([USERS, objectId, TRANSITIVE_MEMBER_OF], queryParams);   
        } else {
            path = check createUrl([GROUPS, objectId, TRANSITIVE_MEMBER_OF], queryParams);   
        }
        
        http:Response response = check self.httpClient->get(path);
        map<json>|string handledResponse = check handleResponse(response);
        GroupStream objectInstance = check new (self.httpClient, path);
        stream<Group, Error> finalStream = new (objectInstance);
        return finalStream; 
    }

    # Add a member to a Microsoft 365 group or a security group through the members navigation property.
    # 
    # + groupId - The object ID if the group
    # + memberIds - The object IDs of members to add to the group
    # + return - `nil` if sucess. Else `Error`.
    @display {label: "Add Group Member"}
    remote isolated function addGroupMember(@display {label: "Group ID"} string groupId, 
                                            @display {label: "Member IDs"} string... memberIds) returns @tainted Error? {
        string path = check createUrl([GROUPS, groupId, MEMBERS, "$ref"]); 
        json payload = {};
        if(memberIds.length() > 1) {
            string[] memberDataArray = [];
            foreach string id in memberIds {
                memberDataArray.push(string `https://graph.microsoft.com/v1.0/directoryObjects/${id}`);
            }
            payload = {
                "members@odata.bind": memberDataArray
            };
        } else if(memberIds.length() == 1) {
            payload = {
                "@odata.id": string `https://graph.microsoft.com/v1.0/directoryObjects/${memberIds[0]}`
            };
        } else {
            return error InputValidationError("Atleast one member should be added");
        }

        http:Response response = check self.httpClient->post(path, payload);
        _ = check handleResponse(response);    
    }

    # Get a list of the group's direct members.
    # 
    # + groupId - The object ID if the group
    # + queryParams - Optional query parameters. This method support OData query parameters to customize the response.
    #                 It should be an array of type `string` in the format `<QUERY_PARAMETER_NAME>=<PARAMETER_VALUE>`
    #                 **Note:** For more information about query parameters, refer here: 
    #                   https://docs.microsoft.com/en-us/graph/query-parameters
    # + return - A stream of type `User` if sucess. Else `Error`.
    @display {label: "List Group Members"}
    remote isolated function listGroupMembers(@display {label: "Group ID"} string groupId, 
                                              @display {label: "Optional Query Parameters"} string[] queryParams = []) 
                                              returns @tainted stream<User, Error>|Error {
        string path = check createUrl([GROUPS, groupId, MEMBERS], queryParams);   
        http:Response response = check self.httpClient->get(path);

        map<json>|string handledResponse = check handleResponse(response);
        UserStream objectInstance = check new (self.httpClient, path);
        stream<User, Error> finalStream = new (objectInstance);
        return finalStream; 
    }

    # Get a list of the group's members.
    # 
    # + groupId - The object ID if the group
    # + queryParams - Optional query parameters. This method support OData query parameters to customize the response.
    #                 It should be an array of type `string` in the format `<QUERY_PARAMETER_NAME>=<PARAMETER_VALUE>`
    #                 **Note:** For more information about query parameters, refer here: 
    #                   https://docs.microsoft.com/en-us/graph/query-parameters
    # + return - A stream of type `User` if sucess. Else `Error`.
    @display {label: "List Transitive Group Members"}
    remote isolated function listTransitiveGroupMembers(@display {label: "Group ID"} string groupId, 
                                                        @display {label: "Optional Query Parameters"} 
                                                        string[] queryParams = []) returns 
                                                        @tainted stream<User, Error>|Error {
        string path = check createUrl([GROUPS, groupId, TRANSITIVE_MEMBERS], queryParams);   
        http:Response response = check self.httpClient->get(path);

        map<json>|string handledResponse = check handleResponse(response);
        UserStream objectInstance = check new (self.httpClient, path);
        stream<User, Error> finalStream = new (objectInstance);
        return finalStream; 
    }

    # Remove a member from a group via the members navigation property.
    # 
    # + groupId - The object ID if the group
    # + memberId - The object ID of member to remove from the group
    # + return - `nil` if sucess. Else `Error`.
    @display {label: "Remove Group Member"}
    remote isolated function removeGroupMember(@display {label: "Group ID"} string groupId, 
                                               @display {label: "Member ID"} string memberId) returns @tainted Error? {
        string path = check createUrl([GROUPS, groupId, MEMBERS, memberId, "$ref"]); 
        http:Response response = check self.httpClient->delete(path);
        _ = check handleResponse(response);        
    }

    # Add a user or service principal to the group's owners. The owners are a set of users or service principals who are 
    # allowed to modify the group object.
    # 
    # + groupId - The object ID if the group
    # + ownerId - The object ID of owner to add to the group
    # + return - `nil` if sucess. Else `Error`.
    @display {label: "Add Group Owner"}
    remote isolated function addGroupOwner(@display {label: "Group ID"} string groupId, 
                                           @display {label: "Owner ID"} string ownerId) returns @tainted Error? {
        string path = check createUrl([GROUPS, groupId, OWNERS, "$ref"]); 
        json payload = {
                "@odata.id": string `https://graph.microsoft.com/v1.0/users/${ownerId}`
        };
        
        http:Response response = check self.httpClient->post(path, payload);
        _ = check handleResponse(response);        
    }

    # Retrieve a list of the group's owners.
    # 
    # + groupId - The object ID if the group
    # + queryParams - Optional query parameters. This method support OData query parameters to customize the response.
    #                 It should be an array of type `string` in the format `<QUERY_PARAMETER_NAME>=<PARAMETER_VALUE>`
    #                 **Note:** For more information about query parameters, refer here: 
    #                   https://docs.microsoft.com/en-us/graph/query-parameters
    # + return - A stream of type `User` if sucess. Else `Error`.
    @display {label: "List Group Owners"}
    remote isolated function listGroupOwners(@display {label: "Group ID"} string groupId, 
                                             @display {label: "Optional Query Parameters"} string[] queryParams = []) 
                                             returns @tainted stream<User, Error>|Error {
        string path = check createUrl([GROUPS, groupId, OWNERS], queryParams);   
        http:Response response = check self.httpClient->get(path);

        map<json>|string handledResponse = check handleResponse(response);
        UserStream objectInstance = check new (self.httpClient, path);
        stream<User, Error> finalStream = new (objectInstance);
        return finalStream; 
    }

    # Remove an owner from a group via the members navigation property.
    # 
    # + groupId - The object ID if the group
    # + ownerId - The object ID of owner to remove from the group
    # + return - `nil` if sucess. Else `Error`.
    @display {label: "Remove Group Owner"}
    remote isolated function removeGroupOwner(@display {label: "Group ID"} string groupId, 
                                              @display {label: "Owner ID"} string ownerId) returns @tainted Error? {
        string path = check createUrl([GROUPS, groupId, OWNERS, ownerId, "$ref"]); 
        
        http:Response response = check self.httpClient->delete(path);
        _ = check handleResponse(response);        
    }

    # List all resource-specific permission grants on the group. This list specifies the Azure AD apps that have access 
    # to the group, along with the corresponding kind of resource-specific access that each app has.
    # 
    # + groupId - The object ID if the group
    # + queryParams - Optional query parameters. This method support OData query parameters to customize the response.
    #                 It should be an array of type `string` in the format `<QUERY_PARAMETER_NAME>=<PARAMETER_VALUE>`
    #                 **Note:** For more information about query parameters, refer here: 
    #                   https://docs.microsoft.com/en-us/graph/query-parameters
    # + return - A stream of type `PermissionGrant` if sucess. Else `Error`.
    @display {label: "List Permission Grants"}
    remote isolated function listPermissionGrants(@display {label: "Group ID"} string groupId, 
                                                  @display {label: "Optional Query Parameters"} 
                                                  string[] queryParams = []) returns 
                                                  @tainted stream<PermissionGrant, Error>|Error {
        string path = check createUrl([GROUPS, groupId, PERMISSION_GRANTS]);   
        http:Response response = check self.httpClient->get(path);

        map<json>|string handledResponse = check handleResponse(response);
        PermissionGrantStream objectInstance = check new (self.httpClient, path);
        stream<PermissionGrant, Error> finalStream = new (objectInstance);
        return finalStream; 
    } 
}
