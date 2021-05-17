import AsyncHTTPClient
import AWSLambdaRuntime
import AWSLambdaEvents
import SotoTimestreamQuery
import Foundation

Lambda.run { context in
    return RequestHandler(eventLoop: context.eventLoop)
}

struct RequestHandler : LambdaHandler {
    
    enum OperationsError: Error {
        case missingTimestreamTableName
        case missingTimestreamDatabaseName
    }
    
    let awsClient: AWSClient
    let timestreamQuery: SotoTimestreamQuery.TimestreamQuery
    
    typealias In = String
    typealias Out = Void
    
    init(eventLoop: EventLoop) {
        awsClient = .init(credentialProvider: .selector(.environment, .configFile()), httpClientProvider: .createNew)
        
        // Either one below fails
        //timestreamQuery = .init(client: awsClient, region: Region.useast2, partition: .aws, endpoint: nil, timeout: nil, byteBufferAllocator: ByteBufferAllocator(), options: [])
        timestreamQuery = .init(client: awsClient)
    }
    
    func handle(context: Lambda.Context, event: String, callback: @escaping (Result<Void, Error>) -> Void) {
        guard let tableName = Lambda.env("TABLE_NAME") else {
            context.logger.error(.init(stringLiteral: "Timestream table name is not defined as env TABLE_NAME"))
            callback(.failure(OperationsError.missingTimestreamTableName))
            return
        }
        
        guard let databaseName = Lambda.env("DATABASE_NAME") else {
            context.logger.error(.init(stringLiteral: "Timestream database name is not defined as env DATABASE_NAME"))
            callback(.failure(OperationsError.missingTimestreamDatabaseName))
            return
        }
        
        do {
            let query: TimestreamQuery.QueryRequest = .init(queryString: "SELECT * FROM \"\(databaseName)\".\"\(tableName)\" WHERE time between ago(15m) and now() ORDER BY time DESC LIMIT 10")
            context.logger.info(.init(stringLiteral: "query: \(query)"))
            let response: TimestreamQuery.QueryResponse = try timestreamQuery.query(query, logger: context.logger, on: nil).wait()
            context.logger.info(.init(stringLiteral: "response: \(response)"))
        } catch {
            context.logger.error(.init(stringLiteral: "query error: \(error)"))
        }
        callback(.success({}()))
    }
    
    public func syncShutdown(context: AWSLambdaRuntimeCore.Lambda.ShutdownContext) throws {
        try? awsClient.syncShutdown()
    }
}
