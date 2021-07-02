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

# Represents configuration parameters to create Azure AD client.
#
# + clientConfig - OAuth client configuration
# + secureSocketConfig - SSH configuration
@display{label: "Connection config"} 
public type Configuration record {|
    http:BearerTokenConfig|http:OAuth2RefreshTokenGrantConfig clientConfig;
    http:ClientSecureSocket secureSocketConfig?;
|};

# Represents a new user to be added to the active directory.
# 
# + displayName - The name displayed in the address book for the user
# + onPremisesImmutableId - This property is used to associate an on-premise active directory user account to its Azure 
#                           AD user object
# + passwordProfile - Specifies the password profile for the user
# + userPrincipalName - The user principal name (UPN) of the user
public type BaseUserData record {
    string onPremisesImmutableId?;
    PasswordProfile passwordProfile?;

    string aboutMe?;
    AgeGroup ageGroup?;
    string birthday?;
    string[] businessPhones?;
    string city?;
    string companyName?;
    ConcentForMinor consentProvidedForMinor?;
    string country?;
    string department?;
    string employeeId?;
    EmployeeType employeeType?;
    string? givenName?;
    string hireDate?;
    string[] interests?;
    string? jobTitle?;
    string? mail?;
    string? mobilePhone?;
    string mySite?;
    string? officeLocation?;
    string otherMails?;
    string passwordPolicies?;//enum
    string[] pastProjects?;
    string postalCode?;
    string? preferredLanguage?;
    string[] responsibilities?;
    string[] schools?;
    string[] skills?;
    string state?;
    string streetAddress?;
    string usageLocation?;//enum
    string? surname?;
};

# Password profile associated with a user.
# 
# + forceChangePasswordNextSignIn - `true` if the user must change the password on the next login or else `false`
# + forceChangePasswordNextSignInWithMfa - If `true`, at the next sign-in, the users must perform a multi-factor 
#                                          authentication (MFA) before being forced to change their password
# + password - The password of the user
public type PasswordProfile record {|
    boolean forceChangePasswordNextSignIn?;
    boolean forceChangePasswordNextSignInWithMfa?;
    string password;
|};

# Description
#
# + accountEnabled - True if the account is enabled or else false
# + mailNickname - The mail alias for the user
public type NewUser record {
    boolean accountEnabled;
    string mailNickname;
    string displayName;
    string userPrincipalName;
    *BaseUserData;
};

# Description
#
# + accountEnabled - True if the account is enabled or else false
# + mailNickname - The mail alias for the user
public type UpdateUser record {
    boolean accountEnabled?;
    string mailNickname?;
    string displayName?;
    string userPrincipalName?;
    *BaseUserData;
};

public type User record {
    string id?;
    string displayName?;
    string userPrincipalName?;
    *BaseUserData;
    ExtentionAttriute onPremisesExtensionAttributes?;
};

public type ExtentionAttriute record {
    string extensionAttribute1?;
    string extensionAttribute2?;
    string extensionAttribute3?;
    string extensionAttribute4?;
    string extensionAttribute5?;
    string extensionAttribute6?;
    string extensionAttribute7?;
    string extensionAttribute8?;
    string extensionAttribute9?;
    string extensionAttribute10?;
    string extensionAttribute11?;
    string extensionAttribute12?;
    string extensionAttribute13?;
    string extensionAttribute14?;
    string extensionAttribute15?;
};