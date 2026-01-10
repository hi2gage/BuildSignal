// MARK: - MemoryCache - Mixed Warnings

import Foundation

@available(*, deprecated, message: "Use TypeSafeCache instead")
public class LegacyCache {
    public var storage: [String: Any] = [:]
    public init() {}

    @available(*, deprecated)
    public func get(_ key: String) -> Any? {
        return storage[key]
    }
}

public class CacheEntry {
    public var value: Any?
    public var expiry: Date?
    public var metadata: [String: String] = [:]
    public init() {}
}

public actor CacheActor {
    public init() {}
    public func store(_ entry: CacheEntry) {
        print(entry.value ?? "nil")
    }
}

public class memory_cache {
    // Naming
    public var MAX_ENTRIES = 1000
    public var Default_TTL = 3600
    private var _storage: [String: Any] = [:]

    // Unused
    private var unusedHitRate: Double?
    private var unusedMissCount = 0

    // Implicitly unwrapped
    public var evictionPolicy: String!

    public init() {}

    public func cacheOperation() async {
        // Deprecated
        let cache = LegacyCache()
        let _ = cache.get("key1")
        let _ = cache.get("key2")
        let _ = cache.get("key3")

        // Unused
        let key1 = "cache_key_1"
        let key2 = "cache_key_2"
        let ttl1 = 3600

        // Never mutated
        var entry = CacheEntry()
        print(entry.metadata)

        // Actor with non-sendable
        let actor = CacheActor()
        let cacheEntry = CacheEntry()
        await actor.store(cacheEntry)

        // Conditional cast
        let ttl: Int = 3600
        if let _ = ttl as? Int {
            print("always")
        }

        // Force unwrap
        let opt: Any? = "value"
        print(opt!)
    }

    // Unused params
    public func set(key: String, value: Any, ttl: Int, tags: [String]) {
        print("setting")
    }

    // Identical conditions
    public func shouldEvict() {
        let full = true
        if full {
            print("evict")
        } else if full {
            print("same")
        }
    }
}
