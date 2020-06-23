Client Connector for Azure Active Directory
[//]: # (above is the module summary)

# Module Overview
Azure AD Client Connector allows you to perform operations on Users and Group of an Azure AD. The operations performed using the v1.0 version of Microsoft Graph API. The client uses OAuth 2.0 authentication.

## Compatibility
|                     |    Version     |
|:-------------------:|:--------------:|
| Ballerina Language  | 1.2.4          |

## Sample

**Create the Azure AD Client**

First, execute the below command to download `ballerinax/azure.ad` module into the Ballerina module repository.
```ballerina
ballerina pull ballerinax/azure.ad
```

Next import the module to your Ballerina project as below.
```ballerina
import ballerinax/azure.'ad as ad;
```

Instantiate the `ad:Client` by giving OAuth2 authentication details in the `ad:ClientConfiguration`. 

You can define the Azure AD configuration and create the Azure AD client as follows. 
```ballerina
ad:ClientCredentialsGrantConfig clientCredentialOAuth2Config = {
    tenantID: "",
    clientId: "",
    clientSecret: ""
};

ad:ClientConfiguration clientConfig = {
    authHandler: ad:getAzureADOutboundOAuth2BearerHandler(clientCredentialOAuth2Config)
};
ad:Client adClient = new(clientConfig);
```

# Outbound Auth Handler for Azure Services
This module provides an Outbound Auth Handler which can be configured to an http:Listener that connects to an 
Microsoft Graph API.

The Auth Handler can be retrieved by invoking the following function:
```ballerina
ad:getAzureADOutboundOAuth2BearerHandler(...)
```

See examples at https://github.com/ballerina-platform/module-ballerinax-azure.ad/blob/ad-implementation/src/azure.ad/tests/client_auth_tests.bal

# Inbound Auth Handler for User Authentication
The module provides an Inbound AuthHandler which be plugged to any http:Listener where every incoming request gets authenticated against Azure AD. The requests must contain Basic Auth Headers.

The Auth Handler can be retrieved by invoking the following function:
```ballerina
public listener http:Listener myEP = new(9090, {
    auth: {
        authHandlers: [ad:getAzureADInboundBasicAuthHandler("", "", "")]
    },
    secureSocket: {
        keyStore: {
            path: "src/azure.ad/tests/resources/ballerinaKeystore.p12",
            password: "ballerina"
        }
    }
});
```

See examples at https://github.com/ballerina-platform/module-ballerinax-azure.ad/blob/ad-implementation/src/azure.ad/tests/inbound_user_authenticator_tests.bal

# Client Operations
**Azure AD operations related to `Users`**

```ballerina
ad:NewUser newUser1 = {
    accountEnabled: true,
    displayName: "Garfield Lynns",
    mailNickname: "garfieldlynns",
    passwordProfile: {
        forceChangePasswordNextSignIn: false,
        password: "Apple*83"
    },
    userPrincipalName: "garfieldlynns@hemikak.onmicrosoft.com",
    ...additionalUser1Attributes
};

// Creating a new user
ad:User user = checkpanic adClient->createUser(newUser1);
io:println(user.displayName);

// Getting user by user principal name
user = checkpanic adClient->getUser("garfieldlynns@hemikak.onmicrosoft.com");
io:println(user.displayName);

// Getting user with additional fields
user = checkpanic adClient->getUser("garfieldlynns@hemikak.onmicrosoft.com", additionalFields = ["postalCode"]);
io:println(user["postalCode"]);

// Updating the user
user.jobTitle = "Senior DevOps Engineer";
checkpanic adClient->updateUser(<@untainted>user);

// Deleting the user
checkpanic adClient->deleteUser(<@untainted>user);
```

**Azure AD operations related to `Groups`**

```ballerina
ad:NewGroup newGroup1 = {
    description: "Beeper cars managers group",
    displayName: "Beeper Cars - Managers",
    mailNickname: "bcmanagers",
    groupTypes: ["Unified"],
    mailEnabled: true,
    securityEnabled: false
};

// Create a new group
ad:Group createdGroup = checkpanic adClient->createGroup(newGroup1);

// Get all the groups
ad:Group[] adGroups = checkpanic adClient->getGroups();

// Get group by ID
ad:Group adGroup = checkpanic adClient->getGroup("9f323ew5-b8jc-414c-9397-8cn791ob2231");

// Add member to group
checkpanic adClient->addMemberToGroup(<@untainted>adGroup, <@untainted>user);

// Get group members
(ad:User|ad:Group|ad:Device)[] members = checkpanic adClient->getGroupMembers(<@untainted>adGroup);

// Remove member from group
checkpanic adClient->removeMemberFromGroup(<@untainted>adGroup, <@untainted>user);

// Add an owner to group
checkpanic adClient->addOwnerToGroup(<@untainted>adGroup, <@untainted>user);

// Get group owners
ad:User[] owners = checkpanic adClient->getGroupOwners(<@untainted>adGroup);

// Remove an owner to group
checkpanic adClient->removeOwnerFromGroup(<@untainted>adGroup, <@untainted>user);

// Delete group
checkpanic adClient->deleteGroup(<@untainted>adGroup);
```

