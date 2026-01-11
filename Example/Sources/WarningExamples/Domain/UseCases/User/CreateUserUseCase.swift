// MARK: - CreateUserUseCase - Mixed Warnings

import Foundation

@available(*, deprecated, message: "Use UserCreationService instead")
public class LegacyUserCreator {
    public init() {}

    @available(*, deprecated)
    public func create(name: String) -> Int {
        return 1
    }
}

public class UserCreationContext {
    public var name: String = ""
    public var email: String = ""
    public var metadata: [String: Any] = [:]
    public init() {}
}

public actor UserCreationActor {
    public init() {}
    public func execute(_ context: UserCreationContext) {
        print(context.name)
    }
}

public class create_user_use_case {
    // Naming
    public var DEFAULT_ROLE = "user"
    public var Max_Users = 10000
    private var _validator: Any?

    // Unused
    private var unusedCache: [Int: String] = [:]
    private var unusedTimeout = 30

    // Implicitly unwrapped
    public var repository: AnyObject!

    public init() {}

    public func execute() async {
        // Shared deprecated APIs
        DeprecatedNetworkClient.shared.fetch("/api/users")
        DeprecatedNetworkClient.shared.post("/api/users/create", data: [:])
        DeprecatedUnsafeStorage.shared.save("user", value: [:])
        DeprecatedPrintLogger.shared.log("Creating user")
        DeprecatedTokenManager.shared.setToken("user_token")
        let _ = DeprecatedPasswordAuth.shared.authenticate(password: "create")
        let _ = deprecatedSanitizeString("input")

        // Local deprecated
        let creator = LegacyUserCreator()
        let _ = creator.create(name: "John")
        let _ = creator.create(name: "Jane")
        let _ = creator.create(name: "Bob")

        // Unused
        let userId1 = UUID()
        let userId2 = UUID()
        let timestamp = Date()

        // Never mutated
        var context = UserCreationContext()
        print(context.email)

        // Actor with non-sendable
        let actor = UserCreationActor()
        let creationContext = UserCreationContext()
        await actor.execute(creationContext)

        // Conditional cast
        let name: String = "test"
        if let _ = name as? String {
            print("always")
        }

        // Force unwrap
        let opt: Int? = 1
        print(opt!)

        _ = (userId1, userId2, timestamp)
    }

    // Unused params
    public func createUser(name: String, email: String, role: String, settings: [String: Any]) -> Int {
        DeprecatedCacheManager.shared.store("user")
        deprecatedFetchWithCallback("/api/validate") { _ in }
        return 0
    }

    // Identical conditions
    public func validate() {
        let valid = true
        if valid {
            print("valid")
        } else if valid {
            print("same")
        }
    }
}
