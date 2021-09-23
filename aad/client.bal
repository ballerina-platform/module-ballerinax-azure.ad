// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

# This is connecting to the Microsoft Graph RESTful web API that enables you to access Microsoft Cloud service resources.
# 
# + httpClient - the HTTP Client
@display {
    label: "Azure AD", 
    iconPath: "resources/azure.ad.svg"
}
public isolated client class Client {
    final http:Client httpClient;
    final readonly & ConnectionConfig config;

    # Gets invoked to initialize the `connector`.
    # The connector initialization requires setting the API credentials. 
    # Create an [Azure account](https://azure.microsoft.com/en-us/free/) 
    # and obtain tokens following [this guide](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-configure-app-expose-web-apis). Configure the Access token to 
    # have the [required permission](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-configure-app-expose-web-apis#add-a-scope).
    # 
    # + aadConfig - Configurations required to initialize the `Client` endpoint
    # + return -  Error at failure of client initialization
    public isolated function init(ConnectionConfig aadConfig) returns error? {
        self.httpClient = check new (BASE_URL, aadConfig);
        self.config = aadConfig.cloneReadOnly();
    }

    // ************************************* Operations on a User resource *********************************************
    // Represents an Azure AD user account.

    # Creates a new user.
    # 
    # + info - The basic information about a user
    # + return - A record `aad:User` if sucess. Else `error`.
    @display {label: "Create User"}
    remote isolated function createUser(@display {label: "New User Information"} NewUser info) returns 
                                        User|error {
        string path = check createUrl([USERS]);
        json payload = check info.cloneWithType(json);
        return check self.httpClient->post(path, payload, targetType = User);
    }

    # Gets information about a user.
    # 
    # + userId - The object ID if the user
    # + queryParams - Optional query parameters
    #               - This method support OData query parameters to customize the response. It should be an array of type `string` in the format `<QUERY_PARAMETER_NAME>=<PARAMETER_VALUE>`
    #               - For more information about query parameters, [visit](https://docs.microsoft.com/en-us/graph/query-parameters).
    # + return - A record `aad:User` if sucess. Else `error`.
    @display {label: "Get User"}
    remote isolated function getUser(@display {label: "User ID"} string userId, 
                                     @display {label: "Optional Query Parameters"} string? queryParams = ()) 
                                     returns User|error {
        string path = check createUrl([USERS, userId], queryParams);   
        return check self.httpClient->get(path, targetType = User);
    }

    # Updates information about a user.
    # 
    # + userId - The object ID if the user
    # + info - The information to update
    # + return - `error` if the operation fails or `()` if nothing is to be returned
    @display {label: "Update User"}
    remote isolated function updateUser(@display {label: "User ID"} string userId, 
                                        @display {label: "User Update Information"} UpdateUser info) 
                                        returns error? {
        string path = check createUrl([USERS, userId]); 
        json payload = check info.cloneWithType(json);   
        http:Response response = check self.httpClient->patch(path, payload);
        _ = check handleResponse(response);
    }

    # Lists information about users.
    # 
    # + queryParams - Optional query parameters
    #               - This method support OData query parameters to customize the response. It should be an array of type `string` in the format `<QUERY_PARAMETER_NAME>=<PARAMETER_VALUE>`
    #               - For more information about query parameters, [visit](https://docs.microsoft.com/en-us/graph/query-parameters).
    # + return - A stream of `aad:User` if sucess. Else `error`.
    @display {label: "List Users"}
    remote isolated function listUsers(@display {label: "Optional Query Parameters"} string? queryParams = ()) 
                                       returns @display {label: "Stream of User records"} stream<User, error?>|error {
        string path = check createUrl([USERS], queryParams);
        http:Response response = check self.httpClient->get(path);

        map<json>|string handledResponse = check handleResponse(response);
        UserStream objectInstance = check new (self.config, self.httpClient, path, queryParams);
        stream<User, error?> finalStream = new (objectInstance);
        return finalStream; 
    }

    # Deletes a user.
    # 
    # + userId - The object ID if the user
    # + return - `error` if the operation fails or `()` if nothing is to be returned
    @display {label: "Delete User"}
    remote isolated function deleteUser(@display {label: "User ID"} string userId) returns error? {
        string path = check createUrl([USERS, userId]); 
        http:Response response = check self.httpClient->delete(path);
        _ = check handleResponse(response);    
    }

    // ************************************* Operations on a Group resource ********************************************
    // Represents an Azure Active Directory (Azure AD) group, which can be a Microsoft 365 group, or a security group.

    # Creates a new group.
    # 
    # + info - The basic information about a group
    # + return - A record `aad:Group` if sucess. Else `error`.
    @display {label: "Create Group"}
    remote isolated function createGroup(@display {label: "New Group Information"} NewGroup info) 
                                         returns Group|error {
        string path = check createUrl([GROUPS]);
        json payload = check convertNewGroupToJson(info);
        return check self.httpClient->post(path, payload, targetType = Group);
    }

    # Gets information about a group.
    # 
    # + groupId - The object ID if the group
    # + queryParams - Optional query parameters
    #               - This method support OData query parameters to customize the response. It should be an array of type `string` in the format `<QUERY_PARAMETER_NAME>=<PARAMETER_VALUE>`
    #               - For more information about query parameters, [visit](https://docs.microsoft.com/en-us/graph/query-parameters).
    # + return - A record `aad:User` if sucess. Else `error`.
    @display {label: "Get Group"}
    remote isolated function getGroup(@display {label: "Group ID"} string groupId, 
                                      @display {label: "Optional Query Parameters"} string? queryParams = ()) 
                                      returns Group|error {
        string path = check createUrl([GROUPS, groupId], queryParams);   
        return check self.httpClient->get(path, targetType = Group);
    }

    # Updates information about a group.
    # 
    # + groupId - The object ID if the group
    # + info - The information to update
    # + return - `error` if the operation fails or `()` if nothing is to be returned
    @display {label: "Update Group"}
    remote isolated function updateGroup(@display {label: "Group ID"} string groupId, 
                                         @display {label: "Group Update Information"}  UpdateGroup info) 
                                         returns error? {
        string path = check createUrl([GROUPS, groupId]); 
        json payload = check info.cloneWithType(json); 
        http:Response response = check self.httpClient->patch(path, payload);
        _ = check handleResponse(response);
  
    }

    # Lists information about groups.
    # 
    # + queryParams - Optional query parameters
    #               - This method support OData query parameters to customize the response. It should be an array of type `string` in the format `<QUERY_PARAMETER_NAME>=<PARAMETER_VALUE>`
    #               - For more information about query parameters, [visit](https://docs.microsoft.com/en-us/graph/query-parameters).
    # + return - A stream `aad:User` if sucess. Else `error`.
    @display {label: "List Groups"}
    remote isolated function listGroups(@display {label: "Optional Query Parameters"} string? queryParams = ()) 
                                        returns @display {label: "Stream of Group records"} 
                                        stream<Group, error?>|error {
        string path = check createUrl([GROUPS], queryParams);   
        http:Response response = check self.httpClient->get(path);

        map<json>|string handledResponse = check handleResponse(response);
        GroupStream objectInstance = check new (self.config, self.httpClient, path, queryParams);
        stream<Group, error?> finalStream = new (objectInstance);
        return finalStream; 
    }

    # Deletes a group.
    # 
    # + groupId - The object ID if the group
    # + return - `error` if the operation fails or `()` if nothing is to be returned
    @display {label: "Delete Group"}
    remote isolated function deleteGroup(@display {label: "Group ID"} string groupId) returns error? {
        string path = check createUrl([GROUPS, groupId]); 
        http:Response response = check self.httpClient->delete(path);
        _ = check handleResponse(response);
   
    }

    # Renews a group's expiration. <br/> When a group is renewed, the group expiration is extended by the number of days 
    # defined in the policy.
    # 
    # + groupId - The object ID if the group
    # + return - `error` if the operation fails or `()` if nothing is to be returned
    @display {label: "Renew Group"}
    remote isolated function renewGroup(@display {label: "Group ID"} string groupId) returns error? {
        string path = check createUrl([GROUPS, groupId, "renew"]); 
        http:Response response = check self.httpClient->post(path, {});
        _ = check handleResponse(response);    
    }

    # Lists groups that the group is a direct member of.
    # 
    # +'type - The type of directiry object
    # + objectId - The object ID
    # + queryParams - Optional query parameters
    #               - This method support OData query parameters to customize the response. It should be an array of type `string` in the format `<QUERY_PARAMETER_NAME>=<PARAMETER_VALUE>`
    #               - For more information about query parameters, [visit](https://docs.microsoft.com/en-us/graph/query-parameters).
    # + return - A stream `aad:Group` if sucess. Else `error`.
    @display {label: "List Parent Groups"}
    remote isolated function listParentGroups(@display {label: "Directory Object Type"} DirctoryObject 'type, 
                                              @display {label: "Object ID"} string objectId, 
                                              @display {label: "Optional Query Parameters"} string? queryParams = ()) 
                                              returns @display {label: "Stream of Group records"} 
                                              stream<Group, error?>|error {
        string path = EMPTY_STRING;
        if('type == USER) {
            path = check createUrl([USERS, objectId, MEMBER_OF], queryParams);   
        } else {
            path = check createUrl([GROUPS, objectId, MEMBER_OF], queryParams);   
        }
        
        http:Response response = check self.httpClient->get(path);
        map<json>|string handledResponse = check handleResponse(response);
        GroupStream objectInstance = check new (self.config, self.httpClient, path, queryParams);
        stream<Group, error?> finalStream = new (objectInstance);
        return finalStream; 
    }

    # Gets groups that the group is a member of. <br/> This operation is transitive and will also include all groups 
    # that this groups is a nested member of.
    # 
    # +'type - The type of directiry object
    # + objectId - The object ID
    # + queryParams - Optional query parameters 
    #               - This method support OData query parameters to customize the response. It should be an array of type `string` in the format `<QUERY_PARAMETER_NAME>=<PARAMETER_VALUE>`
    #               - For more information about query parameters, [visit](https://docs.microsoft.com/en-us/graph/query-parameters).
    # + return - A stream `aad:Group` if sucess. Else `error`.
    @display {label: "List Transitive Parent Groups"}
    remote isolated function listTransitiveParentGroups(@display {label: "Directory Object Type"} DirctoryObject 'type, 
                                                        @display {label: "Object ID"} string objectId, 
                                                        @display {label: "Optional Query Parameters"} 
                                                        string? queryParams = ()) returns 
                                                        @display {label: "Stream of Group records"} 
                                                        stream<Group, error?>|error {
        string path = EMPTY_STRING;
        if('type == USER) {
            path = check createUrl([USERS, objectId, TRANSITIVE_MEMBER_OF], queryParams);   
        } else {
            path = check createUrl([GROUPS, objectId, TRANSITIVE_MEMBER_OF], queryParams);   
        }
        
        http:Response response = check self.httpClient->get(path);
        map<json>|string handledResponse = check handleResponse(response);
        GroupStream objectInstance = check new (self.config, self.httpClient, path, queryParams);
        stream<Group, error?> finalStream = new (objectInstance);
        return finalStream; 
    }

    # Adds a member to a Microsoft 365 group or a security group through the members navigation property.
    # 
    # + groupId - The object ID if the group
    # + memberIds - The object IDs of members to add to the group
    # + return - `error` if the operation fails or `()` if nothing is to be returned
    @display {label: "Add Group Member"}
    remote isolated function addGroupMember(@display {label: "Group ID"} string groupId, 
                                            @display {label: "Member IDs"} string... memberIds) returns error? {
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
            return error("Atleast one member should be added");
        }

        http:Response response = check self.httpClient->post(path, payload);
        _ = check handleResponse(response);    
    }

    # Gets a list of the group's direct members.
    # 
    # + groupId - The object ID if the group
    # + queryParams - Optional query parameters 
    #               - This method support OData query parameters to customize the response. It should be an array of type `string` in the format `<QUERY_PARAMETER_NAME>=<PARAMETER_VALUE>`
    #               - For more information about query parameters, [visit](https://docs.microsoft.com/en-us/graph/query-parameters).
    # + return - A stream of `aad:User` if sucess. Else `error`.
    @display {label: "List Group Members"}
    remote isolated function listGroupMembers(@display {label: "Group ID"} string groupId, 
                                              @display {label: "Optional Query Parameters"} string? queryParams = ()) 
                                              returns @display {label: "Stream of User records"} 
                                              stream<User, error?>|error {
        string path = check createUrl([GROUPS, groupId, MEMBERS], queryParams);   
        http:Response response = check self.httpClient->get(path);

        map<json>|string handledResponse = check handleResponse(response);
        UserStream objectInstance = check new (self.config, self.httpClient, path, queryParams);
        stream<User, error?> finalStream = new (objectInstance);
        return finalStream; 
    }

    # Gets a list of the group's members.
    # 
    # + groupId - The object ID if the group
    # + queryParams - Optional query parameters
    #               - This method support OData query parameters to customize the response. It should be an array of type `string` in the format `<QUERY_PARAMETER_NAME>=<PARAMETER_VALUE>`
    #               - For more information about query parameters, [visit](https://docs.microsoft.com/en-us/graph/query-parameters).
    # + return - A stream of `aad:User` if sucess. Else `error`.
    @display {label: "List Transitive Group Members"}
    remote isolated function listTransitiveGroupMembers(@display {label: "Group ID"} string groupId, 
                                                        @display {label: "Optional Query Parameters"} 
                                                        string? queryParams = ()) returns 
                                                        @display {label: "Stream of User records"} 
                                                        stream<User, error?>|error {
        string path = check createUrl([GROUPS, groupId, TRANSITIVE_MEMBERS], queryParams);   
        http:Response response = check self.httpClient->get(path);

        map<json>|string handledResponse = check handleResponse(response);
        UserStream objectInstance = check new (self.config, self.httpClient, path, queryParams);
        stream<User, error?> finalStream = new (objectInstance);
        return finalStream; 
    }

    # Removes a member from a group via the members navigation property.
    # 
    # + groupId - The object ID if the group
    # + memberId - The object ID of member to remove from the group
    # + return - `error` if the operation fails or `()` if nothing is to be returned
    @display {label: "Remove Group Member"}
    remote isolated function removeGroupMember(@display {label: "Group ID"} string groupId, 
                                               @display {label: "Member ID"} string memberId) returns error? {
        string path = check createUrl([GROUPS, groupId, MEMBERS, memberId, "$ref"]); 
        http:Response response = check self.httpClient->delete(path);
        _ = check handleResponse(response);        
    }

    # Adds a user or service principal to the group's owners. <br/> The owners are a set of users or service principals who are 
    # allowed to modify the group object.
    # 
    # + groupId - The object ID if the group
    # + ownerId - The object ID of owner to add to the group
    # + return - `error` if the operation fails or `()` if nothing is to be returned
    @display {label: "Add Group Owner"}
    remote isolated function addGroupOwner(@display {label: "Group ID"} string groupId, 
                                           @display {label: "Owner ID"} string ownerId) returns error? {
        string path = check createUrl([GROUPS, groupId, OWNERS, "$ref"]); 
        json payload = {
                "@odata.id": string `https://graph.microsoft.com/v1.0/users/${ownerId}`
        };
        
        http:Response response = check self.httpClient->post(path, payload);
        _ = check handleResponse(response);        
    }

    # Retrieves a list of the group's owners.
    # 
    # + groupId - The object ID if the group
    # + queryParams - Optional query parameters
    #               - This method support OData query parameters to customize the response. It should be an array of type `string` in the format `<QUERY_PARAMETER_NAME>=<PARAMETER_VALUE>`
    #               - For more information about query parameters, [visit](https://docs.microsoft.com/en-us/graph/query-parameters).
    # + return - A stream `aad:User` if sucess. Else `error`.
    @display {label: "List Group Owners"}
    remote isolated function listGroupOwners(@display {label: "Group ID"} string groupId, 
                                             @display {label: "Optional Query Parameters"} string? queryParams = ()) 
                                             returns @display {label: "Stream of User records"} stream<User, error?>|error {
        string path = check createUrl([GROUPS, groupId, OWNERS], queryParams);   
        http:Response response = check self.httpClient->get(path);

        map<json>|string handledResponse = check handleResponse(response);
        UserStream objectInstance = check new (self.config, self.httpClient, path, queryParams);
        stream<User, error?> finalStream = new (objectInstance);
        return finalStream; 
    }

    # Removes an owner from a group via the members navigation property.
    # 
    # + groupId - The object ID if the group
    # + ownerId - The object ID of owner to remove from the group
    # + return - `error` if the operation fails or `()` if nothing is to be returned
    @display {label: "Remove Group Owner"}
    remote isolated function removeGroupOwner(@display {label: "Group ID"} string groupId, 
                                              @display {label: "Owner ID"} string ownerId) returns error? {
        string path = check createUrl([GROUPS, groupId, OWNERS, ownerId, "$ref"]); 
        
        http:Response response = check self.httpClient->delete(path);
        _ = check handleResponse(response);        
    }

    # Lists all resource-specific permission grants on the group. <br/> This list specifies the Azure AD apps that have access 
    # to the group, along with the corresponding kind of resource-specific access that each app has.
    # 
    # + groupId - The object ID if the group
    # + queryParams - Optional query parameters
    #               - This method support OData query parameters to customize the response. It should be an array of type `string` in the format `<QUERY_PARAMETER_NAME>=<PARAMETER_VALUE>`
    #               - For more information about query parameters, [visit](https://docs.microsoft.com/en-us/graph/query-parameters).
    # + return - A stream of `aad:PermissionGrant` if sucess. Else `error`.
    @display {label: "List Permission Grants"}
    remote isolated function listPermissionGrants(@display {label: "Group ID"} string groupId, 
                                                  @display {label: "Optional Query Parameters"} 
                                                  string? queryParams = ()) returns 
                                                  @display {label: "Stream of Permission records"} 
                                                  stream<PermissionGrant, error?>|error {
        string path = check createUrl([GROUPS, groupId, PERMISSION_GRANTS]);   
        http:Response response = check self.httpClient->get(path);

        map<json>|string handledResponse = check handleResponse(response);
        PermissionGrantStream objectInstance = check new (self.config, self.httpClient, path, queryParams);
        stream<PermissionGrant, error?> finalStream = new (objectInstance);
        return finalStream; 
    } 
}
