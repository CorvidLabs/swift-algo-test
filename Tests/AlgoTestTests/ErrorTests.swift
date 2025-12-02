import XCTest
@testable import AlgoTest

final class ErrorTests: XCTestCase {
    func testAlgoTestErrorEquality() {
        let error1 = AlgoTestError.sandboxNotRunning
        let error2 = AlgoTestError.sandboxNotRunning

        XCTAssertEqual(error1, error2)
    }

    func testAlgoTestErrorInsufficientBalance() {
        let error = AlgoTestError.insufficientBalance(
            required: 1_000_000,
            available: 500_000
        )

        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription!.contains("1000000"))
        XCTAssertTrue(error.errorDescription!.contains("500000"))
    }

    func testAlgoTestErrorFundingFailed() {
        let error = AlgoTestError.fundingFailed(
            amount: 5_000_000,
            reason: "Network timeout"
        )

        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription!.contains("Network timeout"))
    }

    func testAlgoTestErrorAssertionFailed() {
        let error = AlgoTestError.assertionFailed("Balance mismatch")

        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription!.contains("Balance mismatch"))
    }

    func testAlgoTestErrorSnapshotComparison() {
        let error = AlgoTestError.snapshotComparisonFailed(
            expected: "snapshot1",
            actual: "snapshot2"
        )

        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription!.contains("snapshot1"))
        XCTAssertTrue(error.errorDescription!.contains("snapshot2"))
    }

    func testAlgoTestErrorMockConfiguration() {
        let error = AlgoTestError.mockConfigurationError("Invalid setup")

        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription!.contains("Invalid setup"))
    }

    func testAlgoTestErrorInvalidState() {
        let error = AlgoTestError.invalidState("Cannot transition")

        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription!.contains("Cannot transition"))
    }
}
