import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(grpc_vaporTests.allTests),
        testCase(GRPCServiceNameTest.allTests)
    ]
}
#endif
