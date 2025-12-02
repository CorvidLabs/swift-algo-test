import Foundation

/// Protocol defining sandbox management operations for Algorand testing environments.
public protocol Sandbox: Sendable {
    /// The current state of the sandbox.
    var state: SandboxState { get async }

    /// The base URL for the algod API endpoint.
    var algodURL: URL { get async throws }

    /// The base URL for the indexer API endpoint.
    var indexerURL: URL { get async throws }

    /// The API token for authenticating with the sandbox.
    var apiToken: String { get async throws }

    /// Starts the sandbox environment.
    /// - Throws: `AlgoTestError.sandboxStartupFailed` if startup fails.
    func start() async throws

    /// Stops the sandbox environment.
    /// - Throws: `AlgoTestError.sandboxShutdownFailed` if shutdown fails.
    func stop() async throws

    /// Resets the sandbox to a clean state.
    /// - Throws: `AlgoTestError` if reset fails.
    func reset() async throws

    /// Waits for the sandbox to be ready for operations.
    /// - Parameter timeout: Maximum time to wait in seconds.
    /// - Throws: `AlgoTestError` if sandbox doesn't become ready within timeout.
    func waitForReady(timeout: TimeInterval) async throws
}

extension Sandbox {
    /// Ensures the sandbox is running, starting it if necessary.
    public func ensureRunning() async throws {
        let currentState = await state
        if !currentState.isRunning {
            try await start()
        }
    }

    /// Executes a block with a running sandbox, ensuring cleanup.
    /// - Parameter body: The async operation to perform.
    /// - Returns: The result of the body operation.
    public func withRunning<T>(
        _ body: () async throws -> T
    ) async throws -> T {
        try await ensureRunning()
        return try await body()
    }
}
