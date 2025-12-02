import Foundation

/// Actor managing storage and comparison of state snapshots.
public actor SnapshotStore {
    private var snapshots: [String: StateSnapshot]
    private var history: [SnapshotEntry]

    private struct SnapshotEntry: Sendable {
        let id: String
        let timestamp: Date
        let snapshot: StateSnapshot
    }

    public init() {
        self.snapshots = [:]
        self.history = []
    }

    /// Stores a snapshot with a unique identifier.
    public func store(id: String, snapshot: StateSnapshot) {
        snapshots[id] = snapshot
        history.append(SnapshotEntry(
            id: id,
            timestamp: Date(),
            snapshot: snapshot
        ))
    }

    /// Retrieves a stored snapshot.
    public func retrieve(id: String) throws -> StateSnapshot {
        guard let snapshot = snapshots[id] else {
            throw AlgoTestError.snapshotCaptureFailed("Snapshot '\(id)' not found")
        }
        return snapshot
    }

    /// Compares two stored snapshots.
    public func compare(
        from fromID: String,
        to toID: String
    ) throws -> SnapshotDiff {
        let fromSnapshot = try retrieve(id: fromID)
        let toSnapshot = try retrieve(id: toID)

        return toSnapshot.diff(from: fromSnapshot)
    }

    /// Asserts that two snapshots are equal.
    public func assertEqual(
        _ id1: String,
        _ id2: String
    ) throws {
        let snapshot1 = try retrieve(id: id1)
        let snapshot2 = try retrieve(id: id2)

        guard snapshot1.accounts == snapshot2.accounts else {
            throw AlgoTestError.snapshotComparisonFailed(
                expected: id1,
                actual: id2
            )
        }
    }

    /// Gets all snapshot IDs in chronological order.
    public var snapshotIDs: [String] {
        history.map { $0.id }
    }

    /// Gets the number of stored snapshots.
    public var count: Int {
        snapshots.count
    }

    /// Clears all stored snapshots.
    public func clear() {
        snapshots.removeAll()
        history.removeAll()
    }

    /// Removes a specific snapshot.
    public func remove(id: String) {
        snapshots.removeValue(forKey: id)
        history.removeAll { $0.id == id }
    }

    /// Gets snapshots within a time range.
    public func snapshots(
        from start: Date,
        to end: Date
    ) -> [StateSnapshot] {
        history
            .filter { $0.timestamp >= start && $0.timestamp <= end }
            .map { $0.snapshot }
    }
}
