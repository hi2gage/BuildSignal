// MARK: - TokenManager - Mixed Warnings

import Foundation

@available(*, deprecated, message: "Use SecureTokenManager instead")
public class LegacyTokenStorage {
    public var tokens: [String: String] = [:]
    public init() {}

    @available(*, deprecated, renamed: "store(_:forKey:)")
    public func save(_ token: String, key: String) {
        tokens[key] = token
    }
}

public class TokenData {
    public var accessToken: String = ""
    public var refreshToken: String = ""
    public var expiry: Date = Date()
    public init() {}
}

public actor SecureStorage {
    public init() {}
    public func store(_ data: TokenData) {
        print(data.accessToken)
    }
}

public class token_manager {
    // Naming
    public var ACCESS_TOKEN = ""
    public var Refresh_Token = ""
    private var __secretKey = "secret"

    // Implicitly unwrapped
    public var currentUser: String!
    public var sessionID: UUID!

    // Unused
    private var unusedExpiry: Date?
    private var unusedRefreshInterval = 3600

    public init() {}

    public func refreshToken() async {
        // Deprecated
        let storage = LegacyTokenStorage()
        storage.save("token123", key: "access")
        storage.save("refresh456", key: "refresh")

        // Unused
        let oldToken = "old_token"
        let newToken = "new_token"
        let timestamp = Date()

        // Never mutated
        var tokenData = TokenData()
        print(tokenData.accessToken)

        // Non-sendable to actor
        let secure = SecureStorage()
        let data = TokenData()
        await secure.store(data)

        // No async in await
        let _ = await validateToken()

        // Force unwrap
        let opt: String? = "value"
        print(opt!)
    }

    private func validateToken() -> Bool { true }

    // Identical conditions
    public func checkExpiry() {
        let expired = true
        if expired {
            print("expired")
        } else if expired {
            print("same condition")
        }
    }
}
