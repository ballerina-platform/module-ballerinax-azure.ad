// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

# The age group of the user.
# 
# + NULL - Default value, no ageGroup has been set for the user
# + MINOR - The user is considered a minor
# + NOT_ADULT - Teenagers who are considered as notAdult in regulated countries
# + ADULT - The user should be a treated as an adult
public enum AgeGroup {
    NULL = "null",
    MINOR = "minor",
    NOT_ADULT = "notAdult",
    ADULT = "adult"
}

# Condition of the capability assignment. 
# 
# + ENABLED - Available for normal use
# + WARNING - Available for normal use but is in a grace period
# + SUSPENDED - Unavailable but any data associated with the capability must be preserved
# + DELETED - Unavailable and any data associated with the capability may be deleted
# + LOCKED_OUT - Unavailable for all administrators and users but any data associated with the capability must be 
#                preserved
public enum CapabilityStatus {
    ENABLED = "Enabled",
    WARNING = "Warning",
    SUSPENDED = "Suspended",
    DELETED = "Deleted",
    LOCKED_OUT = "LockedOut"
}

# Consent which has been obtained for minors.
# 
# + NULL_CONCENT - Default value, no consentProvidedForMinor has been set for the user
# + GRANTED - Consent has been obtained for the user to have an account
# + DENIED - Consent has not been obtained for the user to have an account
# + NOT_REQUIRED - The user is from a location that does not require consent
public enum ConcentForMinor {
    NULL_CONCENT = "null",
    GRANTED = "granted",
    DENIED = "denied",
    NOT_REQUIRED = "notRequired"
}

# Represent the enterprise worker type.
# 
# + EMPLOYEE - 
# + CONTRACTOR - 
# + CONSULTANT - 
# + VENDOR - 
public enum EmployeeType {
    EMPLOYEE = "Employee",
    CONTRACTOR = "Contractor",
    CONSULTANT = "Consultant",
    VENDOR = "Vendor"
}

# Specifies the visibility of a Microsoft 365 group.
# 
# + PRIVATE -
# + PUBLIC - 
# + HIDDEN - 
# + EMPTY -
public enum GroupVisibility {
    PRIVATE = "Private",
    PUBLIC = "Public",
    HIDDEN = "HiddenMembership",
    EMPTY = ""
}

# Specifies the visibility of a Microsoft 365 group.
# 
# + USER -
# + GROUP - 
public enum DirctoryObject {
    USER = "user",
    GROUP = "group"
}

enum SystemQueryOption {
    EXPAND = "expand",
    SELECT = "select",
    FILTER = "filter",
    COUNT = "count",
    ORDERBY = "orderby",
    SKIP = "skip",
    TOP = "top",
    SEARCH = "search",
    BATCH = "batch",
    FORMAT = "format"
}

enum OpeningCharacters {
    OPEN_BRACKET = "(",
    OPEN_SQURAE_BRACKET = "[",
    OPEN_CURLY_BRACKET = "{",
    SINGLE_QUOTE_O = "'",
    DOUBLE_QUOTE_O = "\""
}

enum ClosingCharacters {
    CLOSE_BRACKET = ")",
    CLOSE_SQURAE_BRACKET = "]",
    CLOSE_CURLY_BRACKET = "}",
    SINGLE_QUOTE_C = "'",
    DOUBLE_QUOTE_C = "\""
}

# Constant field `BASE_URL`. Holds the value of the Microsoft graph API's endpoint URL.
const string BASE_URL = "https://graph.microsoft.com/v1.0";

# Symbols
const EQUAL_SIGN = "=";
const EMPTY_STRING = "";
const DOLLAR_SIGN = "$";
const FORWARD_SLASH = "/";
const AMPERSAND = "&";
const QUESTION_MARK = "?";

# Numbers
const ZERO = 0;

# Path parameters
const USERS = "users";
const GROUPS = "groups";
const MEMBER_OF = "memberOf";
const MEMBERS = "members";
const TRANSITIVE_MEMBERS = "transitiveMembers";
const OWNERS = "owners";
const TRANSITIVE_MEMBER_OF = "transitiveMemberOf";
const PERMISSION_GRANTS = "permissionGrants";
