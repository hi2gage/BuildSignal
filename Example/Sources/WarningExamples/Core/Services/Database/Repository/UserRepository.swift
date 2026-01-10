// MARK: - UserRepository - Mixed Warnings

import Foundation

@available(*, deprecated, message: "Use UserService instead")
public struct LegacyUser {
    public var id: Int
    public var name: String
    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

public class UserData {
    public var users: [String] = []
    public var cache: [Int: String] = [:]
    public init() {}
}

public actor UserActor {
    public init() {}
    public func save(_ data: UserData) {
        print(data.users)
    }
}

public class user_repository {
    // Non-standard naming
    public var USER_TABLE = "users"
    public var MAX_USERS = 1000
    private var _privateField = 0

    // Unused
    private var unusedQuery = "SELECT * FROM users"
    private var unusedLimit = 100

    public init() {}

    public func fetchUsers() async {
        // Deprecated
        let user1 = LegacyUser(id: 1, name: "John")
        let user2 = LegacyUser(id: 2, name: "Jane")
        let user3 = LegacyUser(id: 3, name: "Bob")

        // Unused
        let query1 = "SELECT"
        let query2 = "FROM"
        let query3 = "WHERE"

        // Never mutated
        var results = [String]()
        print(results)

        // Non-sendable to actor
        let actor = UserActor()
        let data = UserData()
        await actor.save(data)

        // Conditional cast
        let id: Int = 1
        if let _ = id as? Int {
            print("always")
        }

        print(user1.name, user2.name, user3.name)
    }

    // Unused parameters
    public func saveUser(id: Int, name: String, email: String, age: Int) {
        print("saving")
    }

    // Result unused
    private func validate() -> Bool { true }
    private func transform() -> String { "" }

    public func process() {
        validate()
        transform()
        validate()
    }
}
