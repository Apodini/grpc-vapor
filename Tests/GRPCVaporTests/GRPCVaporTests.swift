import XCTest
@testable import GRPCVapor

final class GRPCVaporTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let xx = FileManager.default.currentDirectoryPath
        print(xx)
//        let d = try? Data(contentsOf: URL(fileURLWithPath: xx))
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
