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

# Represents a Device in the active directory.
# 
# + accountEnabled - `true` if account is enabled, else `false`
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

# `Unified` refers to Office 365 group. Else `DynamicMembership`.
public type GroupTypes "Unified"|"DynamicMembership";

# Represents a new Group to add to the active directory.
# 
# + displayName - The display name for the group
# + groupTypes - Type of the group and its membership
# + description - Description for the group
# + mailEnabled - Specifies whether the group is mail-enabled
# + mailNickname - The mail alias for the group
# + securityEnabled - Specifies whether the group is a security group
# + owners - The owners of the group
# + members - Users and groups that are members of this group
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

# Represents a Group in the active directory.
# 
# + allowExternalSenders - Indicates if people external to the organization can send messages to the group
# + classification - Classification for the group
# + createdDateTime - Timestamp of when the group was created
# + deletedDateTime - Deleted time of the group
# + description - Description for the group
# + displayName - The display name for the group
# + groupTypes - Type of the group and its membership
# + mail - The SMTP address for the group
# + mailEnabled - Specifies whether the group is mail-enabled
# + onPremisesLastSyncDateTime - Indicates the last time at which the group was synced with the on-premises directory
# + onPremisesNetBiosName - Contains the on-premises netBios name synchronized from the on-premises directory
# + onPremisesSamAccountName - Contains the on-premises SAM account name synchronized from the on-premises directory
# + onPremisesSecurityIdentifier - Contains the on-premises security identifier (SID) for the group that was synchronized from on-premises to the cloud
# + onPremisesSyncEnabled - `true` if this group is synced from an on-premises directory; `false` if this group was originally synced from an on-premises directory but is no longer synced
# + preferredDataLocation - The preferred data location for the group
# + proxyAddresses - Email addresses for the group that direct to the same group mailbox
# + renewedDateTime - Timestamp of when the group was last renewed
# + securityEnabled - Specifies whether the group is a security group
# + securityIdentifier - Security identifier of the group, used in Windows scenarios
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

# Password profile associated with a User.
# 
# + forceChangePasswordNextSignIn - `true` if the user must change her password on the next login; otherwise `false`
# + forceChangePasswordNextSignInWithMfa - If `true`, at next sign-in, the user must perform a multi-factor authentication (MFA) before being forced to change their password
# + password - The password for the user
public type PasswordProfile record {|
    boolean forceChangePasswordNextSignIn = false;
    boolean forceChangePasswordNextSignInWithMfa = false;
    string password;
|};

# Represents a new User to add to the active directory.
# 
# + accountEnabled - true if the account is enabled; otherwise, false
# + displayName - The name displayed in the address book for the user
# + onPremisesImmutableId - This property is used to associate an on-premises Active Directory user account to their Azure AD user object
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

# Represents a User in the active directory.
# 
# + businessPhones - The telephone numbers for the user
# + displayName - The name displayed in the address book for the user
# + givenName - The given name (first name) of the user
# + jobTitle -The user’s job title
# + mail - The SMTP address for the user
# + mobilePhone - The primary cellular telephone number for the use
# + officeLocation - The office location in the user's place of business
# + preferredLanguage - The preferred language for the user
# + surname - The user's surname (family name or last name)
# + userPrincipalName - The user principal name (UPN) of the user
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
