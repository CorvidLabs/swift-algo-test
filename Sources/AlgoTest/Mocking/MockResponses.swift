import Foundation

/// Mock response types for testing.
public enum MockResponses {
    /// Represents a mock account information response.
    public struct AccountInfo: Sendable, Equatable {
        public let address: String
        public let balance: UInt64
        public let round: UInt64
        public let assets: [AssetHolding]

        public init(
            address: String,
            balance: UInt64,
            round: UInt64 = 1_000,
            assets: [AssetHolding] = []
        ) {
            self.address = address
            self.balance = balance
            self.round = round
            self.assets = assets
        }
    }

    /// Represents a mock asset holding.
    public struct AssetHolding: Sendable, Equatable {
        public let assetID: UInt64
        public let amount: UInt64

        public init(assetID: UInt64, amount: UInt64) {
            self.assetID = assetID
            self.amount = amount
        }
    }

    /// Represents a mock transaction response.
    public struct TransactionResponse: Sendable, Equatable {
        public let txID: String
        public let confirmedRound: UInt64?

        public init(txID: String, confirmedRound: UInt64? = nil) {
            self.txID = txID
            self.confirmedRound = confirmedRound
        }

        public static func confirmed(round: UInt64) -> TransactionResponse {
            TransactionResponse(
                txID: UUID().uuidString,
                confirmedRound: round
            )
        }

        public static var pending: TransactionResponse {
            TransactionResponse(txID: UUID().uuidString)
        }
    }

    /// Represents a mock block response.
    public struct Block: Sendable, Equatable {
        public let round: UInt64
        public let timestamp: Date
        public let transactionCount: Int

        public init(
            round: UInt64,
            timestamp: Date = Date(),
            transactionCount: Int = 0
        ) {
            self.round = round
            self.timestamp = timestamp
            self.transactionCount = transactionCount
        }
    }

    /// Represents mock node status.
    public struct NodeStatus: Sendable, Equatable {
        public let lastRound: UInt64
        public let timeSinceLastRound: TimeInterval

        public init(
            lastRound: UInt64 = 1_000,
            timeSinceLastRound: TimeInterval = 4.5
        ) {
            self.lastRound = lastRound
            self.timeSinceLastRound = timeSinceLastRound
        }
    }
}
