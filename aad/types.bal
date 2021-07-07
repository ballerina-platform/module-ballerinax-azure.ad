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
@display{label: "Connection Config"} 
public type Configuration record {|
    http:BearerTokenConfig|http:OAuth2RefreshTokenGrantConfig clientConfig;
    http:ClientSecureSocket secureSocketConfig?;
|};

# Represents common Azure AD user account information. 
#
# + onPremisesImmutableId - This property is used to associate an on-premise active directory user account to its Azure 
#                           AD user object
# + passwordProfile - Specifies the password profile for the user
# + aboutMe - A freeform text entry field for the user to describe themselves 
# + ageGroup - Sets the age group of the user
# + birthday - The birthday of the user. The Timestamp type represents date and time information using ISO 8601 format 
#              and is always in UTC time. For example, midnight UTC on Jan 1, 2014 is `2014-01-01T00:00:00Z`. 
# + businessPhones - The telephone numbers for the user. 
#                   **NOTE:** Although this is a string collection, only one number can be set for this property.  
# + city - The city in which the user is located. Maximum length is 128 characters.
# + companyName -  	The company name which the user is associated. This property can be useful for describing the 
#                   company that an external user comes from. The maximum length of the company name is 64 characters.  
# + consentProvidedForMinor - Sets whether consent has been obtained for minors  
# + country -  	The country/region in which the user is located; for example, US or UK. Maximum length is 128 characters.  
# + department -  	The name for the department in which the user works. Maximum length is 64 characters.
# + employeeId - The employee identifier assigned to the user by the organization 
# + employeeType - Captures enterprise worker type 
# + givenName - The given name (first name) of the user. Maximum length is 64 characters.  
# + hireDate - The hire date of the user. The Timestamp type represents date and time information using ISO 8601 format 
#              and is always in UTC time. For example, midnight UTC on Jan 1, 2014 is `2014-01-01T00:00:00Z`.   
# + interests - A list for the user to describe their interests  
# + jobTitle - The user's job title. Maximum length is 128 characters. 
# + mail - The SMTP address for the user, for example, jeff@contoso.onmicrosoft.com 
# + mobilePhone - The primary cellular telephone number for the user. Read-only for users synced from on-premises 
#                 directory. Maximum length is 64 characters. 
# + mySite - The URL for the user's personal site  
# + officeLocation - The office location in the user's place of business 
# + otherMails - A list of additional email addresses for the user
#                Example: ["bob@contoso.com", "Robert@fabrikam.com"] 
# + passwordPolicies - Specifies password policies for the user  
# + pastProjects - A list for the user to enumerate their past projects 
# + postalCode - The postal code for the user's postal address  
# + preferredLanguage - The preferred language for the user. Should follow ISO 639-1 Code; for example `en-US`. 
# + responsibilities - A list for the user to enumerate their responsibilities 
# + schools - A list for the user to enumerate the schools they have attended 
# + skills - A list for the user to enumerate their skills  
# + state - The state or province in the user's address. Maximum length is 128 characters 
# + streetAddress - The street address of the user's place of business. Maximum length is 1024 characters  
# + usageLocation - A two letter country code (ISO standard 3166). Required for users that will be assigned licenses
#                   due to legal requirement to check for availability of services in countries
#                   Examples: US, JP, and GB.   
# + surname - The user's surname (family name or last name). Maximum length is 64 characters
public type BaseUserData record {
    string? onPremisesImmutableId?;
    PasswordProfile? passwordProfile?;
    string? aboutMe?;
    AgeGroup? ageGroup?;
    string? birthday?;
    string[] businessPhones?;
    string? city?;
    string? companyName?;
    ConcentForMinor? consentProvidedForMinor?;
    string? country?;
    string? department?;
    string? employeeId?;
    EmployeeType? employeeType?;
    string? givenName?;
    string? hireDate?;
    string[] interests?;
    string? jobTitle?;
    string? mail?;
    string? mobilePhone?;
    string? mySite?;
    string? officeLocation?;
    string? otherMails?;
    PasswordPolicy? passwordPolicies?;
    string[] pastProjects?;
    string? postalCode?;
    string? preferredLanguage?;
    string[] responsibilities?;
    string[] schools?;
    string[] skills?;
    string? state?;
    string? streetAddress?;
    string? usageLocation?;
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

# Represents a new user to be added to the Active AD.
# 
# + accountEnabled - True if the account is enabled or else false
# + mailNickname - The mail alias for the user
# + displayName - The name displayed in the address book for the user
# + userPrincipalName - The user principal name (UPN) of the user
public type NewUser record {
    boolean accountEnabled;
    string mailNickname;
    string displayName;
    string userPrincipalName;
    *BaseUserData;
};

# Represents updatable Azure AD user account information.
#
# + accountEnabled - True if the account is enabled or else false
# + mailNickname - The mail alias for the user
# + displayName - The name displayed in the address book for the user. Maximum length is 256 characters.
# + userPrincipalName - The user principal name (UPN) of the user
public type UpdateUser record {
    boolean accountEnabled?;
    string mailNickname?;
    string displayName?;
    string userPrincipalName?;
    *BaseUserData;
};

# Represents an Azure AD user account.
#
# + id - The unique identifier for the user  
# + displayName -  	The name displayed in the address book for the user. Maximum length is 256 characters.
# + userPrincipalName - The user principal name (UPN) of the user
# + onPremisesExtensionAttributes - Contains extensionAttributes 1-15 for the user  
public type User record {
    string id?;
    string? displayName?;
    string? userPrincipalName?;
    *BaseUserData;
    ExtentionAttriute onPremisesExtensionAttributes?;
};

# Custom extention attributes of the user. Source of authority for this set of properties is the on-premises Active 
# Directory which is synchronized to Azure AD
#
# + extensionAttribute1 - First customizable extension attribute  
# + extensionAttribute2 - Second customizable extension attribute  
# + extensionAttribute3 - Third customizable extension attribute  
# + extensionAttribute4 - Fourth customizable extension attribute  
# + extensionAttribute5 - Fifth customizable extension attribute  
# + extensionAttribute6 - Sixth customizable extension attribute  
# + extensionAttribute7 - Seventh customizable extension attribute  
# + extensionAttribute8 - Eighth customizable extension attribute  
# + extensionAttribute9 - Ninth customizable extension attribute  
# + extensionAttribute10 - Tenth customizable extension attribute  
# + extensionAttribute11 - Eleventh customizable extension attribute  
# + extensionAttribute12 - Twelfth customizable extension attribute  
# + extensionAttribute13 - Thirteenth customizable extension attribute  
# + extensionAttribute14 - Fourteenth customizable extension attribute  
# + extensionAttribute15 - Fifteenth customizable extension attribute  
public type ExtentionAttriute record {
    string? extensionAttribute1?;
    string? extensionAttribute2?;
    string? extensionAttribute3?;
    string? extensionAttribute4?;
    string? extensionAttribute5?;
    string? extensionAttribute6?;
    string? extensionAttribute7?;
    string? extensionAttribute8?;
    string? extensionAttribute9?;
    string? extensionAttribute10?;
    string? extensionAttribute11?;
    string? extensionAttribute12?;
    string? extensionAttribute13?;
    string? extensionAttribute14?;
    string? extensionAttribute15?;
};

# Represents common Azure Active Directory (Azure AD) group information.
#
# + visibility - Specifies the group join policy and group content visibility for groups
# + description - An optional description for the group  
# + isAssignableToRole - Indicates whether this group can be assigned to an Azure Active Directory role or not  
# + owners - The owners of the group. The owners are a set of non-admin users who are allowed to modify this object. 
#            Limited to 100 owners.  
# + members - Users and groups that are members of this group  
# + classification - Describes a classification for the group (such as low, medium or high business impact) 
# + membershipRule - The rule that determines members for this group if the group is a dynamic group
# + membershipRuleProcessingState - Indicates whether the dynamic membership processing is on or paused
# + preferredDataLocation - The preferred data location for the group
# + preferredLanguage - The preferred language for a Microsoft 365 group. Should follow ISO 639-1 Code.
#                       Example: `en-US`. 
# + resourceProvisioningOptions - Specifies the group resources that are provisioned as part of Microsoft 365 group 
#                                 creation, that are not normally part of default group creation. 
# + theme - Specifies a Microsoft 365 group's color theme  
public type BaseGroupData record {
    GroupVisibility? visibility?;
    string? description?;
    boolean? isAssignableToRole?;
    string[] owners?;
    string[] members?;
    string? classification?;
    string? membershipRule?;
    MembershipRuleProcessingState? membershipRuleProcessingState?;
    string? preferredDataLocation?;
    string? preferredLanguage?;
    ResourceProvisionOption[] resourceProvisioningOptions?;
    Theme? theme?;
};

# Represents a new group to be added to the Active AD.
#
# + groupTypes - Specifies the group type and its membership  
# + displayName - The display name for the group 
# + mailEnabled - Specifies whether the group is mail-enabled  
# + securityEnabled -Specifies whether the group is a security group  
# + mailNickname - The mail alias for the group
# + resourceBehaviorOptions - Specifies the group behaviors that can be set for a Microsoft 365 group during creation
# + ownerIds - Represents the owners for the group at creation time.
# + memberIds - Represents the members for the group at creation time 
public type NewGroup record {
    *BaseGroupData;
    GroupType[] groupTypes;
    string displayName;
    boolean mailEnabled;
    boolean securityEnabled;
    string mailNickname;
    ResourceBehaviorOption[] resourceBehaviorOptions?;
    string[] ownerIds?;
    string[] memberIds?;
};

# Represents updatable Azure AD group information.
#
# + groupTypes - Specifies the group type and its membership  
# + description - An optional description for the group  
# + displayName - The display name for the group 
# + mailEnabled - Specifies whether the group is mail-enabled
# + securityEnabled -Specifies whether the group is a security group  
# + mailNickname - The mail alias for the group
# + allowExternalSenders - Indicates if people external to the organization can send messages to the group. 
#                          Default value is `false`
# + autoSubscribeNewMembers - Indicates if new members added to the group will be auto-subscribed to receive email 
#                             notifications
# + visibility - Specifies the group join policy and group content visibility for groups 
public type UpdateGroup record {
    GroupType[] groupTypes?;
    string description?;
    string displayName?;
    boolean mailEnabled?;
    boolean securityEnabled?;
    string mailNickname?;
    boolean allowExternalSenders?;
    boolean autoSubscribeNewMembers?;
    GroupVisibility visibility?;
};

# Represents an Azure Active Directory (Azure AD) group.
#
# + id - The unique identifier for the group 
# + resourceBehaviorOptions - Specifies the group behaviors that can be set for a Microsoft 365 group during creation
# + allowExternalSenders - Indicates if people external to the organization can send messages to the group  
# + assignedLabels - The list of sensitivity label pairs (label ID, label name) associated with a Microsoft 365 group  
# + assignedLicenses - The licenses that are assigned to the group  
# + autoSubscribeNewMembers - Indicates if new members added to the group will be auto-subscribed to receive email 
#                             notifications
# + createdDateTime - Timestamp of when the group was created. Represents date and time information using ISO 8601 
#                     format and is always in UTC time. For example, midnight UTC on Jan 1, `2014 is 2014-01-01T00:00:00Z`. 
# + deletedDateTime - The date and time when the object was deleted
# + renewedDateTime - Timestamp of when the group was last renewed 
# + expirationDateTime - Timestamp of when the group is set to expire 
# + hideFromAddressLists - True if the group is not displayed in certain parts of the Outlook UI: the Address Book, 
#                          address lists for selecting message recipients, and the Browse Groups dialog for searching 
#                          groups; otherwise, false. 
# + hideFromOutlookClients - True if the group is not displayed in Outlook clients, such as Outlook for Windows and 
#                            Outlook on the web; otherwise, false. 
# + isSubscribedByMail - Indicates whether the signed-in user is subscribed to receive email conversations. Default 
#                        value is `true` 
# + licenseProcessingState - Indicates status of the group license assignment to all members of the group. Default value 
#                            is `false`
# + onPremisesDomainName - On premises domain name  
# + onPremisesLastSyncDateTime - On premises last sync date/time  
# + onPremisesNetBiosName - On premises net bios name   
# + onPremisesSamAccountName - On premises SAM account name   
# + onPremisesSecurityIdentifier - On premises security identifier
# + onPremisesSyncEnabled - On premises sync enabled   
# + proxyAddresses - Email addresses for the group that direct to the same group mailbox. 
#                    Example: ["SMTP: bob@contoso.com", "smtp: bob@sales.contoso.com"] 
public type Group record {
    string id?;
    *BaseGroupData;
    ResourceBehaviorOption[] resourceBehaviorOptions?;
    boolean? allowExternalSenders?;
    AssignedLabel[] assignedLabels?;
    AssignedLicense[] assignedLicenses?;
    boolean? autoSubscribeNewMembers?;
    string? createdDateTime?;
    string? deletedDateTime?;
    string? renewedDateTime?;
    string? expirationDateTime?;
    string? hideFromAddressLists?;
    string? hideFromOutlookClients?;
    boolean? isSubscribedByMail?;
    string? licenseProcessingState?;
    string? onPremisesDomainName?;
    string? onPremisesLastSyncDateTime?;
    string? onPremisesNetBiosName?;
    string? onPremisesSamAccountName?;
    string? onPremisesSecurityIdentifier?;
    boolean? onPremisesSyncEnabled?;
    string[] proxyAddresses?;
};

# Represents a sensitivity label assigned to an Microsoft 365 group.
#
# + labelId - The unique identifier of the label  
# + displayName - The display name of the label 
public type AssignedLabel record {
    string labelId;
    string displayName;
};

# Represents a license assigned to a user.
#
# + disabledPlans - A collection of the unique identifiers for plans that have been disabled  
# + skuId - The unique identifier for the SKU  
public type AssignedLicense record {
    string[] disabledPlans;
    string skuId;
};

# Represents the permission that has been granted to a specific AzureAD app for an instance of a resource in Microsoft 
# Graph.
#
# + id - The unique identifier of the resource-specific permission grant  
# + deletedDateTime - Deleted date/time  
# + clientId - ID of the Azure AD app that has been granted access  
# + clientAppId - ID of the service principal of the Azure AD app that has been granted access
# + resourceAppId - ID of the Azure AD app that is hosting the resource
# + permissionType - The type of permission 
# + permission - The name of the resource-specific permission
public type PermissionGrant record {
    string id;
    string deletedDateTime?;
    string clientId?;
    string clientAppId?;
    string resourceAppId?;
    PermissionType permissionType?;
    string permission?;
};
