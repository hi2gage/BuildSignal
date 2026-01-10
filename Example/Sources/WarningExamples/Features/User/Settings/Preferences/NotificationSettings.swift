// MARK: - NotificationSettings - Mixed Warnings

import Foundation

@available(*, deprecated, message: "Use NotificationPreferences instead")
public enum LegacyNotificationLevel {
    case all
    case important
    case none
}

public class NotificationConfig {
    public var enabled: Bool = true
    public var sound: Bool = true
    public var badge: Bool = true
    public init() {}
}

@MainActor
public class NotificationPresenter {
    public var config: NotificationConfig?
    public init() {}
    public func show(_ config: NotificationConfig) {
        self.config = config
    }
}

public class notification_settings {
    // Naming
    public var PUSH_ENABLED = true
    public var Sound_Enabled = true
    private var _badgeCount = 0

    // Unused
    private var unusedToken: String?
    private var unusedCategory = "default"

    // Implicitly unwrapped
    public var deviceToken: Data!

    public init() {}

    public func configure() async {
        // Deprecated
        let level1: LegacyNotificationLevel = .all
        let level2: LegacyNotificationLevel = .important
        let level3: LegacyNotificationLevel = .none

        // Unused
        let setting1 = ["enabled": true]
        let setting2 = ["vibrate": false]
        let setting3 = 60

        // Never mutated
        var config = NotificationConfig()
        print(config.enabled)

        // MainActor crossing
        let presenter = await NotificationPresenter()
        let notifConfig = NotificationConfig()
        await presenter.show(notifConfig)

        // Conditional cast
        let flag: Bool = true
        if let _ = flag as? Bool {
            print("always")
        }

        print(level1, level2, level3)

        // Force unwrap
        let opt: String? = "test"
        print(opt!)
    }

    // Unused params
    public func setPreferences(push: Bool, email: Bool, sms: Bool, frequency: String) {
        print("setting")
    }

    // Empty blocks
    public func reset() {
        if PUSH_ENABLED {
            // empty
        }
    }
}
