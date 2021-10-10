@testable import NBusCore
import XCTest

final class NBusTests: XCTestCase {

    func testExample() {
        XCTAssertEqual(Bus.shared.isDebugEnabled, true)
        XCTAssertEqual(Bus.shared.handlers.isEmpty, true)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
