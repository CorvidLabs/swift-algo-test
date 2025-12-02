import Foundation

/// Builder for creating test transactions with sensible defaults.
public struct TestTransactionBuilder: Sendable {
    private let sender: String
    private let receiver: String?
    private let amount: UInt64?
    private let note: Data?
    private let fee: UInt64
    private let firstValid: UInt64
    private let lastValid: UInt64
    private let genesisID: String
    private let genesisHash: Data

    /// Default transaction parameters for testing.
    public struct Defaults {
        public static let fee: UInt64 = 1_000
        public static let validRounds: UInt64 = 1_000
        public static let genesisID = "testnet-v1.0"
        public static let genesisHash = Data(repeating: 0, count: 32)
    }

    private init(
        sender: String,
        receiver: String?,
        amount: UInt64?,
        note: Data?,
        fee: UInt64,
        firstValid: UInt64,
        lastValid: UInt64,
        genesisID: String,
        genesisHash: Data
    ) {
        self.sender = sender
        self.receiver = receiver
        self.amount = amount
        self.note = note
        self.fee = fee
        self.firstValid = firstValid
        self.lastValid = lastValid
        self.genesisID = genesisID
        self.genesisHash = genesisHash
    }

    /// Creates a new builder with the sender account.
    public static func payment(from sender: FundedAccount) -> TestTransactionBuilder {
        TestTransactionBuilder(
            sender: sender.address,
            receiver: nil,
            amount: nil,
            note: nil,
            fee: Defaults.fee,
            firstValid: 1,
            lastValid: 1 + Defaults.validRounds,
            genesisID: Defaults.genesisID,
            genesisHash: Defaults.genesisHash
        )
    }

    /// Sets the receiver of the payment.
    public func to(_ receiver: FundedAccount) -> TestTransactionBuilder {
        to(receiver.address)
    }

    /// Sets the receiver address.
    public func to(_ address: String) -> TestTransactionBuilder {
        TestTransactionBuilder(
            sender: sender,
            receiver: address,
            amount: amount,
            note: note,
            fee: fee,
            firstValid: firstValid,
            lastValid: lastValid,
            genesisID: genesisID,
            genesisHash: genesisHash
        )
    }

    /// Sets the payment amount in microAlgos.
    public func amount(_ microAlgos: UInt64) -> TestTransactionBuilder {
        TestTransactionBuilder(
            sender: sender,
            receiver: receiver,
            amount: microAlgos,
            note: note,
            fee: fee,
            firstValid: firstValid,
            lastValid: lastValid,
            genesisID: genesisID,
            genesisHash: genesisHash
        )
    }

    /// Sets the transaction note.
    public func note(_ data: Data) -> TestTransactionBuilder {
        TestTransactionBuilder(
            sender: sender,
            receiver: receiver,
            amount: amount,
            note: data,
            fee: fee,
            firstValid: firstValid,
            lastValid: lastValid,
            genesisID: genesisID,
            genesisHash: genesisHash
        )
    }

    /// Sets the transaction note from a string.
    public func note(_ string: String) -> TestTransactionBuilder {
        note(Data(string.utf8))
    }

    /// Sets the transaction fee.
    public func fee(_ microAlgos: UInt64) -> TestTransactionBuilder {
        TestTransactionBuilder(
            sender: sender,
            receiver: receiver,
            amount: amount,
            note: note,
            fee: microAlgos,
            firstValid: firstValid,
            lastValid: lastValid,
            genesisID: genesisID,
            genesisHash: genesisHash
        )
    }

    /// Sets the valid round range.
    public func validRounds(first: UInt64, last: UInt64) -> TestTransactionBuilder {
        TestTransactionBuilder(
            sender: sender,
            receiver: receiver,
            amount: amount,
            note: note,
            fee: fee,
            firstValid: first,
            lastValid: last,
            genesisID: genesisID,
            genesisHash: genesisHash
        )
    }

    /// Builds the transaction.
    public func build() throws -> Transaction {
        guard let receiver else {
            throw AlgoTestError.transactionBuildFailed("Receiver not specified")
        }

        guard let amount else {
            throw AlgoTestError.transactionBuildFailed("Amount not specified")
        }

        return Transaction(
            sender: sender,
            receiver: receiver,
            amount: amount,
            note: note,
            fee: fee,
            firstValid: firstValid,
            lastValid: lastValid,
            genesisID: genesisID,
            genesisHash: genesisHash
        )
    }
}

/// Represents a test transaction.
public struct Transaction: Sendable, Equatable {
    public let sender: String
    public let receiver: String
    public let amount: UInt64
    public let note: Data?
    public let fee: UInt64
    public let firstValid: UInt64
    public let lastValid: UInt64
    public let genesisID: String
    public let genesisHash: Data
}
