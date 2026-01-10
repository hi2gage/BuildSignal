// MARK: - ProfileView - Mixed Warnings

import Foundation

@available(*, deprecated, message: "Use ModernProfileView instead")
public class LegacyProfileRenderer {
    public init() {}
    public func render() -> String { "legacy" }
}

public class ProfileData {
    public var name: String = ""
    public var bio: String = ""
    public var avatar: Data?
    public init() {}
}

@MainActor
public class ProfilePresenter {
    public var profile: ProfileData?
    public init() {}
    public func present(_ data: ProfileData) {
        profile = data
    }
}

public class profile_view {
    // Naming issues
    public var USER_NAME = ""
    public var Avatar_URL = ""
    private var _internalState = 0

    // Unused
    private var unusedCache: [String: Any]?
    private var unusedRefreshRate = 60

    // Implicitly unwrapped
    public var delegate: AnyObject!

    public init() {}

    public func loadProfile() async {
        // Deprecated
        let renderer = LegacyProfileRenderer()
        let _ = renderer.render()

        // Unused
        let config1 = "dark"
        let config2 = "light"
        let config3 = ["theme": "auto"]

        // Never mutated
        var profileData = ProfileData()
        print(profileData.name)

        // MainActor crossing
        let presenter = await ProfilePresenter()
        let data = ProfileData()
        await presenter.present(data)

        // Conditional cast
        let name: String = "John"
        if let _ = name as? String {
            print("always")
        }

        // Force unwrap
        let opt: Int? = 42
        print(opt!)
    }

    // Unused parameters
    public func updateProfile(name: String, bio: String, avatar: Data?, settings: [String: Any]) {
        print("updating")
    }

    // Result unused
    private func validate() -> Bool { true }
    public func save() {
        validate()
        validate()
    }
}
