// MARK: - ProfileViewModel - Mixed Warnings

import Foundation

@available(*, deprecated, message: "Use ReactiveProfileVM instead")
public class LegacyProfileVM {
    public var name: String = ""
    public init() {}

    @available(*, deprecated)
    public func load() {}
}

public class ProfileState {
    public var isLoading: Bool = false
    public var error: Error?
    public var data: [String: Any] = [:]
    public init() {}
}

public actor ProfileActor {
    public init() {}
    public func update(_ state: ProfileState) {
        print(state.isLoading)
    }
}

public class PROFILE_VIEW_MODEL {
    // Non-standard naming
    public var Is_Loading = false
    public var Error_Message = ""
    private var __privateData: Any?

    // Unused
    private var unusedTimer: Timer?
    private var unusedInterval = 30.0

    public init() {}

    public func fetchProfile() async {
        // Deprecated
        let vm = LegacyProfileVM()
        vm.load()
        print(vm.name)

        // Unused
        let temp1 = UUID()
        let temp2 = Date()
        let temp3 = [String: Int]()

        // Never mutated
        var state = ProfileState()
        print(state.isLoading)

        // Actor crossing with non-sendable
        let actor = ProfileActor()
        let profileState = ProfileState()
        await actor.update(profileState)

        // No async in await
        let _ = await syncMethod()

        // Comparing to nil
        let value = 100
        if value == nil {
            print("never")
        }
    }

    private func syncMethod() -> Int { 1 }

    // Unused params
    public func configure(theme: String, locale: String, options: [String: Bool]) {
        print("configuring")
    }

    // Identical conditions
    public func checkState() {
        let ready = true
        if ready {
            print("ready")
        } else if ready {
            print("same")
        }
    }
}
