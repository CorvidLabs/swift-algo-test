import XCTest
@testable import AlgoTest

final class SnapshotTests: XCTestCase {
    func testStateSnapshotCreation() {
        let accountState = StateSnapshot.AccountState(
            address: "ADDR1",
            balance: 5_000_000
        )

        let snapshot = StateSnapshot(
            round: 1000,
            accounts: ["ADDR1": accountState]
        )

        XCTAssertEqual(snapshot.round, 1000)
        XCTAssertEqual(snapshot.accounts.count, 1)
    }

    func testStateSnapshotDiff() {
        let state1 = StateSnapshot.AccountState(
            address: "ADDR1",
            balance: 5_000_000
        )

        let state2 = StateSnapshot.AccountState(
            address: "ADDR1",
            balance: 7_000_000
        )

        let snapshot1 = StateSnapshot(
            round: 1000,
            accounts: ["ADDR1": state1]
        )

        let snapshot2 = StateSnapshot(
            round: 1005,
            accounts: ["ADDR1": state2]
        )

        let diff = snapshot2.diff(from: snapshot1)

        XCTAssertEqual(diff.fromRound, 1000)
        XCTAssertEqual(diff.toRound, 1005)
        XCTAssertTrue(diff.hasChanges)

        let change = diff.balanceChanges["ADDR1"]
        XCTAssertEqual(change?.previous, 5_000_000)
        XCTAssertEqual(change?.current, 7_000_000)
        XCTAssertEqual(change?.delta, 2_000_000)
        XCTAssertTrue(change?.increased ?? false)
    }

    func testSnapshotDiffNoChanges() {
        let state = StateSnapshot.AccountState(
            address: "ADDR1",
            balance: 5_000_000
        )

        let snapshot1 = StateSnapshot(
            round: 1000,
            accounts: ["ADDR1": state]
        )

        let snapshot2 = StateSnapshot(
            round: 1005,
            accounts: ["ADDR1": state]
        )

        let diff = snapshot2.diff(from: snapshot1)
        XCTAssertFalse(diff.hasChanges)
    }

    func testSnapshotCaptureAccounts() async throws {
        let client = MockAlgodClient()

        await client.register(account: MockResponses.AccountInfo(
            address: "ADDR1",
            balance: 10_000_000
        ))

        let capture = SnapshotCapture(client: client)

        let snapshot = try await capture.capture(
            accounts: ["ADDR1"],
            label: "Test snapshot"
        )

        XCTAssertEqual(snapshot.accounts.count, 1)
        XCTAssertEqual(snapshot.accounts["ADDR1"]?.balance, 10_000_000)
        XCTAssertEqual(snapshot.metadata.label, "Test snapshot")
    }

    func testSnapshotCaptureAll() async throws {
        let client = MockAlgodClient()

        await client.register(account: MockResponses.AccountInfo(
            address: "ADDR1",
            balance: 5_000_000
        ))

        await client.register(account: MockResponses.AccountInfo(
            address: "ADDR2",
            balance: 7_000_000
        ))

        let capture = SnapshotCapture(client: client)
        let snapshot = try await capture.captureAll(label: "All accounts")

        XCTAssertEqual(snapshot.accounts.count, 2)
    }

    func testSnapshotCaptureAround() async throws {
        let client = MockAlgodClient()

        let sender = FundedAccount.mock(balance: 10_000_000)
        let receiver = FundedAccount.mock(balance: 1_000_000)

        await client.register(account: MockResponses.AccountInfo(
            address: sender.address,
            balance: sender.initialBalance
        ))

        await client.register(account: MockResponses.AccountInfo(
            address: receiver.address,
            balance: receiver.initialBalance
        ))

        let capture = SnapshotCapture(client: client)

        let result = try await capture.captureAround(
            accounts: [sender.address, receiver.address]
        ) {
            let tx = try TestTransactionBuilder
                .payment(from: sender)
                .to(receiver)
                .amount(1_000_000)
                .build()

            return try await client.submitTransaction(tx)
        }

        XCTAssertNotNil(result.before)
        XCTAssertNotNil(result.after)
        XCTAssertFalse(result.result.isEmpty)

        let diff = result.after.diff(from: result.before)
        XCTAssertTrue(diff.hasChanges)
    }

    func testSnapshotStoreAndRetrieve() async throws {
        let store = SnapshotStore()

        let snapshot = StateSnapshot(
            round: 1000,
            accounts: [:]
        )

        await store.store(id: "snapshot1", snapshot: snapshot)

        let retrieved = try await store.retrieve(id: "snapshot1")
        XCTAssertEqual(retrieved.round, 1000)
    }

    func testSnapshotStoreNotFound() async {
        let store = SnapshotStore()

        do {
            _ = try await store.retrieve(id: "nonexistent")
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is AlgoTestError)
        }
    }

    func testSnapshotStoreCompare() async throws {
        let store = SnapshotStore()

        let state1 = StateSnapshot.AccountState(
            address: "ADDR1",
            balance: 5_000_000
        )

        let state2 = StateSnapshot.AccountState(
            address: "ADDR1",
            balance: 7_000_000
        )

        let snapshot1 = StateSnapshot(
            round: 1000,
            accounts: ["ADDR1": state1]
        )

        let snapshot2 = StateSnapshot(
            round: 1005,
            accounts: ["ADDR1": state2]
        )

        await store.store(id: "s1", snapshot: snapshot1)
        await store.store(id: "s2", snapshot: snapshot2)

        let diff = try await store.compare(from: "s1", to: "s2")
        XCTAssertEqual(diff.fromRound, 1000)
        XCTAssertEqual(diff.toRound, 1005)
    }

    func testSnapshotStoreCount() async {
        let store = SnapshotStore()

        let snapshot = StateSnapshot(round: 1000, accounts: [:])

        await store.store(id: "s1", snapshot: snapshot)
        await store.store(id: "s2", snapshot: snapshot)

        let count = await store.count
        XCTAssertEqual(count, 2)
    }

    func testSnapshotStoreClear() async {
        let store = SnapshotStore()

        let snapshot = StateSnapshot(round: 1000, accounts: [:])
        await store.store(id: "s1", snapshot: snapshot)

        await store.clear()

        let count = await store.count
        XCTAssertEqual(count, 0)
    }

    func testSnapshotStoreRemove() async throws {
        let store = SnapshotStore()

        let snapshot = StateSnapshot(round: 1000, accounts: [:])
        await store.store(id: "s1", snapshot: snapshot)
        await store.store(id: "s2", snapshot: snapshot)

        await store.remove(id: "s1")

        let count = await store.count
        XCTAssertEqual(count, 1)

        do {
            _ = try await store.retrieve(id: "s1")
            XCTFail("Expected error")
        } catch {
            // Expected
        }
    }
}
