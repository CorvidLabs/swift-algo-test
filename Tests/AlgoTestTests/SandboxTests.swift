import XCTest
@testable import AlgoTest

final class SandboxTests: XCTestCase {
    func testSandboxStateInitialization() {
        let state = SandboxState.stopped
        XCTAssertTrue(state.isStopped)
        XCTAssertFalse(state.isRunning)
        XCTAssertFalse(state.isTransitioning)
    }

    func testSandboxStateRunning() {
        let state = SandboxState.running(startedAt: Date())
        XCTAssertTrue(state.isRunning)
        XCTAssertFalse(state.isStopped)
        XCTAssertFalse(state.isTransitioning)
    }

    func testSandboxStateTransitioning() {
        let starting = SandboxState.starting
        XCTAssertTrue(starting.isTransitioning)

        let stopping = SandboxState.stopping
        XCTAssertTrue(stopping.isTransitioning)
    }

    func testLocalSandboxStart() async throws {
        let sandbox = LocalSandbox()

        var state = await sandbox.state
        XCTAssertTrue(state.isStopped)

        try await sandbox.start()

        state = await sandbox.state
        XCTAssertTrue(state.isRunning)
    }

    func testLocalSandboxStop() async throws {
        let sandbox = LocalSandbox()
        try await sandbox.start()

        var state = await sandbox.state
        XCTAssertTrue(state.isRunning)

        try await sandbox.stop()

        state = await sandbox.state
        XCTAssertTrue(state.isStopped)
    }

    func testLocalSandboxStartWhenAlreadyRunning() async throws {
        let sandbox = LocalSandbox()
        try await sandbox.start()

        await assertThrowsError(
            try await sandbox.start(),
            expectedError: AlgoTestError.sandboxAlreadyRunning
        )
    }

    func testLocalSandboxStopWhenNotRunning() async throws {
        let sandbox = LocalSandbox()

        await assertThrowsError(
            try await sandbox.stop(),
            expectedError: AlgoTestError.sandboxNotRunning
        )
    }

    func testLocalSandboxReset() async throws {
        let sandbox = LocalSandbox()
        try await sandbox.start()
        try await sandbox.reset()

        let state = await sandbox.state
        XCTAssertTrue(state.isRunning)
    }

    func testLocalSandboxURLsWhenRunning() async throws {
        let sandbox = LocalSandbox()
        try await sandbox.start()

        let algodURL = try await sandbox.algodURL
        XCTAssertEqual(algodURL.absoluteString, "http://localhost:4001")

        let indexerURL = try await sandbox.indexerURL
        XCTAssertEqual(indexerURL.absoluteString, "http://localhost:8980")
    }

    func testLocalSandboxURLsWhenStopped() async throws {
        let sandbox = LocalSandbox()

        do {
            _ = try await sandbox.algodURL
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? AlgoTestError, .sandboxNotRunning)
        }
    }

    func testLocalSandboxEnsureRunning() async throws {
        let sandbox = LocalSandbox()
        try await sandbox.ensureRunning()

        let state = await sandbox.state
        XCTAssertTrue(state.isRunning)
    }

    func testLocalSandboxWithRunning() async throws {
        let sandbox = LocalSandbox()

        let result = try await sandbox.withRunning {
            let state = await sandbox.state
            return state.isRunning
        }

        XCTAssertTrue(result)
    }
}
