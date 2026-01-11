// MARK: - SessionManager - Mixed Warnings

import Foundation

@available(*, deprecated, message: "Use SecureSessionManager instead")
public struct LegacySession {
    public var id: UUID
    public var userId: Int
    public init(id: UUID, userId: Int) {
        self.id = id
        self.userId = userId
    }
}

public class SessionState {
    public var isActive: Bool = false
    public var lastActivity: Date = Date()
    public var metadata: [String: Any] = [:]
    public init() {}
}

@globalActor
public actor SessionActor {
    public static let shared = SessionActor()
}

@SessionActor
public class SessionStore {
    public var sessions: [UUID: SessionState] = [:]
    public init() {}
    public func add(_ state: SessionState) {
        sessions[UUID()] = state
    }
}

public class SESSION_MANAGER {
    // All caps class name + properties
    public var MAX_SESSIONS = 10
    public var Session_Timeout = 3600
    private var _activeSessions: [UUID] = []

    // Unused
    private var unusedCounter = 0
    private var unusedFlag = false

    public init() {}

    public func createSession() async {
        // Shared deprecated APIs
        DeprecatedNetworkClient.shared.fetch("/api/session")
        DeprecatedUnsafeStorage.shared.save("session", value: [:])
        DeprecatedPrintLogger.shared.log("Creating session")
        DeprecatedTokenManager.shared.setToken("session_token")
        let _ = DeprecatedPasswordAuth.shared.authenticate(password: "session")

        // Local deprecated
        let session1 = LegacySession(id: UUID(), userId: 1)
        let session2 = LegacySession(id: UUID(), userId: 2)

        // Unused
        let config1 = ["timeout": 3600]
        let config2 = ["maxRetries": 3]
        let config3 = true

        // Never mutated
        var state = SessionState()
        print(state.isActive)

        // GlobalActor crossing
        let store = await SessionStore()
        let newState = SessionState()
        await store.add(newState)

        // Conditional cast
        let uuid: UUID = UUID()
        if let _ = uuid as? UUID {
            print("always")
        }

        print(session1.userId, session2.userId)
        _ = (config1, config2, config3)
    }

    // Unused params
    public func validateSession(id: UUID, userId: Int, timestamp: Date, ip: String) -> Bool {
        DeprecatedCacheManager.shared.store("validation")
        return true
    }

    // Unreachable
    public func invalidate() {
        return
        _activeSessions.removeAll()
    }
}
