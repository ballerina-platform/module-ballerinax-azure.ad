
public function parseError(json errorJsonPayload) returns GraphAPIError|InvalidErrorPayload {
    json|error errorJsonOrError = errorJsonPayload.'error;

    if (errorJsonOrError is error) {
        InvalidErrorPayload payloadError = InvalidErrorPayload(message = "unable to parse json error payload: " + errorJsonPayload.toJsonString());
        return payloadError;
    }

    json errorJson = <json>errorJsonOrError;
    json|error codeJsonOrError = errorJson.code;
    if (codeJsonOrError is error) {
        InvalidErrorPayload payloadError = InvalidErrorPayload(message = "unable to find error code: " + errorJsonPayload.toJsonString());
        return payloadError;
    }
    json codeJson  = <json>codeJsonOrError;

    json|error messageJsonOrError = errorJson.message;
    if (messageJsonOrError is error) {
        InvalidErrorPayload payloadError = InvalidErrorPayload(message = "unable to find error message: " + errorJsonPayload.toJsonString());
        return payloadError;
    }
    json messageJson = <json>messageJsonOrError;

    map<anydata> details = {};
    json|error detailsJsonOrError = errorJson.innerError;
    if (detailsJsonOrError is json) {
        map<anydata>|error detailsMapOrError = map<anydata>.constructFrom(detailsJsonOrError);
        if (detailsMapOrError is map<anydata>) {
            details = detailsMapOrError;
        }
    }
    
    GraphAPIError generalError = error(codeJson.toString(), message = messageJson.toString(), innerError = details);
    return generalError;
}