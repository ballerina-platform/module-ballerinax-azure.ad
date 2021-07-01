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
