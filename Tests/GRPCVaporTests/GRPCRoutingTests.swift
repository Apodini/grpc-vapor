//
//  GRPCRoutingTests.swift
//  grpc-vaporTests
//
//  Created by Michael Schlicker on 21.03.20.
//

import XCTVapor
@testable import GRPCVapor
@testable import Vapor


class GRPCRoutingTests: XCTestCase {

    var middleware: GRPCMiddleware = GRPCMiddleware(services: [
        ExampleService(),
        StructService(),
        EmptyService(),
        SomeClass.NestedService()
    ])

    struct ExampleInput: GRPCModel { }

    struct ExampleOutput: GRPCModel { }



    class ExampleService: GRPCService {

    }

    struct StructService: GRPCService {
        func handleMethod(methodName: String, vaporRequest: Request) -> AnyCallHandler? {
            return nil
        }
    }

    class EmptyService: GRPCService { }

    class SomeClass {
        class NestedService: GRPCService {

        }
    }

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddingService() throws {
        class AdditionalService: GRPCService {

        }
    }

//    func testExample() throws {
//        let app = Application(.testing)
//        defer { app.shutdown() }
//        app.middleware.use(middleware)
//
//
//        let request = Request(application: app, method: .POST, url: URI(string: "/ExampleService/ExampleMethod/"), on: app.eventLoopGroup.next())
//
//
//        app.te
//
//        let exampleUnaryCall = UnaryCallHandler<ExampleInput, ExampleOutput>(vaporRequest: request) { req in
//            return req.eventLoop.makeSucceededFuture(ExampleOutput())
//        }
//
//        extension ExampleService {
//            func handleMethod(methodName: String, vaporRequest: Request) -> AnyCallHandler? {
//                switch methodName {
//                case "ExampleMethod":
//                    return try? exampleUnaryCall
//                default:
//                    return nil
//                }
//            }
//        }
//    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
