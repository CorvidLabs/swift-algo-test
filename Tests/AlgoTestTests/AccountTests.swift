import XCTest
@testable import AlgoTest

final class AccountTests: XCTestCase {
    func testFundedAccountCreation() {
        let account = FundedAccount(
            address: "TEST123",
            privateKey: Data(repeating: 1, count: 32),
            initialBalance: 1_000_000
        )

        XCTAssertEqual(account.address, "TEST123")
        XCTAssertEqual(account.initialBalance, 1_000_000)
    }

    func testFundedAccountMock() {
        let account = FundedAccount.mock(balance: 5_000_000)
        XCTAssertEqual(account.initialBalance, 5_000_000)
    }

    func testFundedAccountTagging() {
        let account = FundedAccount.mock()
            .tagged("test", "integration")

        XCTAssertTrue(account.metadata.tags.contains("test"))
        XCTAssertTrue(account.metadata.tags.contains("integration"))
    }

    func testAccountFactoryCreateAccount() async throws {
        let factory = AccountFactory()
        let account = try await factory.createAccount(
            fundedWith: 2_000_000,
            purpose: "Test account"
        )

        XCTAssertEqual(account.initialBalance, 2_000_000)
        XCTAssertEqual(account.metadata.purpose, "Test account")
    }

    func testAccountFactoryCreateMultipleAccounts() async throws {
        let factory = AccountFactory()
        let accounts = try await factory.createAccounts(
            count: 5,
            fundedWith: 1_000_000
        )

        XCTAssertEqual(accounts.count, 5)
        for account in accounts {
            XCTAssertEqual(account.initialBalance, 1_000_000)
        }
    }

    func testAccountFactoryFundAccount() async throws {
        let factory = AccountFactory()
        let account = try await factory.createAccount(fundedWith: 1_000_000)
        let funded = try await factory.fundAccount(account, with: 500_000)

        XCTAssertEqual(funded.initialBalance, 1_500_000)
    }

    func testAccountFactoryTracksAccounts() async throws {
        let factory = AccountFactory()
        _ = try await factory.createAccount()
        _ = try await factory.createAccount()

        let accounts = await factory.accounts
        XCTAssertEqual(accounts.count, 2)
    }

    func testAccountFactoryReset() async throws {
        let factory = AccountFactory()
        _ = try await factory.createAccount()

        await factory.reset()

        let accounts = await factory.accounts
        XCTAssertEqual(accounts.count, 0)
    }

    func testAccountPoolInitialization() async throws {
        let pool = AccountPool()
        try await pool.initialize()

        let stats = await pool.statistics
        XCTAssertEqual(stats.available, 10)
        XCTAssertEqual(stats.inUse, 0)
    }

    func testAccountPoolAcquire() async throws {
        let pool = AccountPool()
        try await pool.initialize()

        let account = try await pool.acquire()

        XCTAssertNotNil(account)

        let stats = await pool.statistics
        XCTAssertEqual(stats.available, 9)
        XCTAssertEqual(stats.inUse, 1)
    }

    func testAccountPoolRelease() async throws {
        let pool = AccountPool()
        try await pool.initialize()

        let account = try await pool.acquire()
        await pool.release(account)

        let stats = await pool.statistics
        XCTAssertEqual(stats.available, 10)
        XCTAssertEqual(stats.inUse, 0)
    }

    func testAccountPoolWithAccount() async throws {
        let pool = AccountPool()
        try await pool.initialize()

        let initialStats = await pool.statistics

        let result = try await pool.withAccount { account in
            let stats = await pool.statistics
            XCTAssertEqual(stats.inUse, 1)
            return account.address
        }

        XCTAssertFalse(result.isEmpty)

        let finalStats = await pool.statistics
        XCTAssertEqual(finalStats.available, initialStats.available)
        XCTAssertEqual(finalStats.inUse, 0)
    }
}
