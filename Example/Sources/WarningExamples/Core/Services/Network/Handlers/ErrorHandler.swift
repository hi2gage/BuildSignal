// MARK: - ErrorHandler - Mixed Warnings

import Foundation

@available(*, deprecated, renamed: "ModernErrorHandler")
public class LegacyErrorHandler {
    public init() {}

    @available(*, deprecated, message: "Use handleError(_:) instead")
    public func handle(_ error: Error) {
        print(error)
    }
}

public class ErrorContext {
    public var code: Int = 0
    public var message: String = ""
    public var underlying: Error?
    public init() {}
}

public class error_handler {
    // Non-standard naming throughout
    public var ERROR_CODE = 0
    public var Error_Message = ""
    public var retry_count = 0

    // Unused
    private var _internalCache: [Int: String] = [:]
    private var __doubleUnderscore = true

    public init() {}

    public func handleError() async {
        // Deprecation warnings
        let handler = LegacyErrorHandler()
        handler.handle(NSError(domain: "test", code: 1))

        // Unused variables
        let errorInfo1 = ["code": 500]
        let errorInfo2 = ["message": "error"]
        let errorInfo3 = [1, 2, 3]

        // Never mutated
        var context = ErrorContext()
        print(context.code)

        // Non-sendable crossing
        Task.detached { [self] in
            print(ERROR_CODE)
            print(Error_Message)
        }

        // Force unwrap
        let optional: String? = "value"
        print(optional!)

        // Unreachable code
        return
        print("never executed")
    }

    // Unused parameters
    public func logError(code: Int, message: String, timestamp: Date, metadata: [String: Any]) {
        print("logging")
    }
}
