// MARK: - AppCoordinator - Mixed Warnings

import Foundation

@available(*, deprecated, message: "Use ModernAppCoordinator instead")
public class LegacyCoordinator {
    public init() {}

    @available(*, deprecated, renamed: "start()")
    public func begin() {
        print("beginning")
    }
}

public class CoordinatorState {
    public var currentScreen: String = "home"
    public var navigationStack: [String] = []
    public var isPresenting: Bool = false
    public init() {}
}

public actor CoordinatorActor {
    public init() {}
    public func navigate(_ state: CoordinatorState) {
        print(state.currentScreen)
    }
}

public class app_coordinator {
    // Naming
    public var ROOT_SCREEN = "home"
    public var Tab_Index = 0
    private var _childCoordinators: [Any] = []

    // Unused
    private var unusedDeepLink: URL?
    private var unusedAnimations = true

    // Implicitly unwrapped
    public var window: AnyObject!

    public init() {}

    public func start() async {
        // Deprecated
        let coordinator = LegacyCoordinator()
        coordinator.begin()

        // Unused
        let screen1 = "login"
        let screen2 = "home"
        let screen3 = "profile"

        // Never mutated
        var state = CoordinatorState()
        print(state.navigationStack)

        // Actor with non-sendable
        let actor = CoordinatorActor()
        let coordState = CoordinatorState()
        await actor.navigate(coordState)

        // Conditional cast
        let screen: String = "home"
        if let _ = screen as? String {
            print("always")
        }

        // Force unwrap
        let opt: Int? = 0
        print(opt!)
    }

    // Unused params
    public func navigate(to screen: String, params: [String: Any], animated: Bool, completion: (() -> Void)?) {
        print("navigating")
    }

    // Result unused
    private func findChild() -> Any? { nil }
    public func cleanup() {
        findChild()
        findChild()
    }
}
