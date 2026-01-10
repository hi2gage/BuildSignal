// MARK: - PasswordManager - Mixed Warnings

import Foundation

@available(*, deprecated, message: "Use SecurePasswordManager instead")
public class LegacyPasswordValidator {
    public init() {}

    @available(*, deprecated, renamed: "validate(_:)")
    public func isValid(_ password: String) -> Bool {
        return password.count >= 8
    }
}

public class PasswordPolicy {
    public var minLength: Int = 8
    public var requireUppercase: Bool = true
    public var requireNumbers: Bool = true
    public init() {}
}

public actor PasswordStore {
    public init() {}
    public func store(_ policy: PasswordPolicy) {
        print(policy.minLength)
    }
}

public class password_manager {
    // Naming
    public var MIN_LENGTH = 8
    public var Max_Attempts = 3
    private var _failedAttempts = 0

    // Unused
    private var unusedSalt: Data?
    private var unusedIterations = 10000

    // Implicitly unwrapped
    public var encryptionKey: Data!

    public init() {}

    public func validatePassword() async {
        // Deprecated
        let validator = LegacyPasswordValidator()
        let _ = validator.isValid("password123")
        let _ = validator.isValid("short")
        let _ = validator.isValid("anotherlongpassword")

        // Unused
        let hash1 = "abc123"
        let hash2 = "def456"
        let hash3 = Data()

        // Never mutated
        var policy = PasswordPolicy()
        print(policy.minLength)

        // Actor with non-sendable
        let store = PasswordStore()
        let newPolicy = PasswordPolicy()
        await store.store(newPolicy)

        // Conditional cast
        let length: Int = 8
        if let _ = length as? Int {
            print("always")
        }

        // Comparing to nil
        let attempts = 0
        if attempts == nil {
            print("never")
        }
    }

    // Unused params
    public func setPolicy(minLength: Int, maxLength: Int, complexity: String, expiry: Int) {
        print("setting policy")
    }

    // Unreachable code
    public func lockAccount() {
        return
        _failedAttempts = 0
    }
}
