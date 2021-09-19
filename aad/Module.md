## Overview
Ballerina connector for Azure Active Directory (AD) is connecting the Azure AD REST API in Microsoft Graph v1.0 via Ballerina language. 
It provides capability to perform management operations on user and group resources in an Azure AD tenent 
(Organization).

The connector uses the Microsoft Graph REST web API that provides the capability to access Microsoft Cloud service resources. This version of the connector only supports the operations on users and groups in an Azure AD.
 
This module supports [Microsoft Graph API](https://docs.microsoft.com/en-us/graph/overview) `v1.0`. 

## Prerequisites
Before using this connector in your Ballerina application, complete the following:

* Create a [Microsoft 365 Work and School account](https://www.office.com/)
* Create an [Azure account](https://azure.microsoft.com/en-us/) to register an application in the Azure portal
* Obtain tokens
    - Use [this](https://docs.microsoft.com/en-us/graph/auth-register-app-v2) guide to register an application with the Microsoft identity platform
    - The necessary scopes for this connector are shown below

    | Permissions name              | Type      | Description                               |
    |:-----------------------------:|:---------:|:-----------------------------------------:|
    | User.ReadWrite.All            | Delegated | Create channels                           |
    | Group.ReadWrite.All           | Delegated | Read and write all users' full profiles   |

## Quickstart
To use the Azure AD connector in your Ballerina application, update the .bal file as follows:
### Step 1 - Import connector
Import the ballerinax/aad module into the Ballerina project.
```ballerina
import ballerinax/azure.aad;
```
### Step 2 - Create a new connector instance
You can now make the connection configuration using the OAuth2 refresh token grant config.
```ballerina
aad:ConnectionConfig configuration = {
    auth: {
        refreshUrl: <REFRESH_URL>,
        refreshToken : <REFRESH_TOKEN>,
        clientId : <CLIENT_ID>,
        clientSecret : <CLIENT_SECRET>
    }
};

aad:Client aadClient = check new (config);
```
### Step 3 - Invoke connector operation

1. Create an Azure AD User
```ballerina
ad:NewUser info = {
    accountEnabled: true,
    displayName: "<DISPLAY_NAME>",
    userPrincipalName: "<USER_PRINCIPAL_NAME>",
    mailNickname: "<MAIL_NICKNAME>",
    passwordProfile: {
        password: "<PASSWORD>",
        forceChangePasswordNextSignIn: true
    },
    surname: "<SURNAME>"
};

ad:User|error userInfo = aadClient->createUser(info);
if (userInfo is ad:User) {
    log:printInfo("User succesfully created " + userInfo?.id.toString());
} else {
    log:printError(userInfo.message());
}
```
2. Use `bal run` command to compile and run the Ballerina program.

**[You can find a list of samples here](https://github.com/ballerina-platform/module-ballerinax-azure.ad/tree/master/aad/samples)**
