import Foundation

/// Actor-based implementation of a local AlgoKit sandbox for testing.
public actor LocalSandbox: Sandbox {
    private var currentState: SandboxState
    private let configuration: Configuration

    /// Configuration for the local sandbox.
    public struct Configuration: Sendable {
        public let algodPort: Int
        public let indexerPort: Int
        public let apiToken: String
        public let workingDirectory: URL

        public init(
            algodPort: Int = 4001,
            indexerPort: Int = 8980,
            apiToken: String = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
            workingDirectory: URL = URL(fileURLWithPath: FileManager.default.temporaryDirectory.path)
        ) {
            self.algodPort = algodPort
            self.indexerPort = indexerPort
            self.apiToken = apiToken
            self.workingDirectory = workingDirectory
        }

        public static let `default` = Configuration()
    }

    public var state: SandboxState {
        currentState
    }

    public var algodURL: URL {
        get throws {
            guard currentState.isRunning else {
                throw AlgoTestError.sandboxNotRunning
            }
            return URL(string: "http://localhost:\(configuration.algodPort)")!
        }
    }

    public var indexerURL: URL {
        get throws {
            guard currentState.isRunning else {
                throw AlgoTestError.sandboxNotRunning
            }
            return URL(string: "http://localhost:\(configuration.indexerPort)")!
        }
    }

    public var apiToken: String {
        get throws {
            guard currentState.isRunning else {
                throw AlgoTestError.sandboxNotRunning
            }
            return configuration.apiToken
        }
    }

    public init(configuration: Configuration = .default) {
        self.configuration = configuration
        self.currentState = .stopped
    }

    public func start() async throws {
        guard currentState.isStopped else {
            throw AlgoTestError.sandboxAlreadyRunning
        }

        currentState = .starting

        // Simulate sandbox startup
        // In a real implementation, this would execute algokit localnet start
        do {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            currentState = .running(startedAt: Date())
        } catch {
            currentState = .stopped
            throw AlgoTestError.sandboxStartupFailed(error.localizedDescription)
        }
    }

    public func stop() async throws {
        guard currentState.isRunning else {
            throw AlgoTestError.sandboxNotRunning
        }

        currentState = .stopping

        // Simulate sandbox shutdown
        // In a real implementation, this would execute algokit localnet stop
        do {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            currentState = .stopped
        } catch {
            currentState = .running(startedAt: Date())
            throw AlgoTestError.sandboxShutdownFailed(error.localizedDescription)
        }
    }

    public func reset() async throws {
        let wasRunning = currentState.isRunning

        if wasRunning {
            try await stop()
        }

        // Simulate cleanup
        try await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds

        if wasRunning {
            try await start()
        }
    }

    public func waitForReady(timeout: TimeInterval = 30) async throws {
        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            if currentState.isRunning {
                return
            }
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }

        throw AlgoTestError.sandboxStartupFailed("Timeout waiting for sandbox to be ready")
    }
}
