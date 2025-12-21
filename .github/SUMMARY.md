# swift-algotest Package Summary

## Overview

A comprehensive testing utilities framework for Algorand blockchain development, following 0xLeif's architectural patterns and Swift 6 best practices.

## Package Details

- **Name**: swift-algotest
- **Module**: AlgoTest
- **Swift Version**: 6.0+
- **Concurrency**: Strict concurrency enabled
- **Platforms**: iOS 15+, macOS 12+, tvOS 15+, watchOS 8+, visionOS 1+
- **License**: MIT
- **Test Coverage**: 83 tests, 100% passing

## Architecture Highlights

### Protocol-Oriented Design

- `Sandbox`: Protocol defining sandbox management operations
- Protocol extensions for convenience methods (`ensureRunning()`, `withRunning()`)
- Clean separation of concerns through protocol composition

### Actor-Based Concurrency

All stateful components implemented as actors for thread-safety:

1. **LocalSandbox**: Manages sandbox lifecycle with state transitions
2. **AccountFactory**: Creates and tracks test accounts
3. **AccountPool**: Provides reusable account pooling with automatic lifecycle
4. **MockAlgodClient**: Thread-safe mock implementation of Algod API
5. **MockIndexerClient**: Thread-safe mock implementation of Indexer API
6. **SnapshotCapture**: Captures blockchain state snapshots
7. **SnapshotStore**: Stores and compares state snapshots

### Sendable Conformance

All public types conform to `Sendable`:

- **Value Types**: `FundedAccount`, `Transaction`, `StateSnapshot`, all `MockResponses` types
- **Enums**: `SandboxState`, `AlgoTestError`, `TransactionScenarios`
- **Actors**: All stateful components listed above

### Type Safety

- Strong typing throughout the codebase
- Enums with associated values for error handling
- No force unwrapping in production code
- Proper optional handling with guard statements

## Module Structure

### Core (AlgoTestError.swift)

```
AlgoTestError: Error, Sendable, Equatable
├── Sandbox errors (notRunning, alreadyRunning, startupFailed, shutdownFailed)
├── Account errors (creationFailed, fundingFailed, insufficientBalance)
├── Transaction errors (buildFailed)
├── Assertion errors (assertionFailed)
├── Snapshot errors (captureFailed, comparisonFailed)
└── Mock errors (configurationError, invalidState)
```

### Sandbox Module (3 files)

1. **SandboxState.swift**: State machine for sandbox lifecycle
   - States: stopped, starting, running, stopping
   - Computed properties: isRunning, isStopped, isTransitioning

2. **Sandbox.swift**: Protocol defining sandbox operations
   - Properties: state, algodURL, indexerURL, apiToken
   - Methods: start(), stop(), reset(), waitForReady()
   - Extensions: ensureRunning(), withRunning()

3. **LocalSandbox.swift**: Actor implementation
   - Configuration support with defaults
   - State management with proper transitions
   - Async/await for all operations

### Accounts Module (3 files)

1. **FundedAccount.swift**: Immutable account representation
   - Address, private key, balance
   - Metadata with tags and purpose
   - Mock factory method with valid 58-char addresses
   - Fluent tagging API

2. **AccountFactory.swift**: Actor for account creation
   - Single account creation with funding
   - Batch account creation
   - Account funding operations
   - Account tracking and reset

3. **AccountPool.swift**: Actor for account pooling
   - Pre-initialized pool of accounts
   - Acquire/release pattern
   - Automatic expansion when exhausted
   - `withAccount()` for automatic lifecycle
   - Pool statistics tracking

### Transactions Module (2 files)

1. **TestTransactionBuilder.swift**: Fluent transaction builder
   - Sensible defaults (fee, valid rounds, genesis)
   - Chainable API: payment() -> to() -> amount() -> note() -> build()
   - Type-safe construction
   - Validation at build time

2. **TransactionScenarios.swift**: Pre-built test scenarios
   - Simple payment
   - Payment with note
   - Minimum balance payment
   - Large payment
   - Zero-amount payment
   - High-fee payment
   - Batch payments
   - Circular payments

### Assertions Module (4 files)

All extend `XCTestCase` for seamless integration:

1. **AlgorandAssertions.swift**: Core Algorand assertions
   - assertValidAddress()
   - assertValidTransaction()
   - assertThrowsError() (async version)
   - assertNoThrow() (async version)

2. **BalanceAssertions.swift**: Balance verification
   - assertSufficientBalance()
   - assertBalanceInRange()
   - assertBalanceEquals() (with tolerance)
   - assertCanAffordTransaction()

3. **TransactionAssertions.swift**: Transaction verification
   - assertTransactionParties()
   - assertTransactionAmount()
   - assertTransactionNote()
   - assertTransactionFeeInRange()
   - assertBatchSameSender()

4. **AssetAssertions.swift**: Asset verification
   - assertValidAssetID()
   - assertAssetHolding()
   - assertAssetConfig()

### Mocking Module (3 files)

1. **MockResponses.swift**: Sendable mock data types
   - AccountInfo
   - AssetHolding
   - TransactionResponse
   - Block
   - NodeStatus

2. **MockAlgodClient.swift**: Actor-based algod mock
   - Account registration and management
   - Transaction submission simulation
   - Balance updates
   - Round advancement
   - Complete state management

3. **MockIndexerClient.swift**: Actor-based indexer mock
   - Transaction indexing
   - Account transaction queries
   - Block storage and retrieval
   - Round range queries
   - Transaction counting

### Snapshots Module (3 files)

1. **StateSnapshot.swift**: Immutable state capture
   - Account states with balances and assets
   - Round information
   - Metadata (label, description, tags)
   - Diff computation with balance changes

2. **SnapshotCapture.swift**: Actor for capturing snapshots
   - Capture specific accounts
   - Capture all registered accounts
   - Capture before/after operations
   - Integration with mock clients

3. **SnapshotStore.swift**: Actor for snapshot storage
   - Store/retrieve snapshots by ID
   - Compare snapshots
   - Assert equality
   - Time-based queries
   - Chronological history

## Test Suite (83 tests, 8 files)

### Test Breakdown

1. **SandboxTests.swift** (12 tests)
   - State machine transitions
   - Start/stop lifecycle
   - URL access
   - Error handling
   - Helper methods

2. **AccountTests.swift** (12 tests)
   - Account creation
   - Metadata and tagging
   - Factory operations
   - Pool initialization
   - Acquire/release pattern
   - Statistics tracking

3. **TransactionTests.swift** (11 tests)
   - Builder pattern
   - Required fields validation
   - Note handling
   - Fee customization
   - All scenario types

4. **AssertionTests.swift** (14 tests)
   - Address validation
   - Transaction validation
   - Balance assertions
   - Transaction property assertions
   - Asset assertions

5. **MockingTests.swift** (11 tests)
   - Mock response types
   - Account registration
   - Transaction submission
   - Balance updates
   - Indexer operations

6. **SnapshotTests.swift** (12 tests)
   - Snapshot creation
   - Diff computation
   - Capture operations
   - Store operations
   - Comparison logic

7. **ErrorTests.swift** (7 tests)
   - Error equality
   - Error descriptions
   - All error cases

8. **IntegrationTests.swift** (4 tests)
   - End-to-end payment flow
   - Account pool integration
   - Batch transaction processing
   - Snapshot comparison workflows

## Key Design Patterns

### Builder Pattern
- `TestTransactionBuilder`: Fluent API for transaction construction
- Immutable intermediate states
- Type-safe compilation

### Factory Pattern
- `AccountFactory`: Centralized account creation
- Consistent configuration
- Lifecycle tracking

### Pool Pattern
- `AccountPool`: Resource reuse
- Automatic lifecycle management
- Statistics and monitoring

### Protocol Extensions
- Default implementations for common operations
- Composition over inheritance
- Flexibility without complexity

### Value Types
- Immutable data structures
- No shared mutable state
- Copy semantics for safety

## Swift 6 Features Used

1. **Strict Concurrency**: Enabled via SwiftSettings
2. **Actors**: For all stateful components
3. **Sendable Protocol**: On all public types
4. **Async/Await**: Throughout the API
5. **Property Wrappers**: For configuration
6. **Result Builders**: Potential future enhancement
7. **Modern Error Handling**: Typed throws with async

## Dependencies

- **swift-algorand**: Core Algorand SDK (local path)
- **swift-algokit**: AlgoKit integration (local path)
- **swift-docc-plugin**: Documentation generation

## Code Quality Standards

- No force unwrapping (!)
- Explicit capture lists in closures
- Guard statements for early returns
- Focused, single-responsibility functions
- Immutability by default (let over var)
- Clear, descriptive naming
- Comprehensive documentation
- 100% test coverage of public API

## Performance Characteristics

- Actor-based concurrency prevents data races
- Value types minimize allocation overhead
- Pool pattern reduces account creation cost
- Lazy initialization where appropriate
- Efficient snapshot diffing algorithm

## Future Enhancements

Potential areas for expansion:

1. Real AlgoKit localnet integration
2. Application testing utilities
3. Asset testing helpers
4. Smart contract testing support
5. Performance benchmarking tools
6. Network simulation
7. Failure injection
8. Time travel debugging
