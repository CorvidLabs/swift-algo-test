import XCTest
@testable import AlgoTest

final class MockingTests: XCTestCase {
    func testMockAccountInfoCreation() {
        let accountInfo = MockResponses.AccountInfo(
            address: "TEST123",
            balance: 5_000_000
        )

        XCTAssertEqual(accountInfo.address, "TEST123")
        XCTAssertEqual(accountInfo.balance, 5_000_000)
    }

    func testMockTransactionResponse() {
        let response = MockResponses.TransactionResponse.confirmed(round: 1000)
        XCTAssertEqual(response.confirmedRound, 1000)
    }

    func testMockAlgodClientRegisterAccount() async throws {
        let client = MockAlgodClient()
        let accountInfo = MockResponses.AccountInfo(
            address: "ADDR1",
            balance: 10_000_000
        )

        await client.register(account: accountInfo)

        let retrieved = try await client.accountInfo(for: "ADDR1")
        XCTAssertEqual(retrieved.balance, 10_000_000)
    }

    func testMockAlgodClientAccountNotFound() async throws {
        let client = MockAlgodClient()

        do {
            _ = try await client.accountInfo(for: "NOTFOUND")
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is AlgoTestError)
        }
    }

    func testMockAlgodClientSubmitTransaction() async throws {
        let client = MockAlgodClient()

        let sender = FundedAccount.mock(balance: 10_000_000)
        let receiver = FundedAccount.mock()

        await client.register(account: MockResponses.AccountInfo(
            address: sender.address,
            balance: sender.initialBalance
        ))

        await client.register(account: MockResponses.AccountInfo(
            address: receiver.address,
            balance: receiver.initialBalance
        ))

        let transaction = try TestTransactionBuilder
            .payment(from: sender)
            .to(receiver)
            .amount(1_000_000)
            .build()

        let txID = try await client.submitTransaction(transaction)
        XCTAssertFalse(txID.isEmpty)

        // Verify balances updated
        let updatedSender = try await client.accountInfo(for: sender.address)
        XCTAssertEqual(updatedSender.balance, 9_000_000 - 1_000) // amount + fee
    }

    func testMockAlgodClientInsufficientBalance() async throws {
        let client = MockAlgodClient()

        let sender = FundedAccount.mock(balance: 500_000)
        let receiver = FundedAccount.mock()

        await client.register(account: MockResponses.AccountInfo(
            address: sender.address,
            balance: sender.initialBalance
        ))

        let transaction = try TestTransactionBuilder
            .payment(from: sender)
            .to(receiver)
            .amount(1_000_000)
            .build()

        do {
            _ = try await client.submitTransaction(transaction)
            XCTFail("Expected insufficient balance error")
        } catch let error as AlgoTestError {
            if case .insufficientBalance = error {
                // Expected
            } else {
                XCTFail("Wrong error type")
            }
        }
    }

    func testMockAlgodClientAdvanceRounds() async {
        let client = MockAlgodClient(initialRound: 1000)

        var round = await client.getCurrentRound()
        XCTAssertEqual(round, 1000)

        await client.advance(rounds: 5)

        round = await client.getCurrentRound()
        XCTAssertEqual(round, 1005)
    }

    func testMockAlgodClientReset() async throws {
        let client = MockAlgodClient()

        await client.register(account: MockResponses.AccountInfo(
            address: "TEST",
            balance: 1_000_000
        ))

        var accounts = await client.registeredAccounts
        XCTAssertEqual(accounts.count, 1)

        await client.reset()

        accounts = await client.registeredAccounts
        XCTAssertEqual(accounts.count, 0)
    }

    func testMockIndexerRegisterTransaction() async throws {
        let indexer = MockIndexerClient()

        let sender = FundedAccount.mock()
        let receiver = FundedAccount.mock()

        let transaction = try TestTransactionBuilder
            .payment(from: sender)
            .to(receiver)
            .amount(1_000_000)
            .build()

        await indexer.register(transactionID: "TX123", transaction: transaction)

        let retrieved = try await indexer.transaction(id: "TX123")
        XCTAssertEqual(retrieved.amount, 1_000_000)
    }

    func testMockIndexerAccountTransactions() async throws {
        let indexer = MockIndexerClient()

        let sender = FundedAccount.mock()
        let receiver = FundedAccount.mock()

        let tx1 = try TestTransactionBuilder
            .payment(from: sender)
            .to(receiver)
            .amount(1_000_000)
            .build()

        let tx2 = try TestTransactionBuilder
            .payment(from: sender)
            .to(receiver)
            .amount(500_000)
            .build()

        await indexer.register(transactionID: "TX1", transaction: tx1)
        await indexer.register(transactionID: "TX2", transaction: tx2)

        let transactions = await indexer.transactions(for: sender.address)
        XCTAssertEqual(transactions.count, 2)
    }

    func testMockIndexerTransactionCount() async throws {
        let indexer = MockIndexerClient()

        let account = FundedAccount.mock()
        let receiver = FundedAccount.mock()

        for i in 0..<5 {
            let tx = try TestTransactionBuilder
                .payment(from: account)
                .to(receiver)
                .amount(1_000_000)
                .build()

            await indexer.register(transactionID: "TX\(i)", transaction: tx)
        }

        let count = await indexer.transactionCount(for: account.address)
        XCTAssertEqual(count, 5)
    }
}
