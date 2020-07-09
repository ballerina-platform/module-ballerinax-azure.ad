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

# Represents a directory object in the active directory.
# 
# + id - A Guid that is the unique identifier for the object
public type DirectoryObject record {|
    string id;
|};

# Represents a device in the active directory.
# 
# + accountEnabled - `true` if the account is enabled or else `false`
# + deviceId - Unique ID for the device set during registration
# + displayName - The display name for the device
# + operatingSystem - The type of operating system on the device
# + operatingSystemVersion - The version of the operating system on the device
public type Device record {
    *DirectoryObject;
    
    boolean accountEnabled;
    string deviceId;
    string displayName;
    string operatingSystem;
    string operatingSystemVersion;
};

# Group visibilty.
public type GroupVisibility "Private"|"Public"|"HiddenMembership";

# `Unified` refers to the Office 365 group or else `DynamicMembership`.
public type GroupTypes "Unified"|"DynamicMembership";

# Represents a new group to be added to the active directory.
# 
# + displayName - The display name for the group
# + groupTypes - Type of the group and its membership
# + description - Description for the group
# + mailEnabled - Specifies whether the group is mail-enabled
# + mailNickname - The mail alias for the group
# + securityEnabled - Specifies whether the group is a security group
# + owners - The owners of the group
# + members - Users and groups who are members of this group
# + visibility - Specifies the visibility of an Office 365 group
public type NewGroup record {
    string displayName;
    GroupTypes[] groupTypes;
    string description?;
    boolean mailEnabled;
    string mailNickname;
    boolean securityEnabled;
    string[] owners?;
    string[] members?;
    GroupVisibility visibility = "Public";
};

# Represents a group in the active directory.
# 
# + allowExternalSenders - Indicates if people who are external to the organization can send messages to the group
# + classification - Classification for the group
# + createdDateTime - Timestamp of when the group was created
# + deletedDateTime - Deleted time of the group
# + description - Description for the group
# + displayName - The display name for the group
# + groupTypes - Type of the group and its membership
# + mail - The SMTP address for the group
# + mailEnabled - Specifies whether the group is mail-enabled
# + onPremisesLastSyncDateTime - Indicates the last time at which the group was synced with the on-premises directory
# + onPremisesNetBiosName - Contains the on-premise netBios name synchronized with the on-premise directory
# + onPremisesSamAccountName - Contains the on-premise SAM account name synchronized with the on-premise directory
# + onPremisesSecurityIdentifier - Contains the on-premises security identifier (SID) for the group that was synchronized from on-premises to the cloud
# + onPremisesSyncEnabled - `true` if this group is synced from an on-premise directory or else `false` if this group was originally synced from an on-premise directory but is no longer synced
# + preferredDataLocation - The preferred data location for the group
# + proxyAddresses - Email addresses of the group, which direct to the same group mailbox
# + renewedDateTime - Timestamp of when the group was last renewed
# + securityEnabled - Specifies whether the group is a security group
# + securityIdentifier - Security identifier of the group used in Windows scenarios
# + visibility - Specifies the visibility of an Office 365 group
public type Group record {
    *DirectoryObject;
    
    boolean allowExternalSenders = false;
    string? classification;
    string createdDateTime;
    string? deletedDateTime;
    string? description;
    string displayName;
    GroupTypes[] groupTypes;
    string? mail;
    boolean mailEnabled;
    string? onPremisesLastSyncDateTime;
    string? onPremisesNetBiosName;
    string? onPremisesSamAccountName;
    string? onPremisesSecurityIdentifier;
    boolean? onPremisesSyncEnabled;
    string? preferredDataLocation;
    string[] proxyAddresses;
    string renewedDateTime;
    boolean securityEnabled;
    string securityIdentifier;
    GroupVisibility? visibility;
};

# Password profile associated with a user.
# 
# + forceChangePasswordNextSignIn - `true` if the user must change the password on the next login or else `false`
# + forceChangePasswordNextSignInWithMfa - If `true`, at the next sign-in, the users must perform a multi-factor authentication (MFA) before being forced to change their password
# + password - The password of the user
public type PasswordProfile record {|
    boolean forceChangePasswordNextSignIn = false;
    boolean forceChangePasswordNextSignInWithMfa = false;
    string password;
|};

# Represents a new user to be added to the active directory.
# 
# + accountEnabled - true if the account is enabled or else false
# + displayName - The name displayed in the address book for the user
# + onPremisesImmutableId - This property is used to associate an on-premise active directory user account to its Azure AD user object
# + mailNickname - The mail alias for the user
# + passwordProfile - Specifies the password profile for the user
# + userPrincipalName - The user principal name (UPN) of the user
public type NewUser record {
    boolean accountEnabled;
    string displayName;
    string onPremisesImmutableId?;
    string mailNickname;
    PasswordProfile passwordProfile;
    string userPrincipalName;
};

# Represents a user in the active directory.
# 
# + businessPhones - The telephone numbers for the user
# + displayName - The name displayed in the address book for the user
# + givenName - The given name (first name) of the user
# + jobTitle -The user’s job title
# + mail - The SMTP address for the user
# + mobilePhone - The primary cellular telephone number of the user
# + officeLocation - The office location of the user's place of business
# + preferredLanguage - The preferred language for the user
# + surname - The user's surname (family name or last name)
# + userPrincipalName - The principal name (UPN) of the user
public type User record {
    *DirectoryObject;
    
    string[] businessPhones?;
    string displayName;
    string? givenName?;
    string? jobTitle?;
    string? mail?;
    string? mobilePhone?;
    string? officeLocation?;
    string? preferredLanguage?;
    string? surname?;
    string userPrincipalName;
};
