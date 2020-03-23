//
//  GRPCServiceNameTest.swift
//  grpc-vaporTests
//
//  Created by Michael Schlicker on 21.03.20.
//

import XCTest
@testable import GRPCVapor

class GRPCServiceNameTests: XCTestCase {

    func testSimpleServiceName() throws {
        class ExampleService: GRPCService { }
        let service = ExampleService()
        let serviceName = service.serviceName
        let expectedServiceName = "ExampleService"
        XCTAssert(serviceName == expectedServiceName)
    }

    func testNestedServiceName() throws {
        class SomeClass {
            class AnotherClass {
                class ExampleService: GRPCService {}
            }
        }
        let service = SomeClass.AnotherClass.ExampleService()
        let serviceName = service.serviceName
        let expectedServiceName = "ExampleService"
        XCTAssert(serviceName == expectedServiceName)
    }

    static var allTests = [
        ("testSimpleServiceName", testSimpleServiceName),
    ]

}
