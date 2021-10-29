Ballerina Azure Active Directory Connector
===================

[![Build Status](https://github.com/ballerina-platform/module-ballerinax-azure.ad/workflows/CI/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-msgraph-teams/actions?query=workflow%3ACI)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-azure.ad.svg)](https://github.com/ballerina-platform/module-ballerinax-msgraph-teams/commits/master)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

Azure Active Directory(AD) is Microsoft’s multi-tenant, cloud-based directory and identity management service. It provides capabilities to enable Single Sign-On (SSO), multi-factor authentication, self-service password reset, privileged identity management, role-based access control, etc., to first and third-party Software as a Service (SaaS) applications.

Azure AD Connector allows you to perform operations on users and groups in an Azure AD using the v1.0 version of Microsoft Graph API. The client supports OAuth 2.0 authentication.

For more information, see module(s).
- [azure.ad](aad/Module.md)

## Building from the source
### Setting up the prerequisites
1.  Download and install Java SE Development Kit (JDK) version 11. You can install either [OpenJDK](https://adoptopenjdk.net/) or [Oracle JDK](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html).
   > **Note:** Set the JAVA_HOME environment variable to the path name of the directory into which you installed JDK.
 
2. Download and install [Ballerina Swan Lake Beta3](https://ballerina.io/)
 
### Building the source
 
Execute the following commands to build from the source:
 
- To build the package:
   ```   
   bal pack --with-tests ./aad
   ```
- To build the package without tests:
   ```
   bal pack ./aad
   ```
## Contributing to ballerina
 
As an open source project, Ballerina welcomes contributions from the community.
 
For more information, see [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).
 
## Code of conduct
 
All contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).
 
## Useful links
 
* Discuss code changes of the Ballerina project via [ballerina-dev@googlegroups.com](mailto:ballerina-dev@googlegroups.com).
* Chat live with us via our [Slack channel](https://ballerina.io/community/slack/).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
