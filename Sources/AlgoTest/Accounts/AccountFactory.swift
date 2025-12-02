import Foundation

/// Actor responsible for creating and funding test accounts.
public actor AccountFactory {
    private var createdAccounts: [FundedAccount]
    private let defaultFundingAmount: UInt64

    /// Configuration for account creation.
    public struct Configuration: Sendable {
        public let defaultFundingAmount: UInt64
        public let minimumBalance: UInt64

        public init(
            defaultFundingAmount: UInt64 = 10_000_000, // 10 ALGO
            minimumBalance: UInt64 = 100_000 // 0.1 ALGO
        ) {
            self.defaultFundingAmount = defaultFundingAmount
            self.minimumBalance = minimumBalance
        }

        public static let `default` = Configuration()
    }

    public init(configuration: Configuration = .default) {
        self.createdAccounts = []
        self.defaultFundingAmount = configuration.defaultFundingAmount
    }

    /// Creates a new funded account.
    /// - Parameters:
    ///   - amount: The amount to fund in microAlgos. Defaults to configuration amount.
    ///   - purpose: Optional description of the account's purpose.
    ///   - tags: Tags for categorizing the account.
    /// - Returns: A newly created and funded account.
    public func createAccount(
        fundedWith amount: UInt64? = nil,
        purpose: String? = nil,
        tags: Set<String> = []
    ) async throws -> FundedAccount {
        let fundingAmount = amount ?? defaultFundingAmount

        // Generate a mock account
        // In a real implementation, this would generate actual Algorand keys
        let address = generateMockAddress()
        let privateKey = generateMockPrivateKey()

        let account = FundedAccount(
            address: address,
            privateKey: privateKey,
            initialBalance: fundingAmount,
            metadata: FundedAccount.Metadata(
                purpose: purpose,
                tags: tags
            )
        )

        createdAccounts.append(account)
        return account
    }

    /// Creates multiple accounts at once.
    /// - Parameters:
    ///   - count: Number of accounts to create.
    ///   - amount: Funding amount per account.
    /// - Returns: Array of created accounts.
    public func createAccounts(
        count: Int,
        fundedWith amount: UInt64? = nil
    ) async throws -> [FundedAccount] {
        try await withThrowingTaskGroup(of: FundedAccount.self) { group in
            for index in 0..<count {
                group.addTask {
                    try await self.createAccount(
                        fundedWith: amount,
                        purpose: "Batch account \(index + 1)"
                    )
                }
            }

            var accounts: [FundedAccount] = []
            for try await account in group {
                accounts.append(account)
            }
            return accounts
        }
    }

    /// Funds an existing account with additional microAlgos.
    /// - Parameters:
    ///   - account: The account to fund.
    ///   - amount: The amount to add.
    /// - Returns: Updated account with new balance.
    public func fundAccount(
        _ account: FundedAccount,
        with amount: UInt64
    ) async throws -> FundedAccount {
        // In a real implementation, this would submit a payment transaction
        let newBalance = account.initialBalance + amount

        return FundedAccount(
            address: account.address,
            privateKey: account.privateKey,
            initialBalance: newBalance,
            metadata: account.metadata
        )
    }

    /// Returns all accounts created by this factory.
    public var accounts: [FundedAccount] {
        createdAccounts
    }

    /// Clears all tracked accounts.
    public func reset() {
        createdAccounts.removeAll()
    }

    // MARK: - Private Helpers

    private func generateMockAddress() -> String {
        let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
        return String((0..<58).map { _ in chars.randomElement()! })
    }

    private func generateMockPrivateKey() -> Data {
        Data((0..<32).map { _ in UInt8.random(in: 0...255) })
    }
}
