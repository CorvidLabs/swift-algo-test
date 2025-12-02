import Foundation
import XCTest

/// Assertions for account balance verification.
extension XCTestCase {
    /// Asserts that an account has sufficient balance.
    public func assertSufficientBalance(
        account: FundedAccount,
        required: UInt64,
        _ message: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertGreaterThanOrEqual(
            account.initialBalance,
            required,
            "Insufficient balance: account has \(account.initialBalance) but needs \(required). \(message)",
            file: file,
            line: line
        )
    }

    /// Asserts that a balance is within a specific range.
    public func assertBalanceInRange(
        _ balance: UInt64,
        min: UInt64,
        max: UInt64,
        _ message: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertGreaterThanOrEqual(
            balance,
            min,
            "Balance \(balance) is below minimum \(min). \(message)",
            file: file,
            line: line
        )

        XCTAssertLessThanOrEqual(
            balance,
            max,
            "Balance \(balance) exceeds maximum \(max). \(message)",
            file: file,
            line: line
        )
    }

    /// Asserts that a balance equals an expected value with tolerance.
    public func assertBalanceEquals(
        _ balance: UInt64,
        expected: UInt64,
        tolerance: UInt64 = 1_000,
        _ message: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let difference = balance > expected ? balance - expected : expected - balance

        XCTAssertLessThanOrEqual(
            difference,
            tolerance,
            "Balance \(balance) differs from expected \(expected) by more than tolerance \(tolerance). \(message)",
            file: file,
            line: line
        )
    }

    /// Asserts that an account can afford a transaction.
    public func assertCanAffordTransaction(
        account: FundedAccount,
        transaction: Transaction,
        _ message: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let totalCost = transaction.amount + transaction.fee
        assertSufficientBalance(
            account: account,
            required: totalCost,
            "Account cannot afford transaction (amount: \(transaction.amount), fee: \(transaction.fee)). \(message)",
            file: file,
            line: line
        )
    }
}
