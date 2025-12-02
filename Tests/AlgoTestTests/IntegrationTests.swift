import XCTest
@testable import AlgoTest

final class IntegrationTests: XCTestCase {
    func testEndToEndPaymentFlow() async throws {
        // Setup
        let client = MockAlgodClient()
        let factory = AccountFactory()

        // Create accounts
        let sender = try await factory.createAccount(fundedWith: 10_000_000)
        let receiver = try await factory.createAccount(fundedWith: 1_000_000)

        // Register with mock client
        await client.register(account: MockResponses.AccountInfo(
            address: sender.address,
            balance: sender.initialBalance
        ))

        await client.register(account: MockResponses.AccountInfo(
            address: receiver.address,
            balance: receiver.initialBalance
        ))

        // Create snapshot
        let capture = SnapshotCapture(client: client)
        let beforeSnapshot = try await capture.captureAll(label: "Before payment")

        // Build and submit transaction
        let transaction = try TestTransactionBuilder
            .payment(from: sender)
            .to(receiver)
            .amount(2_000_000)
            .note("Test payment")
            .build()

        let txID = try await client.submitTransaction(transaction)
        XCTAssertFalse(txID.isEmpty)

        // Capture after snapshot
        let afterSnapshot = try await capture.captureAll(label: "After payment")

        // Verify changes
        let diff = afterSnapshot.diff(from: beforeSnapshot)
        XCTAssertTrue(diff.hasChanges)

        let senderChange = diff.balanceChanges[sender.address]
        XCTAssertTrue(senderChange?.decreased ?? false)

        let receiverChange = diff.balanceChanges[receiver.address]
        XCTAssertTrue(receiverChange?.increased ?? false)
    }

    func testAccountPoolWithTransactions() async throws {
        let client = MockAlgodClient()
        let pool = AccountPool()

        try await pool.initialize()

        let result = try await pool.withAccount { sender in
            try await pool.withAccount { receiver in
                // Register accounts
                await client.register(account: MockResponses.AccountInfo(
                    address: sender.address,
                    balance: sender.initialBalance
                ))

                await client.register(account: MockResponses.AccountInfo(
                    address: receiver.address,
                    balance: receiver.initialBalance
                ))

                // Create transaction
                let transaction = try TestTransactionBuilder
                    .payment(from: sender)
                    .to(receiver)
                    .amount(1_000_000)
                    .build()

                return try await client.submitTransaction(transaction)
            }
        }

        XCTAssertFalse(result.isEmpty)

        // Verify pool released accounts
        let stats = await pool.statistics
        XCTAssertEqual(stats.inUse, 0)
    }

    func testBatchTransactionProcessing() async throws {
        let client = MockAlgodClient()
        let factory = AccountFactory()

        let sender = try await factory.createAccount(fundedWith: 100_000_000)
        let receivers = try await factory.createAccounts(count: 5)

        // Register all accounts
        await client.register(account: MockResponses.AccountInfo(
            address: sender.address,
            balance: sender.initialBalance
        ))

        for receiver in receivers {
            await client.register(account: MockResponses.AccountInfo(
                address: receiver.address,
                balance: receiver.initialBalance
            ))
        }

        // Create batch transactions
        let transactions = try TransactionScenarios.batchPayments(
            from: sender,
            to: receivers,
            amount: 1_000_000
        )

        // Submit all transactions
        var txIDs: [String] = []
        for transaction in transactions {
            let txID = try await client.submitTransaction(transaction)
            txIDs.append(txID)
        }

        XCTAssertEqual(txIDs.count, 5)

        // Verify sender balance decreased
        let senderInfo = try await client.accountInfo(for: sender.address)
        let expectedBalance: UInt64 = 100_000_000 - (5 * 1_000_000) - (5 * 1_000) // amount + fees
        XCTAssertEqual(senderInfo.balance, expectedBalance)
    }

    func testSnapshotComparison() async throws {
        let client = MockAlgodClient()
        let store = SnapshotStore()
        let capture = SnapshotCapture(client: client)

        let account = FundedAccount.mock(balance: 5_000_000)

        await client.register(account: MockResponses.AccountInfo(
            address: account.address,
            balance: account.initialBalance
        ))

        // Capture initial snapshot
        let snapshot1 = try await capture.capture(
            accounts: [account.address],
            label: "Initial"
        )
        await store.store(id: "initial", snapshot: snapshot1)

        // Advance rounds
        await client.advance(rounds: 10)

        // Capture second snapshot (same balance)
        let snapshot2 = try await capture.capture(
            accounts: [account.address],
            label: "After 10 rounds"
        )
        await store.store(id: "after", snapshot: snapshot2)

        // Compare
        let diff = try await store.compare(from: "initial", to: "after")
        XCTAssertFalse(diff.hasChanges)
    }
}
