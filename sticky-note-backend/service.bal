import ballerina/http;
import ballerina/sql;

type MapAnyData map<anydata>;

# A service representing a network-accessible API
# bound to port `8080`.

// @http:ServiceConfig {
//     cors: {
//         allowOrigins: ["http://localhost:5173"],
//         allowCredentials: true,
//        allowMethods: ["GET", "POST", "PUT","DELETE"]
//     }
// }
service / on new http:Listener(8080) {

    # A resource representing an invokable API method accessible at `/getNote/{id}`.
    # This resource is used with path parameters
    # + return - A string payload which eventually becomes 
    # the payload of the response
    resource function get getNote/[int id](http:Caller caller) returns error? {
        http:Response resp = new;
        Data|error result = GetDataItemById(id);

        if (result is Data) {
            resp.setJsonPayload(result.toJson());
            resp.statusCode = 200;

        } else {
            resp.setJsonPayload(result.toString().toJson());
            resp.statusCode = 409;

        }
        resp.setHeader("Content-type", "application/json");
        check caller->respond(resp);
    }

    # A resource representing an invokable API method accessible at `/getNotes`.
    # + return - A string payload which eventually becomes
    # the payload of the response
    resource function get getNotes(http:Caller caller) returns error? {
        http:Response resp = new;
        Data[]|error result = GetDataItems();

        if (result is Data[]) {
            resp.setJsonPayload(result.toJson());
            resp.statusCode = 200;

        } else {
            resp.setJsonPayload(result.toString().toJson());
            resp.statusCode = 409;

        }
        resp.setHeader("Content-type", "application/json");
        check caller->respond(resp);
    }

    # A resource representing an invokable API method accessible at `/addNote`.
    #
    # + return - A string payload which eventually becomes 
    # the payload of the response
    resource function post addNote(http:Caller caller, @http:Payload MapAnyData payload) returns error? {
        http:Response resp = new;
        map<anydata>|error entryDataMap = payload.cloneWithType(MapAnyData);

        if (entryDataMap is error) {
            resp.statusCode = 400;
            resp.setPayload("Payload extraction failed. Provide the correct payload");

        } else {
            any|error description = entryDataMap.get("description");
            if (description is error) {
                resp.statusCode = 400;
                resp.setPayload("Payload extraction failed. Provide the correct payload with orgName");

            } else {

                Data|error result = AddDataItem(description.toString());
                if (result is error) {
                    resp.statusCode = 409;
                    resp.setPayload(result.message());
                } else {
                    resp.statusCode = 200;
                    resp.setPayload(result.toJson());
                }

            }
        }
        resp.setHeader("Content-type", "application/json");
        check caller->respond(resp);
    }

    # A resource representing an invokable API method accessible at `/updateNote/{id}`.
    # This resource is used with path parameters
    # + return - A string payload which eventually becomes
    # the payload of the response
    resource function put updateNote/[int id](http:Caller caller, @http:Payload MapAnyData payload) returns error? {
        http:Response resp = new;
        map<anydata>|error entryDataMap = payload.cloneWithType(MapAnyData);

        if (entryDataMap is error) {
            resp.statusCode = 400;
            resp.setPayload("Payload extraction failed. Provide the correct payload");

        } else {
            any|error description = entryDataMap.get("description");
            if (description is error) {
                resp.statusCode = 400;
                resp.setPayload("Payload extraction failed. Provide the correct payload with orgName");

            } else {

                Data|error result = updateDataItem(id, description.toString());
                if (result is error) {
                    resp.statusCode = 409;
                    resp.setPayload(result.message());
                } else {
                    resp.statusCode = 200;
                    resp.setPayload(result.toJson());
                }

            }
        }
        resp.setHeader("Content-type", "application/json");
        check caller->respond(resp);
    }

    # A resource representing an invokable API method accessible at `/deleteNote/{id}`.
    # This resource is used with path parameters
    # + return - A string payload which eventually becomes
    # the payload of the response
    # + id - The path parameter which is used to identify the note
    # to be deleted
    resource function delete deleteNote/[int id](http:Caller caller) returns error? {
        http:Response resp = new;
        error? result = deleteDataItem(id);

        if (result is error) {
            resp.statusCode = 409;
            resp.setPayload(result.message());
        } else {
            resp.statusCode = 200;
            resp.setPayload("Deleted successfully");
        }

        resp.setHeader("Content-type", "application/json");
        check caller->respond(resp);
    }
}

public function main() returns error? {
    sql:Error? errorInInit = initializeDatabase();
    string|sql:Error? errorInCreate = initializeTable();

}

