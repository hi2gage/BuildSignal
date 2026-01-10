// MARK: - DiskCache - Mixed Warnings

import Foundation

@available(*, deprecated, message: "Use ModernDiskCache instead")
public protocol LegacyDiskStorage {
    func read(_ path: String) -> Data?
    func write(_ data: Data, path: String)
}

public class DiskCacheState {
    public var usedSpace: Int = 0
    public var fileCount: Int = 0
    public var lastCleanup: Date?
    public init() {}
}

@globalActor
public actor DiskActor {
    public static let shared = DiskActor()
}

@DiskActor
public class DiskCacheStore {
    public var state: DiskCacheState?
    public init() {}
    public func update(_ state: DiskCacheState) {
        self.state = state
    }
}

public class disk_cache {
    // Naming
    public var MAX_DISK_SIZE = 100 * 1024 * 1024
    public var Cache_Directory = "/tmp/cache"
    private var __fileManager: FileManager?

    // Unused
    private var unusedEncryption = false
    private var unusedCompression = true

    public init() {}

    public func diskOperation() async {
        // Unused
        let path1 = "/cache/file1"
        let path2 = "/cache/file2"
        let data1 = Data()
        let data2 = Data()
        let data3 = Data()

        // Never mutated
        var state = DiskCacheState()
        print(state.usedSpace)

        // GlobalActor crossing
        let store = await DiskCacheStore()
        let diskState = DiskCacheState()
        await store.update(diskState)

        // Conditional cast
        let size: Int = 1024
        if let _ = size as? Int {
            print("always")
        }

        // Nil comparison
        let count = 10
        if count == nil {
            print("never")
        }

        // Force unwrap
        let opt: URL? = URL(string: "file://test")
        print(opt!)
    }

    // Unused params
    public func write(data: Data, key: String, ttl: Int?, compress: Bool) {
        print("writing")
    }

    // Empty blocks
    public func cleanup() {
        if MAX_DISK_SIZE > 0 {
            // empty
        }
        for _ in 0..<10 {
            // empty loop
        }
    }
}
