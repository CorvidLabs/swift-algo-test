import Foundation
import XCTest

/// Extension to XCTestCase providing Algorand-specific assertion helpers.
extension XCTestCase {
    /// Asserts that an address is valid.
    public func assertValidAddress(
        _ address: String,
        _ message: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        // Algorand addresses are 58 characters
        XCTAssertEqual(
            address.count,
            58,
            "Invalid address length: \(message)",
            file: file,
            line: line
        )

        // Should only contain valid base32 characters
        let validChars = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567")
        let addressChars = CharacterSet(charactersIn: address)
        XCTAssertTrue(
            validChars.isSuperset(of: addressChars),
            "Address contains invalid characters: \(message)",
            file: file,
            line: line
        )
    }

    /// Asserts that a transaction is valid.
    public func assertValidTransaction(
        _ transaction: Transaction,
        _ message: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assertValidAddress(transaction.sender, "Invalid sender address", file: file, line: line)
        assertValidAddress(transaction.receiver, "Invalid receiver address", file: file, line: line)

        XCTAssertGreaterThan(
            transaction.fee,
            0,
            "Transaction fee must be positive: \(message)",
            file: file,
            line: line
        )

        XCTAssertLessThan(
            transaction.firstValid,
            transaction.lastValid,
            "First valid round must be before last valid round: \(message)",
            file: file,
            line: line
        )
    }

    /// Asserts that an async operation throws a specific error.
    public func assertThrowsError<T, E: Error & Equatable>(
        _ expression: @autoclosure () async throws -> T,
        expectedError: E,
        _ message: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        do {
            _ = try await expression()
            XCTFail("Expected error \(expectedError) but no error was thrown: \(message)", file: file, line: line)
        } catch let error as E {
            XCTAssertEqual(error, expectedError, message, file: file, line: line)
        } catch {
            XCTFail("Expected error \(expectedError) but got \(error): \(message)", file: file, line: line)
        }
    }

    /// Asserts that an async operation does not throw.
    public func assertNoThrow<T>(
        _ expression: @autoclosure () async throws -> T,
        _ message: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) async rethrows -> T? {
        do {
            return try await expression()
        } catch {
            XCTFail("Unexpected error: \(error) - \(message)", file: file, line: line)
            throw error
        }
    }
}
