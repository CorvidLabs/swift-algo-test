import Foundation

/// Errors that can occur during Algorand testing operations.
public enum AlgoTestError: Error, Sendable, Equatable {
    case sandboxNotRunning
    case sandboxAlreadyRunning
    case sandboxStartupFailed(String)
    case sandboxShutdownFailed(String)
    case accountCreationFailed(String)
    case fundingFailed(amount: UInt64, reason: String)
    case insufficientBalance(required: UInt64, available: UInt64)
    case transactionBuildFailed(String)
    case assertionFailed(String)
    case snapshotCaptureFailed(String)
    case snapshotComparisonFailed(expected: String, actual: String)
    case mockConfigurationError(String)
    case invalidState(String)
}

extension AlgoTestError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .sandboxNotRunning:
            return "Sandbox is not running"
        case .sandboxAlreadyRunning:
            return "Sandbox is already running"
        case .sandboxStartupFailed(let message):
            return "Sandbox startup failed: \(message)"
        case .sandboxShutdownFailed(let message):
            return "Sandbox shutdown failed: \(message)"
        case .accountCreationFailed(let reason):
            return "Account creation failed: \(reason)"
        case .fundingFailed(let amount, let reason):
            return "Failed to fund account with \(amount) microAlgos: \(reason)"
        case .insufficientBalance(let required, let available):
            return "Insufficient balance: required \(required), available \(available)"
        case .transactionBuildFailed(let reason):
            return "Transaction build failed: \(reason)"
        case .assertionFailed(let message):
            return "Assertion failed: \(message)"
        case .snapshotCaptureFailed(let reason):
            return "Snapshot capture failed: \(reason)"
        case .snapshotComparisonFailed(let expected, let actual):
            return "Snapshot comparison failed: expected \(expected), got \(actual)"
        case .mockConfigurationError(let message):
            return "Mock configuration error: \(message)"
        case .invalidState(let message):
            return "Invalid state: \(message)"
        }
    }
}
