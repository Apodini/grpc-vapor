//
//  UnaryCallHandkerTests.swift
//  grpc-vaporTests
//
//  Created by Michael Schlicker on 21.03.20.
//

import XCTest
@testable import GRPCVapor
@testable import Vapor

//class UnaryCallHandlerTests: XCTestCase {
//
//    struct ExampleInput: GRPCModel {}
//    struct ExampleOutput: GRPCModel {}
//
//    struct _ExampleInput: GRPCMessage {
//        typealias ModelType = ExampleInput
//
//        static var protoMessageName: String
//
//        var unknownFields: UnknownStorage
//
//        mutating func decodeMessage<D>(decoder: inout D) throws where D : Decoder {
//            <#code#>
//        }
//
//        func traverse<V>(visitor: inout V) throws where V : Visitor {
//            <#code#>
//        }
//
//        func isEqualTo(message: Message) -> Bool {
//            <#code#>
//        }
//
//
//    }
//
//    class ExampleService: GRPCService {
//        func exampleMethod(request: GRPCRequest<)
//    }
//
//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//        let application = Vapor.Application.init()
//        let xx = Vapor.Request.init(application: application, method: HTTPMethod.POST, url: "", on: application.eventLoopGroup.next())
//        xx.body = Vapor.Request.Body.
//
//    }
//
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//
//    func testExample() throws {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//
//}
