import XCTest
@testable import AlgoTest

final class TransactionTests: XCTestCase {
    func testTransactionBuilderBasic() throws {
        let sender = FundedAccount.mock()
        let receiver = FundedAccount.mock()

        let transaction = try TestTransactionBuilder
            .payment(from: sender)
            .to(receiver)
            .amount(1_000_000)
            .build()

        XCTAssertEqual(transaction.sender, sender.address)
        XCTAssertEqual(transaction.receiver, receiver.address)
        XCTAssertEqual(transaction.amount, 1_000_000)
    }

    func testTransactionBuilderWithNote() throws {
        let sender = FundedAccount.mock()
        let receiver = FundedAccount.mock()

        let transaction = try TestTransactionBuilder
            .payment(from: sender)
            .to(receiver)
            .amount(500_000)
            .note("Test payment")
            .build()

        let noteString = transaction.note.flatMap { String(data: $0, encoding: .utf8) }
        XCTAssertEqual(noteString, "Test payment")
    }

    func testTransactionBuilderWithCustomFee() throws {
        let sender = FundedAccount.mock()
        let receiver = FundedAccount.mock()

        let transaction = try TestTransactionBuilder
            .payment(from: sender)
            .to(receiver)
            .amount(1_000_000)
            .fee(5_000)
            .build()

        XCTAssertEqual(transaction.fee, 5_000)
    }

    func testTransactionBuilderMissingReceiver() {
        let sender = FundedAccount.mock()

        XCTAssertThrowsError(
            try TestTransactionBuilder
                .payment(from: sender)
                .amount(1_000_000)
                .build()
        )
    }

    func testTransactionBuilderMissingAmount() {
        let sender = FundedAccount.mock()
        let receiver = FundedAccount.mock()

        XCTAssertThrowsError(
            try TestTransactionBuilder
                .payment(from: sender)
                .to(receiver)
                .build()
        )
    }

    func testSimplePaymentScenario() throws {
        let sender = FundedAccount.mock()
        let receiver = FundedAccount.mock()

        let transaction = try TransactionScenarios.simplePayment(
            from: sender,
            to: receiver
        )

        XCTAssertEqual(transaction.amount, 1_000_000)
    }

    func testPaymentWithNoteScenario() throws {
        let sender = FundedAccount.mock()
        let receiver = FundedAccount.mock()

        let transaction = try TransactionScenarios.paymentWithNote(
            from: sender,
            to: receiver,
            amount: 2_000_000,
            note: "Payment for services"
        )

        let noteString = transaction.note.flatMap { String(data: $0, encoding: .utf8) }
        XCTAssertEqual(noteString, "Payment for services")
    }

    func testMinimumPaymentScenario() throws {
        let sender = FundedAccount.mock()
        let receiver = FundedAccount.mock()

        let transaction = try TransactionScenarios.minimumPayment(
            from: sender,
            to: receiver
        )

        XCTAssertEqual(transaction.amount, 100_000)
    }

    func testLargePaymentScenario() throws {
        let sender = FundedAccount.mock()
        let receiver = FundedAccount.mock()

        let transaction = try TransactionScenarios.largePayment(
            from: sender,
            to: receiver
        )

        XCTAssertEqual(transaction.amount, 100_000_000_000)
    }

    func testBatchPaymentsScenario() throws {
        let sender = FundedAccount.mock()
        let receivers = [
            FundedAccount.mock(),
            FundedAccount.mock(),
            FundedAccount.mock()
        ]

        let transactions = try TransactionScenarios.batchPayments(
            from: sender,
            to: receivers,
            amount: 500_000
        )

        XCTAssertEqual(transactions.count, 3)
        for transaction in transactions {
            XCTAssertEqual(transaction.sender, sender.address)
            XCTAssertEqual(transaction.amount, 500_000)
        }
    }

    func testCircularPaymentsScenario() throws {
        let accounts = [
            FundedAccount.mock(),
            FundedAccount.mock(),
            FundedAccount.mock()
        ]

        let transactions = try TransactionScenarios.circularPayments(
            accounts: accounts,
            amount: 250_000
        )

        XCTAssertEqual(transactions.count, 3)
        XCTAssertEqual(transactions[0].sender, accounts[0].address)
        XCTAssertEqual(transactions[0].receiver, accounts[1].address)
        XCTAssertEqual(transactions[2].receiver, accounts[0].address)
    }
}
