import Foundation

/// Mock implementation of an Indexer client for unit testing.
public actor MockIndexerClient {
    private var transactions: [String: Transaction]
    private var accountTransactions: [String: [String]]
    private var blocks: [UInt64: MockResponses.Block]

    public init() {
        self.transactions = [:]
        self.accountTransactions = [:]
        self.blocks = [:]
    }

    // MARK: - Configuration

    /**
     Registers a transaction for indexing.

     - Parameters:
       - transactionID: The transaction identifier.
       - transaction: The transaction to register.
     */
    public func register(transactionID: String, transaction: Transaction) {
        transactions[transactionID] = transaction

        // Add to sender's transactions
        var senderTxns = accountTransactions[transaction.sender] ?? []
        senderTxns.append(transactionID)
        accountTransactions[transaction.sender] = senderTxns

        // Add to receiver's transactions
        var receiverTxns = accountTransactions[transaction.receiver] ?? []
        receiverTxns.append(transactionID)
        accountTransactions[transaction.receiver] = receiverTxns
    }

    /**
     Registers a block.

     - Parameter block: The block to register.
     */
    public func register(block: MockResponses.Block) {
        blocks[block.round] = block
    }

    // MARK: - Query Operations

    /**
     Searches for transactions by account.

     - Parameters:
       - address: The account address to search.
       - limit: Maximum number of transactions to return (default: 100).
     - Returns: Array of transactions for the account.
     */
    public func transactions(
        for address: String,
        limit: Int = 100
    ) -> [Transaction] {
        guard let txnIDs = accountTransactions[address] else {
            return []
        }

        return txnIDs.prefix(limit).compactMap { transactions[$0] }
    }

    /**
     Gets a specific transaction.

     - Parameter id: The transaction identifier.
     - Returns: The transaction.
     - Throws: `AlgoTestError.mockConfigurationError` if transaction not found.
     */
    public func transaction(id: String) throws -> Transaction {
        guard let transaction = transactions[id] else {
            throw AlgoTestError.mockConfigurationError("Transaction \(id) not found")
        }
        return transaction
    }

    /**
     Gets a specific block.

     - Parameter round: The block round number.
     - Returns: The block.
     - Throws: `AlgoTestError.mockConfigurationError` if block not found.
     */
    public func block(round: UInt64) throws -> MockResponses.Block {
        guard let block = blocks[round] else {
            throw AlgoTestError.mockConfigurationError("Block at round \(round) not found")
        }
        return block
    }

    /**
     Searches for transactions within a round range.

     - Parameters:
       - minRound: Minimum round number.
       - maxRound: Maximum round number.
     - Returns: Array of transactions within the round range.
     */
    public func transactions(
        minRound: UInt64,
        maxRound: UInt64
    ) -> [Transaction] {
        transactions.values.filter { txn in
            txn.firstValid >= minRound && txn.lastValid <= maxRound
        }
    }

    /**
     Gets transaction count for an account.

     - Parameter address: The account address.
     - Returns: Number of transactions for the account.
     */
    public func transactionCount(for address: String) -> Int {
        accountTransactions[address]?.count ?? 0
    }

    // MARK: - State Management

    /// Resets the mock indexer.
    public func reset() {
        transactions.removeAll()
        accountTransactions.removeAll()
        blocks.removeAll()
    }

    /// Returns all indexed transactions.
    public var allTransactions: [Transaction] {
        Array(transactions.values)
    }
}
