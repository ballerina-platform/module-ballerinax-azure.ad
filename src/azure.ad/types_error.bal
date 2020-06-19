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

const AD_CLIENT_ERROR = "{ballerinax/azure.ad}ADClientError";
const INVALID_PAYLOAD = "{ballerinax/azure.ad}InvalidPayload";

public type ADClientError error<AD_CLIENT_ERROR, record {| string message; error cause; |}>;
public type GraphAPIError error<string, InnerError>;
public type InvalidErrorPayload error<INVALID_PAYLOAD>;

# Represents an error information returned from the Graph API
# 
# + message - The message of the error
# + cause - Error cause if exists
# + innerError - Error details
public type InnerError record {|
    string message;
    error cause?;
    map<anydata> innerError;
|};