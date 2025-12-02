import Foundation
import XCTest

/// Assertions for transaction verification.
extension XCTestCase {
    /// Asserts that a transaction has the expected sender and receiver.
    public func assertTransactionParties(
        _ transaction: Transaction,
        sender: FundedAccount,
        receiver: FundedAccount,
        _ message: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(
            transaction.sender,
            sender.address,
            "Transaction sender mismatch. \(message)",
            file: file,
            line: line
        )

        XCTAssertEqual(
            transaction.receiver,
            receiver.address,
            "Transaction receiver mismatch. \(message)",
            file: file,
            line: line
        )
    }

    /// Asserts that a transaction has the expected amount.
    public func assertTransactionAmount(
        _ transaction: Transaction,
        equals amount: UInt64,
        _ message: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(
            transaction.amount,
            amount,
            "Transaction amount mismatch. \(message)",
            file: file,
            line: line
        )
    }

    /// Asserts that a transaction has the expected note.
    public func assertTransactionNote(
        _ transaction: Transaction,
        equals note: String,
        _ message: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard let transactionNote = transaction.note else {
            XCTFail("Transaction has no note but expected '\(note)'. \(message)", file: file, line: line)
            return
        }

        let noteString = String(data: transactionNote, encoding: .utf8)
        XCTAssertEqual(
            noteString,
            note,
            "Transaction note mismatch. \(message)",
            file: file,
            line: line
        )
    }

    /// Asserts that a transaction fee is within acceptable range.
    public func assertTransactionFeeInRange(
        _ transaction: Transaction,
        min: UInt64 = 1_000,
        max: UInt64 = 100_000,
        _ message: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertGreaterThanOrEqual(
            transaction.fee,
            min,
            "Transaction fee \(transaction.fee) is below minimum \(min). \(message)",
            file: file,
            line: line
        )

        XCTAssertLessThanOrEqual(
            transaction.fee,
            max,
            "Transaction fee \(transaction.fee) exceeds maximum \(max). \(message)",
            file: file,
            line: line
        )
    }

    /// Asserts that transactions in a batch all have the same sender.
    public func assertBatchSameSender(
        _ transactions: [Transaction],
        _ message: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard let firstSender = transactions.first?.sender else {
            XCTFail("Empty transaction batch. \(message)", file: file, line: line)
            return
        }

        for (index, transaction) in transactions.enumerated() {
            XCTAssertEqual(
                transaction.sender,
                firstSender,
                "Transaction \(index) has different sender. \(message)",
                file: file,
                line: line
            )
        }
    }
}
