import Foundation

/// Represents a snapshot of blockchain state at a specific point in time.
public struct StateSnapshot: Sendable, Equatable {
    public let timestamp: Date
    public let round: UInt64
    public let accounts: [String: AccountState]
    public let metadata: Metadata

    public struct AccountState: Sendable, Equatable {
        public let address: String
        public let balance: UInt64
        public let assets: [UInt64: UInt64] // assetID -> amount

        public init(
            address: String,
            balance: UInt64,
            assets: [UInt64: UInt64] = [:]
        ) {
            self.address = address
            self.balance = balance
            self.assets = assets
        }
    }

    public struct Metadata: Sendable, Equatable {
        public let label: String?
        public let description: String?
        public let tags: Set<String>

        public init(
            label: String? = nil,
            description: String? = nil,
            tags: Set<String> = []
        ) {
            self.label = label
            self.description = description
            self.tags = tags
        }
    }

    public init(
        timestamp: Date = Date(),
        round: UInt64,
        accounts: [String: AccountState],
        metadata: Metadata = Metadata()
    ) {
        self.timestamp = timestamp
        self.round = round
        self.accounts = accounts
        self.metadata = metadata
    }
}

extension StateSnapshot {
    /// Compares two snapshots and returns the differences.
    public func diff(from other: StateSnapshot) -> SnapshotDiff {
        var balanceChanges: [String: SnapshotDiff.BalanceChange] = [:]

        let allAddresses = Set(accounts.keys).union(other.accounts.keys)

        for address in allAddresses {
            let currentBalance = accounts[address]?.balance ?? 0
            let previousBalance = other.accounts[address]?.balance ?? 0

            if currentBalance != previousBalance {
                balanceChanges[address] = SnapshotDiff.BalanceChange(
                    previous: previousBalance,
                    current: currentBalance,
                    delta: Int64(currentBalance) - Int64(previousBalance)
                )
            }
        }

        return SnapshotDiff(
            fromRound: other.round,
            toRound: round,
            balanceChanges: balanceChanges
        )
    }

    /// Gets the account state for a specific address.
    public func accountState(for address: String) -> AccountState? {
        accounts[address]
    }
}

/// Represents the difference between two snapshots.
public struct SnapshotDiff: Sendable, Equatable {
    public let fromRound: UInt64
    public let toRound: UInt64
    public let balanceChanges: [String: BalanceChange]

    public struct BalanceChange: Sendable, Equatable {
        public let previous: UInt64
        public let current: UInt64
        public let delta: Int64

        public var increased: Bool { delta > 0 }
        public var decreased: Bool { delta < 0 }
        public var unchanged: Bool { delta == 0 }
    }

    public var hasChanges: Bool {
        !balanceChanges.isEmpty
    }
}
