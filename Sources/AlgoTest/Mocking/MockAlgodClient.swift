import Foundation

/// Mock implementation of an Algod client for unit testing.
public actor MockAlgodClient {
    private var accounts: [String: MockResponses.AccountInfo]
    private var transactions: [String: MockResponses.TransactionResponse]
    private var currentRound: UInt64
    private var nodeStatus: MockResponses.NodeStatus

    public init(initialRound: UInt64 = 1_000) {
        self.accounts = [:]
        self.transactions = [:]
        self.currentRound = initialRound
        self.nodeStatus = MockResponses.NodeStatus(lastRound: initialRound)
    }

    // MARK: - Configuration

    /// Registers a mock account.
    public func register(account: MockResponses.AccountInfo) {
        accounts[account.address] = account
    }

    /// Registers multiple mock accounts.
    public func register(accounts: [MockResponses.AccountInfo]) {
        for account in accounts {
            register(account: account)
        }
    }

    /// Registers a mock transaction response.
    public func register(transactionID: String, response: MockResponses.TransactionResponse) {
        transactions[transactionID] = response
    }

    /// Updates the current round.
    public func advance(rounds: UInt64 = 1) {
        currentRound += rounds
        nodeStatus = MockResponses.NodeStatus(lastRound: currentRound)
    }

    // MARK: - Query Operations

    /// Gets account information.
    public func accountInfo(for address: String) throws -> MockResponses.AccountInfo {
        guard let account = accounts[address] else {
            throw AlgoTestError.mockConfigurationError("Account \(address) not registered")
        }
        return account
    }

    /// Gets transaction information.
    public func transaction(id: String) throws -> MockResponses.TransactionResponse {
        guard let transaction = transactions[id] else {
            throw AlgoTestError.mockConfigurationError("Transaction \(id) not registered")
        }
        return transaction
    }

    /// Gets current node status.
    public func status() -> MockResponses.NodeStatus {
        nodeStatus
    }

    /// Gets the current round.
    public func getCurrentRound() -> UInt64 {
        currentRound
    }

    // MARK: - Transaction Simulation

    /// Simulates submitting a transaction.
    public func submitTransaction(_ transaction: Transaction) throws -> String {
        // Verify sender exists and has sufficient balance
        guard let sender = accounts[transaction.sender] else {
            throw AlgoTestError.mockConfigurationError("Sender account not registered")
        }

        let totalCost = transaction.amount + transaction.fee
        guard sender.balance >= totalCost else {
            throw AlgoTestError.insufficientBalance(
                required: totalCost,
                available: sender.balance
            )
        }

        // Update balances
        let newSenderBalance = sender.balance - totalCost
        accounts[transaction.sender] = MockResponses.AccountInfo(
            address: sender.address,
            balance: newSenderBalance,
            round: currentRound,
            assets: sender.assets
        )

        if let receiver = accounts[transaction.receiver] {
            let newReceiverBalance = receiver.balance + transaction.amount
            accounts[transaction.receiver] = MockResponses.AccountInfo(
                address: receiver.address,
                balance: newReceiverBalance,
                round: currentRound,
                assets: receiver.assets
            )
        }

        // Generate transaction ID
        let txID = UUID().uuidString
        let response = MockResponses.TransactionResponse.confirmed(round: currentRound)
        transactions[txID] = response

        return txID
    }

    // MARK: - State Management

    /// Resets the mock client to initial state.
    public func reset() {
        accounts.removeAll()
        transactions.removeAll()
        currentRound = 1_000
        nodeStatus = MockResponses.NodeStatus(lastRound: currentRound)
    }

    /// Returns all registered accounts.
    public var registeredAccounts: [MockResponses.AccountInfo] {
        Array(accounts.values)
    }
}
