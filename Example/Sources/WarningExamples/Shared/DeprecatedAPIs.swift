// MARK: - Shared Deprecated APIs
// These deprecated APIs are used across multiple files in the codebase

import Foundation

// MARK: - Deprecated Network APIs
@available(*, deprecated, message: "Use ModernHTTPClient instead")
public class DeprecatedNetworkClient {
    public static let shared = DeprecatedNetworkClient()
    public init() {}
    public func fetch(_ url: String) { print("fetching \(url)") }
    public func post(_ url: String, data: Any) { print("posting to \(url)") }
}

@available(*, deprecated, renamed: "AsyncDataLoader")
public class DeprecatedDataFetcher {
    public init() {}
    public func fetchData() -> Data? { return nil }
}

// MARK: - Deprecated Storage APIs
@available(*, deprecated, message: "Use EncryptedStorage instead")
public class DeprecatedUnsafeStorage {
    public static let shared = DeprecatedUnsafeStorage()
    public init() {}
    public func save(_ key: String, value: Any) { print("saving \(key)") }
    public func load(_ key: String) -> Any? { return nil }
}

@available(*, deprecated, renamed: "ModernCacheManager")
public class DeprecatedCacheManager {
    public static let shared = DeprecatedCacheManager()
    public init() {}
    public func store(_ item: Any) {}
    public func retrieve() -> Any? { return nil }
}

// MARK: - Deprecated Authentication APIs
@available(*, deprecated, message: "Use BiometricAuthService instead")
public class DeprecatedPasswordAuth {
    public static let shared = DeprecatedPasswordAuth()
    public init() {}
    public func authenticate(password: String) -> Bool { return true }
}

@available(*, deprecated, renamed: "SecureTokenService")
public class DeprecatedTokenManager {
    public static let shared = DeprecatedTokenManager()
    public init() {}
    public func getToken() -> String? { return nil }
    public func setToken(_ token: String) {}
}

// MARK: - Deprecated Logging APIs
@available(*, deprecated, message: "Use OSLogLogger instead")
public class DeprecatedPrintLogger {
    public static let shared = DeprecatedPrintLogger()
    public init() {}
    public func log(_ message: String) { print(message) }
    public func error(_ message: String) { print("ERROR: \(message)") }
}

// MARK: - Deprecated Utility Functions
@available(*, deprecated, renamed: "Date.formatted()")
public func deprecatedFormatDate(_ date: Date) -> String { return "\(date)" }

@available(*, deprecated, renamed: "String.sanitize()")
public func deprecatedSanitizeString(_ input: String) -> String { return input }

@available(*, deprecated, message: "Use Codable instead")
public func deprecatedParseJSON(_ data: Data) -> [String: Any]? { return nil }

@available(*, deprecated, renamed: "Data.checksum()")
public func deprecatedChecksum(_ data: Data) -> Int { return 0 }

@available(*, deprecated, message: "Use async/await instead")
public func deprecatedFetchWithCallback(_ url: String, completion: @escaping (Data?) -> Void) {
    completion(nil)
}
