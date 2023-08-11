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
import ballerinax/'client.config;

class UserStream {
    private User[] currentEntries = [];
    private string nextLink;
    int index = 0;
    private final http:Client httpClient;
    private final string path;
    http:ClientConfiguration config;
    string? queryParams;

    isolated function init(ConnectionConfig config, http:Client httpClient, string path, string? queryParams = ()) 
                           returns error? {
        self.config = check config:constructHTTPClientConfig(config);
        self.httpClient = httpClient;
        self.path = path;
        self.nextLink = EMPTY_STRING;
        self.queryParams = queryParams;
        self.currentEntries = check self.fetchRecordsInitial();
    }

    public isolated function next() returns record {| User value; |}|error? {
        if(self.index < self.currentEntries.length()) {
            record {| User value; |} singleRecord = {value: self.currentEntries[self.index]};
            self.index += 1;
            return singleRecord;
        }
        // This code block is for retrieving the next batch of records when the initial batch is finished.
        if (self.nextLink != EMPTY_STRING && !self.queryParams.toString().includes("$top")) {
            self.index = 0;
            self.currentEntries = check self.fetchRecordsNext();
            record {| User value; |} singleRecord = {value: self.currentEntries[self.index]};
            self.index += 1;
            return singleRecord;
        }
        return;
    }

    isolated function fetchRecordsInitial() returns User[]|error {
        http:Response response = check self.httpClient->get(self.path);
        _ = check handleResponse(response);
        return check self.getAndConvertToUserArray(response);
    }
    
    isolated function fetchRecordsNext() returns User[]|error {
        http:Client nextPageClient = check new (self.nextLink, self.config);
        http:Response response = check nextPageClient->get(EMPTY_STRING);
        return check self.getAndConvertToUserArray(response);
    }

    isolated function getAndConvertToUserArray(http:Response response) returns User[]|error {
        map<json>|string? handledResponse = check handleResponse(response);
        if (handledResponse is map<json>) {
            self.nextLink = let var link = handledResponse["@odata.nextLink"] in link is string ? link : EMPTY_STRING;
            return check handledResponse[VALUE_ARRAY].cloneWithType(UserArray);
        } else {
            return error(INVALID_RESPONSE);
        }
    }
}

class GroupStream {
    private Group[] currentEntries = [];
    private string nextLink;
    int index = 0;
    private final http:Client httpClient;
    private final string path;
    http:ClientConfiguration config;
    string? queryParams;

    isolated function init(ConnectionConfig config, http:Client httpClient, string path, string? queryParams = ()) 
                           returns error? {
        self.config = check config:constructHTTPClientConfig(config);
        self.httpClient = httpClient;
        self.path = path;
        self.nextLink = EMPTY_STRING;
        self.queryParams = queryParams;
        self.currentEntries = check self.fetchRecordsInitial();
    }

    public isolated function next() returns record {| Group value; |}|error? {
        if(self.index < self.currentEntries.length()) {
            record {| Group value; |} singleRecord = {value: self.currentEntries[self.index]};
            self.index += 1;
            return singleRecord;
        }
        // This code block is for retrieving the next batch of records when the initial batch is finished.
        if (self.nextLink != EMPTY_STRING && !self.queryParams.toString().includes("$top")) {
            self.index = 0;
            self.currentEntries = check self.fetchRecordsNext();
            record {| Group value; |} singleRecord = {value: self.currentEntries[self.index]};
            self.index += 1;
            return singleRecord;
        }
        return;
    }

    isolated function fetchRecordsInitial() returns Group[]|error {
        http:Response response = check self.httpClient->get(self.path);
        _ = check handleResponse(response);
        return check self.getAndConvertToGroupArray(response);
    }
    
    isolated function fetchRecordsNext() returns Group[]|error {
        http:Client nextPageClient = check new (self.nextLink, self.config);        
        http:Response response = check nextPageClient->get(EMPTY_STRING);
        return check self.getAndConvertToGroupArray(response);
    }

    isolated function getAndConvertToGroupArray(http:Response response) returns Group[]|error {
        map<json>|string? handledResponse = check handleResponse(response);
        if (handledResponse is map<json>) {
            self.nextLink = let var link = handledResponse["@odata.nextLink"] in link is string ? link : EMPTY_STRING;
            return check handledResponse[VALUE_ARRAY].cloneWithType(GroupArray);
        } else {
            return error(INVALID_RESPONSE);
        }
    }
}

class PermissionGrantStream {
    private PermissionGrant[] currentEntries = [];
    private string nextLink;
    int index = 0;
    private final http:Client httpClient;
    private final string path;
    http:ClientConfiguration config;
    string? queryParams;

    isolated function init(ConnectionConfig config, http:Client httpClient, string path, string? queryParams = ()) 
                           returns error? {
        self.config = check config:constructHTTPClientConfig(config);
        self.httpClient = httpClient;
        self.path = path;
        self.nextLink = EMPTY_STRING;
        self.queryParams = queryParams;
        self.currentEntries = check self.fetchRecordsInitial();
    }

    public isolated function next() returns record {| PermissionGrant value; |}|error? {
        if(self.index < self.currentEntries.length()) {
            record {| PermissionGrant value; |} singleRecord = {value: self.currentEntries[self.index]};
            self.index += 1;
            return singleRecord;
        }
        // This code block is for retrieving the next batch of records when the initial batch is finished.
        if (self.nextLink != EMPTY_STRING && !self.queryParams.toString().includes("$top")) {
            self.index = 0;
            self.currentEntries = check self.fetchRecordsNext();
            record {| PermissionGrant value; |} singleRecord = {value: self.currentEntries[self.index]};
            self.index += 1;
            return singleRecord;
        }
        return;
    }

    isolated function fetchRecordsInitial() returns PermissionGrant[]|error {
        http:Response response = check self.httpClient->get(self.path);
        _ = check handleResponse(response);
        return check self.getAndConvertToGrantArray(response);
    }
    
    isolated function fetchRecordsNext() returns PermissionGrant[]|error {
        http:Client nextPageClient = check new (self.nextLink, self.config);         
        http:Response response = check nextPageClient->get(EMPTY_STRING);
        return check self.getAndConvertToGrantArray(response);
    }

    isolated function getAndConvertToGrantArray(http:Response response) returns PermissionGrant[]|error {
        map<json>|string? handledResponse = check handleResponse(response);
        if (handledResponse is map<json>) {
            self.nextLink = let var link = handledResponse["@odata.nextLink"] in link is string ? link : EMPTY_STRING;
            return check handledResponse[VALUE_ARRAY].cloneWithType(PermissionGrantArray);
        } 
        else {
            return error(INVALID_RESPONSE);
        }
    }
}
