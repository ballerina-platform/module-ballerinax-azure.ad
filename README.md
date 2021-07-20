Ballerina Azure Active Directory Connector
===================

[![Build Status](https://github.com/ballerina-platform/module-ballerinax-azure.ad/workflows/CI/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-msgraph-teams/actions?query=workflow%3ACI)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-azure.ad.svg)](https://github.com/ballerina-platform/module-ballerinax-msgraph-teams/commits/master)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

Azure Active Directory is Microsoft’s multi-tenant, cloud-based directory and identity management service which provides 
capabilities to enable  Single Sign-On (SSO) ,multi-factor authentication, self-service password reset, privileged identity 
management, role based access control etc to first and third-party Software as a Service (SaaS) applications.

Azure AD Client Connector allows you to perform operations on users and groups of an Azure AD. The operations are 
performed using the v1.0 version of Microsoft Graph API. The client uses OAuth 2.0 authentication.

## Building from the Source
### Setting Up the Prerequisites
1. Download and install Java SE Development Kit (JDK) version 11 (from one of the following locations).
 
  * [Oracle](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html)
 
  * [OpenJDK](https://adoptopenjdk.net/)
 
       > **Note:** Set the JAVA_HOME environment variable to the path name of the directory into which you installed
       JDK.
 
2. Download and install [Ballerina](https://ballerina.io/)

### Building the Source
 
Execute the commands below to build from the source.
 
1. To build the package:
   ```   
   bal build -c ./aad
   ```
2. To run the without tests:
   ```
   bal build -c --skip-tests ./aad
   ```
## Contributing to Ballerina
 
As an open source project, Ballerina welcomes contributions from the community.
 
For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).
 
## Code of Conduct
 
All contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).
 
## Useful Links
 
* Discuss code changes of the Ballerina project in [ballerina-dev@googlegroups.com](mailto:ballerina-dev@googlegroups.com).
* Chat live with us via our [Slack channel](https://ballerina.io/community/slack/).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
