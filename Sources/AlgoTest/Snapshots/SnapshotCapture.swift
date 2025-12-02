import Foundation

/// Actor responsible for capturing state snapshots.
public actor SnapshotCapture {
    private let client: MockAlgodClient

    public init(client: MockAlgodClient) {
        self.client = client
    }

    /// Captures a snapshot of specific accounts.
    public func capture(
        accounts: [String],
        label: String? = nil,
        description: String? = nil
    ) async throws -> StateSnapshot {
        let round = await client.getCurrentRound()
        var accountStates: [String: StateSnapshot.AccountState] = [:]

        for address in accounts {
            let accountInfo = try await client.accountInfo(for: address)

            let assets = accountInfo.assets.reduce(into: [UInt64: UInt64]()) { result, holding in
                result[holding.assetID] = holding.amount
            }

            accountStates[address] = StateSnapshot.AccountState(
                address: address,
                balance: accountInfo.balance,
                assets: assets
            )
        }

        return StateSnapshot(
            round: round,
            accounts: accountStates,
            metadata: StateSnapshot.Metadata(
                label: label,
                description: description
            )
        )
    }

    /// Captures a snapshot of all registered accounts.
    public func captureAll(
        label: String? = nil
    ) async throws -> StateSnapshot {
        let registeredAccounts = await client.registeredAccounts
        let addresses = registeredAccounts.map { $0.address }

        return try await capture(
            accounts: addresses,
            label: label
        )
    }

    /// Captures snapshots before and after an operation.
    public func captureAround<T>(
        accounts: [String],
        operation: () async throws -> T
    ) async throws -> (before: StateSnapshot, after: StateSnapshot, result: T) {
        let before = try await capture(
            accounts: accounts,
            label: "Before operation"
        )

        let result = try await operation()

        let after = try await capture(
            accounts: accounts,
            label: "After operation"
        )

        return (before, after, result)
    }
}
