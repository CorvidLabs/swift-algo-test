import Foundation

/// Represents a test account with balance tracking capabilities.
public struct FundedAccount: Sendable, Equatable {
    /// The account's public address.
    public let address: String

    /// The account's private key for signing transactions.
    public let privateKey: Data

    /// The initial funding amount in microAlgos.
    public let initialBalance: UInt64

    /// Metadata about the account.
    public let metadata: Metadata

    public struct Metadata: Sendable, Equatable {
        public let createdAt: Date
        public let purpose: String?
        public let tags: Set<String>

        public init(
            createdAt: Date = Date(),
            purpose: String? = nil,
            tags: Set<String> = []
        ) {
            self.createdAt = createdAt
            self.purpose = purpose
            self.tags = tags
        }
    }

    public init(
        address: String,
        privateKey: Data,
        initialBalance: UInt64,
        metadata: Metadata = Metadata()
    ) {
        self.address = address
        self.privateKey = privateKey
        self.initialBalance = initialBalance
        self.metadata = metadata
    }
}

extension FundedAccount {
    /// Creates a test account with a mock address and key.
    public static func mock(
        balance: UInt64 = 1_000_000,
        purpose: String? = nil
    ) -> FundedAccount {
        // Generate a valid 58-character Algorand address format
        let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
        let mockAddress = String((0..<58).map { _ in chars.randomElement()! })

        return FundedAccount(
            address: mockAddress,
            privateKey: Data(repeating: 0, count: 32),
            initialBalance: balance,
            metadata: Metadata(purpose: purpose)
        )
    }

    /// Returns a copy of the account with additional tags.
    public func tagged(_ tags: String...) -> FundedAccount {
        FundedAccount(
            address: address,
            privateKey: privateKey,
            initialBalance: initialBalance,
            metadata: Metadata(
                createdAt: metadata.createdAt,
                purpose: metadata.purpose,
                tags: metadata.tags.union(tags)
            )
        )
    }
}
