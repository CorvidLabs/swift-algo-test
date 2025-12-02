import Foundation

/// Actor managing a reusable pool of funded accounts for efficient testing.
public actor AccountPool {
    private var availableAccounts: [FundedAccount]
    private var inUseAccounts: Set<String>
    private let factory: AccountFactory
    private let poolSize: Int

    public struct Configuration: Sendable {
        public let poolSize: Int
        public let accountFunding: UInt64

        public init(
            poolSize: Int = 10,
            accountFunding: UInt64 = 10_000_000
        ) {
            self.poolSize = poolSize
            self.accountFunding = accountFunding
        }

        public static let `default` = Configuration()
    }

    public init(
        factory: AccountFactory = AccountFactory(),
        configuration: Configuration = .default
    ) {
        self.factory = factory
        self.poolSize = configuration.poolSize
        self.availableAccounts = []
        self.inUseAccounts = []
    }

    /// Initializes the pool by pre-creating accounts.
    public func initialize() async throws {
        guard availableAccounts.isEmpty else { return }

        availableAccounts = try await factory.createAccounts(count: poolSize)
    }

    /// Acquires an account from the pool.
    /// - Returns: An available account, or creates a new one if pool is exhausted.
    public func acquire() async throws -> FundedAccount {
        if let account = availableAccounts.first {
            availableAccounts.removeFirst()
            inUseAccounts.insert(account.address)
            return account
        }

        // Pool exhausted, create a new account
        let account = try await factory.createAccount()
        inUseAccounts.insert(account.address)
        return account
    }

    /// Releases an account back to the pool.
    /// - Parameter account: The account to release.
    public func release(_ account: FundedAccount) {
        guard inUseAccounts.contains(account.address) else { return }

        inUseAccounts.remove(account.address)
        availableAccounts.append(account)
    }

    /// Executes a block with an account from the pool, automatically releasing it.
    /// - Parameter body: The operation to perform with the account.
    /// - Returns: The result of the operation.
    public func withAccount<T>(
        _ body: (FundedAccount) async throws -> T
    ) async throws -> T {
        let account = try await acquire()
        defer { release(account) }
        return try await body(account)
    }

    /// Returns pool statistics.
    public var statistics: Statistics {
        Statistics(
            available: availableAccounts.count,
            inUse: inUseAccounts.count,
            total: availableAccounts.count + inUseAccounts.count
        )
    }

    public struct Statistics: Sendable, Equatable {
        public let available: Int
        public let inUse: Int
        public let total: Int
    }

    /// Resets the pool to its initial state.
    public func reset() async throws {
        availableAccounts.removeAll()
        inUseAccounts.removeAll()
        try await initialize()
    }
}
