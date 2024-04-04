import ballerina/io;
import ballerina/log;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

public type Data record {|
    int Id;
    string Description;
|};

configurable string dbHost = "localhost";
configurable string dbUser = "user";
configurable string dbPassword = "password";
configurable string dbName = "db";
configurable int port = 3308;

mysql:Client mysqlClient = check new (dbHost, dbUser, dbPassword, dbName, port);

public function initializeDatabase() returns sql:Error? {

    sql:ParameterizedQuery createDbQuery = `CREATE DATABASE IF NOT EXISTS ${dbName}`;
    sql:ExecutionResult result = check mysqlClient->execute(createDbQuery);
    io:println(result);
    io:println("Database created.");
}

public function initializeTable() returns sql:Error? {

    sql:ParameterizedQuery AddSampleDataTableQuery = `CREATE TABLE IF NOT EXISTS Note (Id INTEGER NOT NULL AUTO_INCREMENT, Description  VARCHAR(300) , PRIMARY KEY (Id))`;

    sql:ExecutionResult|error result = check mysqlClient->execute(AddSampleDataTableQuery);
    if (result is error) {
        return error(result.message());
    } else {
        if (result is sql:ExecutionResult) {
            log:printInfo("Add table executed. " + result.toString());
        }
        return;
    }

}

# GetDataItemById - This method is used to get an item from the databae
#
# + id - Id of the data item to retrieve
# + return - Ruturn the added data item if passed, or return error if something failed. 
public function GetDataItemById(int id) returns Data|error {

    log:printInfo("SQL GetDataItemById Method Reached");

    sql:ParameterizedQuery GetDataItemByIdQuery = `SELECT * FROM Note WHERE Id = ${id}`;
    stream<record {}, error?> resultStream = mysqlClient->query(GetDataItemByIdQuery);

    record {|
        record {} value;
    |}|error? result = resultStream.next();
    if (result is record {|
        record {} value;
    |}) {
        //Map result into structure
        Data addedItem = {
            Id: <int>result.value["Id"],
            Description: <string>result.value["Description"]
        };
        return addedItem;

    } else if (result is error) {
        log:printError("Next operation on the stream failed!:" + result.message());
        return error(result.message());
    } else {
        return error("Retreive failed");
    }
}

# GetDataItems - This method is used to get all items from the databae
# + return - Ruturn the added data item if passed, or return error if something failed.
public function GetDataItems() returns Data[]|error {

    log:printInfo("SQL GetDataItems Method Reached");

    sql:ParameterizedQuery GetDataItemsQuery = `SELECT * FROM Note`;
    stream<Data, error?> resultStream = mysqlClient->query(GetDataItemsQuery);

    // Process the stream and convert results to Data[] or return error.
    return from Data data in resultStream
        select data;
}

# AddDataItem - This method is used to add an item to the databae
#
# + entry - Entry Description of the data item
# + return - Ruturn the added data item if passed, or return error if something failed.  
public function AddDataItem(string entry) returns Data|error {

    log:printInfo("SQL AddDataItem Method Reached");

    sql:ParameterizedQuery InsertNewDataItemQuery = `INSERT INTO Note(Description) VALUES(${entry})`;

    sql:ExecutionResult|sql:Error queryResult = mysqlClient->execute(InsertNewDataItemQuery);

    if (queryResult is sql:ExecutionResult) {
        log:printInfo("Insert success");

        //Retrieve the inserted value
        return GetDataItemById(<int>queryResult.lastInsertId);

    } else {
        log:printError("Error occurred");
        return queryResult;
    }

}

// deleteDataItem - This method is used to delete an item from the databae
public function deleteDataItem(int id) returns error? {

    log:printInfo("SQL deleteDataItem Method Reached");

    sql:ParameterizedQuery DeleteDataItemQuery = `DELETE FROM Note WHERE Id = ${id}`;

    sql:ExecutionResult|sql:Error queryResult = mysqlClient->execute(DeleteDataItemQuery);

    if (queryResult is sql:ExecutionResult) {
        log:printInfo("Delete success");
        return;
    } else {
        log:printError("Error occurred");
        return queryResult;
    }

}

// updateDataItem - This method is used to update an item in the databae
public function updateDataItem(int id, string entry) returns Data|error {

    log:printInfo("SQL updateDataItem Method Reached");

    sql:ParameterizedQuery UpdateDataItemQuery = `UPDATE Note SET Description = ${entry} WHERE Id = ${id}`;

    sql:ExecutionResult|sql:Error queryResult = mysqlClient->execute(UpdateDataItemQuery);

    if (queryResult is sql:ExecutionResult) {
        log:printInfo("Update success");
        return GetDataItemById(id);
    } else {
        log:printError("Error occurred");
        return queryResult;
    }

}
