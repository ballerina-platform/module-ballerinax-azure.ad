## Overview
Ballerina connector for Azure AD is connecting the Azure AD REST API in Microsoft Graph v1.0 via Ballerina language 
easily. It provides capability to perform management operations on `User` and `Group` resources in an Azure AD tenent 
(Organization).

The connector is developed on top of Microsoft Graph is a REST web API that empowers you to access Microsoft Cloud 
service resources. This version of the connector only supports the operations on users and groups of an Azure AD
 
This module supports [Microsoft Graph API](https://docs.microsoft.com/en-us/graph/overview) v1.0 version. 
## Configuring connector
### Prerequisites
- Microsoft Office365 Work or School account
- Access to register an application in Azure portal
## Obtaining tokens
1. Sign into [Azure Portal - App Registrations](https://portal.azure.com/#blade/Microsoft_AAD_RegisteredApps/ApplicationsListBlade). You should use your work or school account to register.

2. In the App registrations page, click **New registration** and enter a meaningful name in the name field.

3. In the **Supported account types** section, select **Accounts in this organizational directory only (Single-tenant)** or **Accounts in any organizational directory (Any Azure AD directory - Multi-tenant)**. Click **Register** to create the application.
    
4. Copy the Application (client) ID (`<CLIENT_ID>`). This is the unique identifier for your app.
    
5. In the application's list of pages (under the **Manage** tab in left hand side menu), select **Authentication**.
    Under **Platform configurations**, click **Add a platform**.

6. Under **Configure platforms**, click **Web** located under **Web applications**.

7. Under the **Redirect URIs text box**, register the https://login.microsoftonline.com/common/oauth2/nativeclient url.
   Under **Implicit grant**, select **Access tokens**.
   Click **Configure**.

8. Under **Certificates & Secrets**, create a new client secret (`<CLIENT_SECRET>`). This requires providing a description and a period of expiry. Next, click **Add**.

9. Next, you need to obtain an access token and a refresh token to invoke the Microsoft Graph API.
    - First, in a new browser, enter the below URL by replacing the `<CLIENT_ID>` with the application ID. 

    - Here you need to provide a space seperated list of necessary scope names for `<SCOPES>`. The necessary scopes for this
    version of the connector are `Group.ReadWrite.All` and `User.ReadWrite.All`.

    ```
    https://login.microsoftonline.com/common/oauth2/v2.0/authorize?response_type=code&client_id=<CLIENT_ID>&redirect_uri=https://login.microsoftonline.com/common/oauth2/nativeclient&scope=<SCOPES> offline_access
    ```

10. This will prompt you to enter the username and password for signing into the Azure Portal App.

11. Once the username and password pair is successfully entered, this will give a URL as follows on the browser address bar.

    ```
    https://login.microsoftonline.com/common/oauth2/nativeclient?code=xxxxxxxxxxxxxxxxxxxxxxxxxxx
    ```

12. Copy the code parameter (`xxxxxxxxxxxxxxxxxxxxxxxxxxx` in the above example) and in a new terminal, enter the following cURL command by replacing the `<CODE>` with the code received from the above step. The `<CLIENT_ID>` and `<CLIENT_SECRET>` parameters are the same as above.

    ```
    curl -X POST --header "Content-Type: application/x-www-form-urlencoded" --header "Host:login.microsoftonline.com" -d "client_id=<CLIENT_ID>&client_secret=<CLIENT_SECRET>&grant_type=authorization_code&redirect_uri=https://login.microsoftonline.com/common/oauth2/nativeclient&code=<CODE>&scope=<SCOPES> offline_access" https://login.microsoftonline.com/common/oauth2/v2.0/token
    ```

    The above cURL command should result in a response as follows.
    ```
    {
      "token_type": "Bearer",
      "scope": openid <LIST_OF_SCOPES>",
      "expires_in": 3600,
      "ext_expires_in": 3600,
      "access_token": "<ACCESS_TOKEN>",
      "refresh_token": "<REFRESH_TOKEN>"
    }
    ```

13. Provide the following configuration information in the `Config.toml` file to use the Azure AD connector.

    ```ballerina
    [ballerinax.azure.ad]
    refreshUrl = <MS_REFRESH_URL>
    refreshToken = <MS_REFRESH_TOKEN>
    clientId = <MS_CLIENT_ID>
    clientSecret = <MS_CLIENT_SECRET>
    ```
    ```

## Quickstart
## Create Azure AD User
### Step 1: Import Azure AD Package
First, import the ballerinax/msgraph_onedrive module into the Ballerina project.
```ballerina
import ballerinax/azure.aad;
```
### Step 2: Configure the connection to an existing Azure AD app
You can now make the connection configuration using the OAuth2 refresh token grant config.
```ballerina
aad:Configuration configuration = {
    clientConfig: {
        refreshUrl: <REFRESH_URL>,
        refreshToken : <REFRESH_TOKEN>,
        clientId : <CLIENT_ID>,
        clientSecret : <CLIENT_SECRET>
    }
};
```
### Step 3: Create Azure AD client
```ballerina
aad:Client aadClient = check new (config);
```
### Step 4: Create an Azure AD User
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

## Add the User into an existing Group
### Step 1: Import Azure AD Package
First, import the ballerinax/msgraph_onedrive module into the Ballerina project.
```ballerina
import ballerinax/azure.aad;
```
### Step 2: Configure the connection to an existing Azure AD app
You can now make the connection configuration using the OAuth2 refresh token grant config.
```ballerina
aad:Configuration configuration = {
    clientConfig: {
        refreshUrl: <REFRESH_URL>,
        refreshToken : <REFRESH_TOKEN>,
        clientId : <CLIENT_ID>,
        clientSecret : <CLIENT_SECRET>
    }
};
```
### Step 3: Create Azure AD client
```ballerina
aad:Client aadClient = check new (config);
```
### Step 4: Add Azure AD User to a Group
```ballerina
    string groupId = "<GROUP_ID>";
    string memberId = "<USER_ID>";

    error? result = aadClient->addGroupMember(groupId, memberId);
    if (result is ()) {
        log:printInfo("Sucessfully added group member");
    } else {
        log:printError(result.message());
    }
```
## [You can find more samples here](https://github.com/ballerina-platform/module-ballerinax-azure.ad/tree/master/aad/samples)