// MARK: - FileLogger - Mixed Warnings

import Foundation

@available(*, deprecated, message: "Use RotatingFileLogger instead")
public struct LegacyLogFile {
    public var path: String
    public var size: Int
    public init(path: String, size: Int) {
        self.path = path
        self.size = size
    }
}

public class FileLogState {
    public var currentFile: URL?
    public var bytesWritten: Int = 0
    public var rotationCount: Int = 0
    public init() {}
}

@MainActor
public class FileLogPresenter {
    public var state: FileLogState?
    public init() {}
    public func update(_ state: FileLogState) {
        self.state = state
    }
}

public class FILE_LOGGER {
    // Naming
    public var MAX_FILE_SIZE = 1024 * 1024
    public var Rotation_Count = 5
    private var __currentPath: String?

    // Unused
    private var unusedCompression = true
    private var unusedEncryption = false

    public init() {}

    public func writeLog() async {
        // Deprecated
        let file1 = LegacyLogFile(path: "/var/log/app.log", size: 1024)
        let file2 = LegacyLogFile(path: "/var/log/app.1.log", size: 2048)
        let file3 = LegacyLogFile(path: "/var/log/app.2.log", size: 512)

        // Unused
        let path1 = "/tmp/log1"
        let path2 = "/tmp/log2"
        let data1 = Data()

        // Never mutated
        var state = FileLogState()
        print(state.bytesWritten)

        // MainActor crossing
        let presenter = await FileLogPresenter()
        let logState = FileLogState()
        await presenter.update(logState)

        // Conditional cast
        let size: Int = 1024
        if let _ = size as? Int {
            print("always")
        }

        print(file1.path, file2.path, file3.path)

        // Nil comparison
        let count = 0
        if count == nil {
            print("never")
        }
    }

    // Unused params
    public func rotate(maxFiles: Int, maxSize: Int, compress: Bool, encrypt: Bool) {
        print("rotating")
    }

    // Unreachable
    public func close() {
        return
        __currentPath = nil
    }
}
