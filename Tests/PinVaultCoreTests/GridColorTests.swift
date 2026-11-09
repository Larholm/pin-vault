import XCTest
@testable import PinVaultCore

final class GridColorTests: XCTestCase {
    func testFourColoursWithAndroidRawValues() {
        XCTAssertEqual(GridColor.allCases.map(\.rawValue), ["RED", "BLUE", "GREEN", "YELLOW"])
    }
}
