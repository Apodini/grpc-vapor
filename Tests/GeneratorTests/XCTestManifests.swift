import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(grpc_middleware_generatorTests.allTests),
    ]
}
#endif
