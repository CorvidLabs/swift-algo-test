import Foundation

/// Represents the current state of a sandbox environment.
public enum SandboxState: Sendable, Equatable, CustomStringConvertible {
    case stopped
    case starting
    case running(startedAt: Date)
    case stopping

    public var isRunning: Bool {
        if case .running = self {
            return true
        }
        return false
    }

    public var isStopped: Bool {
        self == .stopped
    }

    public var isTransitioning: Bool {
        switch self {
        case .starting, .stopping:
            return true
        case .stopped, .running:
            return false
        }
    }

    public var description: String {
        switch self {
        case .stopped:
            return "stopped"
        case .starting:
            return "starting"
        case .running(let startedAt):
            return "running (started at \(startedAt))"
        case .stopping:
            return "stopping"
        }
    }
}
