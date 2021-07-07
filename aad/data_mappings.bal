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

isolated function convertNewGroupToJson(NewGroup info) returns json|Error? {
    json newGroup = check info.cloneWithType(json);
    string[] ownerIds = info?.ownerIds ?: [];
    string[] memberIds = info?.memberIds ?: [];
    if (ownerIds.length() >= 1) {
        string[] ownerArray = [];
        foreach string id in ownerIds {
            ownerArray.push(string `https://graph.microsoft.com/v1.0/users/${id}`);
        }
        _ = check newGroup.mergeJson({
            "owners@odata.bind" : ownerArray
        });
    }

    if (memberIds.length() >= 1) {
        string[] memberArray = [];
        foreach string id in memberIds {
            memberArray.push(string `https://graph.microsoft.com/v1.0/users/${id}`);
        }
        _ = check newGroup.mergeJson({
            "members@odata.bind" : memberArray
        });
    }
    removeKey(<map<json>>newGroup, "ownerIds");
    removeKey(<map<json>>newGroup, "memberIds");
    return newGroup;
}
