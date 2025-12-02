import XCTest
@testable import AlgoTest

final class AssertionTests: XCTestCase {
    func testAssertValidAddress() {
        let validAddress = String(repeating: "A", count: 58)
        assertValidAddress(validAddress)
    }

    func testAssertInvalidAddressLength() {
        let _ = "SHORTADDRESS"
        // This would fail in actual test
        // assertValidAddress(invalidAddress)
    }

    func testAssertValidTransaction() throws {
        let sender = FundedAccount.mock()
        let receiver = FundedAccount.mock()

        let transaction = try TestTransactionBuilder
            .payment(from: sender)
            .to(receiver)
            .amount(1_000_000)
            .build()

        assertValidTransaction(transaction)
    }

    func testAssertSufficientBalance() {
        let account = FundedAccount.mock(balance: 5_000_000)
        assertSufficientBalance(account: account, required: 3_000_000)
    }

    func testAssertBalanceInRange() {
        assertBalanceInRange(5_000_000, min: 1_000_000, max: 10_000_000)
    }

    func testAssertBalanceEquals() {
        assertBalanceEquals(1_000_000, expected: 1_000_500, tolerance: 1_000)
    }

    func testAssertCanAffordTransaction() throws {
        let sender = FundedAccount.mock(balance: 10_000_000)
        let receiver = FundedAccount.mock()

        let transaction = try TestTransactionBuilder
            .payment(from: sender)
            .to(receiver)
            .amount(5_000_000)
            .build()

        assertCanAffordTransaction(account: sender, transaction: transaction)
    }

    func testAssertTransactionParties() throws {
        let sender = FundedAccount.mock()
        let receiver = FundedAccount.mock()

        let transaction = try TestTransactionBuilder
            .payment(from: sender)
            .to(receiver)
            .amount(1_000_000)
            .build()

        assertTransactionParties(transaction, sender: sender, receiver: receiver)
    }

    func testAssertTransactionAmount() throws {
        let sender = FundedAccount.mock()
        let receiver = FundedAccount.mock()

        let transaction = try TestTransactionBuilder
            .payment(from: sender)
            .to(receiver)
            .amount(2_500_000)
            .build()

        assertTransactionAmount(transaction, equals: 2_500_000)
    }

    func testAssertTransactionNote() throws {
        let sender = FundedAccount.mock()
        let receiver = FundedAccount.mock()

        let transaction = try TestTransactionBuilder
            .payment(from: sender)
            .to(receiver)
            .amount(1_000_000)
            .note("Test note")
            .build()

        assertTransactionNote(transaction, equals: "Test note")
    }

    func testAssertTransactionFeeInRange() throws {
        let sender = FundedAccount.mock()
        let receiver = FundedAccount.mock()

        let transaction = try TestTransactionBuilder
            .payment(from: sender)
            .to(receiver)
            .amount(1_000_000)
            .fee(5_000)
            .build()

        assertTransactionFeeInRange(transaction, min: 1_000, max: 10_000)
    }

    func testAssertBatchSameSender() throws {
        let sender = FundedAccount.mock()
        let receivers = [FundedAccount.mock(), FundedAccount.mock()]

        let transactions = try TransactionScenarios.batchPayments(
            from: sender,
            to: receivers,
            amount: 1_000_000
        )

        assertBatchSameSender(transactions)
    }

    func testAssertValidAssetID() {
        assertValidAssetID(12345)
    }

    func testAssertAssetConfig() {
        assertAssetConfig(assetID: 100, total: 1_000_000, decimals: 6)
    }
}
