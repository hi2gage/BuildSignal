// MARK: - ConsoleLogger - Mixed Warnings

import Foundation

@available(*, deprecated, message: "Use StructuredLogger instead")
public class LegacyLogger {
    public init() {}

    @available(*, deprecated, renamed: "log(_:level:)")
    public func print(_ message: String) {
        Swift.print(message)
    }
}

public class LogContext {
    public var timestamp: Date = Date()
    public var level: String = "INFO"
    public var metadata: [String: Any] = [:]
    public init() {}
}

public actor LogActor {
    public init() {}
    public func write(_ context: LogContext) {
        Swift.print(context.level)
    }
}

public class console_logger {
    // Naming
    public var LOG_LEVEL = "DEBUG"
    public var Output_Format = "json"
    private var _buffer: [String] = []

    // Unused
    private var unusedMaxSize = 1000
    private var unusedFlushInterval = 60.0

    // Implicitly unwrapped
    public var outputStream: Any!

    public init() {}

    public func log() async {
        // Deprecated
        let logger = LegacyLogger()
        logger.print("test message 1")
        logger.print("test message 2")
        logger.print("test message 3")

        // Unused
        let msg1 = "debug"
        let msg2 = "info"
        let msg3 = "error"

        // Never mutated
        var context = LogContext()
        Swift.print(context.timestamp)

        // Actor with non-sendable
        let actor = LogActor()
        let logContext = LogContext()
        await actor.write(logContext)

        // Conditional cast
        let level: String = "INFO"
        if let _ = level as? String {
            Swift.print("always")
        }

        // Force unwrap
        let opt: Date? = Date()
        Swift.print(opt!)
    }

    // Unused params
    public func format(message: String, level: String, timestamp: Date, context: [String: Any]) -> String {
        return ""
    }

    // Result unused
    private func createEntry() -> String { "" }
    public func flush() {
        createEntry()
        createEntry()
    }
}
