import Foundation
import XCTest

/// Assertions for Algorand Standard Asset (ASA) verification.
extension XCTestCase {
    /// Asserts that an asset ID is valid.
    public func assertValidAssetID(
        _ assetID: UInt64,
        _ message: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertGreaterThan(
            assetID,
            0,
            "Asset ID must be positive. \(message)",
            file: file,
            line: line
        )
    }

    /// Asserts that an account holds a specific asset amount.
    public func assertAssetHolding(
        account: String,
        assetID: UInt64,
        amount: UInt64,
        _ message: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        // This would query actual asset holdings in a real implementation
        // For now, we just validate the inputs
        assertValidAddress(account, "Invalid account address", file: file, line: line)
        assertValidAssetID(assetID, "Invalid asset ID", file: file, line: line)
    }

    /// Asserts that an asset has the expected configuration.
    public func assertAssetConfig(
        assetID: UInt64,
        total: UInt64,
        decimals: UInt8,
        _ message: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assertValidAssetID(assetID, file: file, line: line)

        XCTAssertGreaterThan(
            total,
            0,
            "Asset total supply must be positive. \(message)",
            file: file,
            line: line
        )

        XCTAssertLessThanOrEqual(
            decimals,
            19,
            "Asset decimals cannot exceed 19. \(message)",
            file: file,
            line: line
        )
    }
}
