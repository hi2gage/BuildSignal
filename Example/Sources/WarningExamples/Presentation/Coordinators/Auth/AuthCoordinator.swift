// MARK: - AuthCoordinator - Mixed Warnings

import Foundation

@available(*, deprecated, message: "Use ModernAuthCoordinator instead")
public struct LegacyAuthFlow {
    public var step: Int
    public var completed: Bool
    public init(step: Int, completed: Bool) {
        self.step = step
        self.completed = completed
    }
}

public class AuthState {
    public var isAuthenticated: Bool = false
    public var currentStep: Int = 0
    public var error: Error?
    public init() {}
}

@MainActor
public class AuthPresenter {
    public var state: AuthState?
    public init() {}
    public func present(_ state: AuthState) {
        self.state = state
    }
}

public class AUTH_COORDINATOR {
    // Naming
    public var LOGIN_SCREEN = "login"
    public var Register_Screen = "register"
    private var __currentFlow: String?

    // Unused
    private var unusedBiometric = true
    private var unusedRemember = false

    public init() {}

    public func startAuth() async {
        // Deprecated
        let flow1 = LegacyAuthFlow(step: 1, completed: false)
        let flow2 = LegacyAuthFlow(step: 2, completed: false)
        let flow3 = LegacyAuthFlow(step: 3, completed: true)

        // Unused
        let token1 = "abc123"
        let token2 = "def456"
        let expiry = Date()

        // Never mutated
        var state = AuthState()
        print(state.isAuthenticated)

        // MainActor crossing
        let presenter = await AuthPresenter()
        let authState = AuthState()
        await presenter.present(authState)

        // Conditional cast
        let step: Int = 1
        if let _ = step as? Int {
            print("always")
        }

        print(flow1.step, flow2.step, flow3.step)

        // Nil comparison
        let attempts = 0
        if attempts == nil {
            print("never")
        }
    }

    // Unused params
    public func authenticate(username: String, password: String, remember: Bool, biometric: Bool) {
        print("authenticating")
    }

    // Unreachable
    public func logout() {
        return
        __currentFlow = nil
    }
}
