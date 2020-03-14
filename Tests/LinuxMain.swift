import XCTest

import grpc_vaporTests

var tests = [XCTestCaseEntry]()
tests += grpc_vaporTests.allTests()
XCTMain(tests)
