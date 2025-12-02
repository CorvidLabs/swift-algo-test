# AlgoTest

![Swift 6.0+](https://img.shields.io/badge/Swift-6.0+-orange.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20visionOS%20%7C%20Linux-lightgrey.svg)
![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)

A comprehensive testing utilities framework for Algorand blockchain development in Swift, built with Swift 6 and strict concurrency support.

## Features

- **Sandbox Management**: Protocol-based sandbox control with state management
- **Account Management**: Factory pattern for creating and funding test accounts with pooling support
- **Transaction Building**: Fluent API for building test transactions with sensible defaults
- **Mock Clients**: Actor-based mock implementations of Algod and Indexer clients
- **State Snapshots**: Capture and compare blockchain state across operations
- **Comprehensive Assertions**: XCTest extensions for Algorand-specific testing

## Requirements

- Swift 6.0+
- iOS 15.0+ / macOS 12.0+ / tvOS 15.0+ / watchOS 8.0+ / visionOS 1.0+

## Installation

Add AlgoTest to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/CorvidLabs/swift-algo-test.git", from: "0.1.0")
]
```

## Quick Start

### Sandbox Management

```swift
import AlgoTest

// Create and start a local sandbox
let sandbox = LocalSandbox()
try await sandbox.start()

// Get sandbox URLs
let algodURL = try await sandbox.algodURL
let indexerURL = try await sandbox.indexerURL

// Ensure sandbox is running before operations
try await sandbox.ensureRunning()

// Stop the sandbox
try await sandbox.stop()
```

### Account Creation

```swift
import AlgoTest

// Create a single funded account
let factory = AccountFactory()
let account = try await factory.createAccount(
    fundedWith: 10_000_000, // 10 ALGO
    purpose: "Test sender"
)

// Create multiple accounts at once
let accounts = try await factory.createAccounts(
    count: 5,
    fundedWith: 5_000_000
)

// Use an account pool for efficient reuse
let pool = AccountPool()
try await pool.initialize()

try await pool.withAccount { account in
    // Use account here
    // Automatically released back to pool
}
```

### Transaction Building

```swift
import AlgoTest

let sender = FundedAccount.mock()
let receiver = FundedAccount.mock()

// Build a payment transaction
let transaction = try TestTransactionBuilder
    .payment(from: sender)
    .to(receiver)
    .amount(1_000_000)
    .note("Test payment")
    .fee(2_000)
    .build()

// Use pre-built scenarios
let tx = try TransactionScenarios.simplePayment(
    from: sender,
    to: receiver,
    amount: 500_000
)

// Batch payments
let transactions = try TransactionScenarios.batchPayments(
    from: sender,
    to: [receiver1, receiver2, receiver3],
    amount: 1_000_000
)
```

### Mock Clients

```swift
import AlgoTest

// Create mock algod client
let client = MockAlgodClient()

// Register accounts
await client.register(account: MockResponses.AccountInfo(
    address: "ADDR...",
    balance: 10_000_000
))

// Submit transactions
let txID = try await client.submitTransaction(transaction)

// Advance blockchain rounds
await client.advance(rounds: 5)

// Query account info
let accountInfo = try await client.accountInfo(for: address)
```

### State Snapshots

```swift
import AlgoTest

let client = MockAlgodClient()
let capture = SnapshotCapture(client: client)

// Capture state before and after operations
let result = try await capture.captureAround(
    accounts: [sender.address, receiver.address]
) {
    // Perform operations
    return try await client.submitTransaction(transaction)
}

// Compare snapshots
let diff = result.after.diff(from: result.before)
if let change = diff.balanceChanges[sender.address] {
    print("Balance changed by: \(change.delta)")
}

// Store snapshots for later comparison
let store = SnapshotStore()
await store.store(id: "before", snapshot: result.before)
await store.store(id: "after", snapshot: result.after)

let comparison = try await store.compare(from: "before", to: "after")
```

### Test Assertions

```swift
import XCTest
import AlgoTest

class MyAlgorandTests: XCTestCase {
    func testPayment() async throws {
        let sender = FundedAccount.mock(balance: 10_000_000)
        let receiver = FundedAccount.mock()

        let transaction = try TestTransactionBuilder
            .payment(from: sender)
            .to(receiver)
            .amount(1_000_000)
            .build()

        // Validate transaction structure
        assertValidTransaction(transaction)
        assertTransactionParties(transaction, sender: sender, receiver: receiver)
        assertTransactionAmount(transaction, equals: 1_000_000)

        // Validate account can afford transaction
        assertCanAffordTransaction(account: sender, transaction: transaction)

        // Validate balances
        assertSufficientBalance(account: sender, required: 1_001_000)
        assertBalanceInRange(sender.initialBalance, min: 1_000_000, max: 100_000_000)
    }
}
```

## Architecture

### Protocol-Oriented Design

AlgoTest follows protocol-oriented design principles with the `Sandbox` protocol defining sandbox operations:

```swift
protocol Sandbox: Sendable {
    var state: SandboxState { get async }
    var algodURL: URL { get async throws }
    var indexerURL: URL { get async throws }

    func start() async throws
    func stop() async throws
    func reset() async throws
}
```

### Actor-Based Concurrency

All stateful components use Swift actors for thread-safe operations:

- `LocalSandbox`: Manages sandbox lifecycle
- `AccountFactory`: Creates and tracks accounts
- `AccountPool`: Manages reusable account pool
- `MockAlgodClient`: Thread-safe mock client
- `MockIndexerClient`: Thread-safe indexer mock
- `SnapshotCapture`: Captures state snapshots
- `SnapshotStore`: Stores and compares snapshots

### Sendable Conformance

All public types conform to `Sendable` for safe concurrent usage:

- Value types: `FundedAccount`, `Transaction`, `StateSnapshot`, `MockResponses.*`
- Enums: `SandboxState`, `AlgoTestError`, `TransactionScenarios`
- Actors: All stateful components

## Error Handling

AlgoTest uses a comprehensive error type with `Sendable` conformance:

```swift
enum AlgoTestError: Error, Sendable, Equatable {
    case sandboxNotRunning
    case sandboxAlreadyRunning
    case accountCreationFailed(String)
    case fundingFailed(amount: UInt64, reason: String)
    case insufficientBalance(required: UInt64, available: UInt64)
    case transactionBuildFailed(String)
    case assertionFailed(String)
    case snapshotCaptureFailed(String)
    case mockConfigurationError(String)
    // ...
}
```

## Testing

The package includes 83+ comprehensive tests covering:

- Sandbox lifecycle management
- Account creation and pooling
- Transaction building and scenarios
- Mock client operations
- State snapshots and comparisons
- All assertion helpers
- Integration scenarios

Run tests:

```bash
swift test
```

## License

MIT License - Copyright (c) 2024 Leif

## Contributing

Contributions are welcome! Please ensure:

- Swift 6 compatibility
- Strict concurrency support
- All types are `Sendable`
- Comprehensive test coverage
- Clear documentation
