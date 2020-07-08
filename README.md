# Ballerina Azure Active Directory Connector

Azure AD Client Connector allows you to perform operations on users and groups of an Azure AD. The operations are performed using the v1.0 version of Microsoft Graph API. The client uses OAuth 2.0 authentication.

### Compatibility
|                     |    Version     |
|:-------------------:|:--------------:|
| Ballerina Language  | 1.2.x          |

### Sample

**Create the Azure AD Client**

First, execute the below command to download the `ballerinax/azure.ad` module into the Ballerina module repository.
```ballerina
ballerina pull ballerinax/azure.ad
```

Next, execute the command below to import the module to your Ballerina project.
```ballerina
import ballerinax/azure.'ad as ad;
```

Instantiate the `ad:Client` by specifying the OAuth2 authentication details in the `ad:ClientConfiguration`. 

You can define the Azure AD configuration and create the Azure AD client as follows. 
```ballerina
ad:ClientCredentialsGrantConfig clientCredentialOAuth2Config = {
    tenantId: "",
    clientId: "",
    clientSecret: ""
};

ad:ClientConfiguration clientConfig = {
    authHandler: ad:getOutboundOAuth2BearerHandler(clientCredentialOAuth2Config)
};
ad:Client adClient = new(clientConfig);
```

## Outbound Auth Handler for Azure Services
This module provides an Outbound Auth Handler, which can be configured to an `http:Listener`, which connects to a
Microsoft Graph API.

The Auth Handler can be retrieved by invoking the following function:
```ballerina
ad:getOutboundOAuth2BearerHandler(...)
```

See examples at https://github.com/ballerina-platform/module-ballerinax-azure.ad/blob/ad-implementation/src/azure.ad/tests/client_auth_tests.bal

## Inbound Auth Handler for User Authentication
This module provides an Inbound AuthHandler, which can be plugged to any `http:Listener` in which every incoming request gets authenticated against Azure AD. The requests must contain the basic auth headers.

The Auth Handler can be retrieved by invoking the following function:
```ballerina
public listener http:Listener myEP = new(9090, {
    auth: {
        authHandlers: [ad:getAzureAdInboundBasicAuthHandler("", "", "")]
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

## Client Operations
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

// Getting a user by the user's principal name
user = checkpanic adClient->getUser("garfieldlynns@hemikak.onmicrosoft.com");
io:println(user.displayName);

// Getting a user with additional fields
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

// Get a group by its ID
ad:Group adGroup = checkpanic adClient->getGroup("9f323ew5-b8jc-414c-9397-8cn791ob2231");

// Add a member to a group
checkpanic adClient->addMemberToGroup(<@untainted>adGroup, <@untainted>user);

// Get the members of a group
(ad:User|ad:Group|ad:Device)[] members = checkpanic adClient->getGroupMembers(<@untainted>adGroup);

// Remove a member from a group
checkpanic adClient->removeMemberFromGroup(<@untainted>adGroup, <@untainted>user);

// Add an owner to a group
checkpanic adClient->addOwnerToGroup(<@untainted>adGroup, <@untainted>user);

// Get the group owners
ad:User[] owners = checkpanic adClient->getGroupOwners(<@untainted>adGroup);

// Remove an owner from a group
checkpanic adClient->removeOwnerFromGroup(<@untainted>adGroup, <@untainted>user);

// Delete a group
checkpanic adClient->deleteGroup(<@untainted>adGroup);
```
