// MARK: - PushHandler - Availability & Platform Warnings

import Foundation

public class PushHandler {
    public init() {}

    // MARK: - Availability Warnings
    @available(macOS 11.0, iOS 14.0, *)
    public func newAPIMethod() {
        print("new API")
    }

    public func useNewAPI() {
        // Using without availability check could warn
        if #available(macOS 11.0, iOS 14.0, *) {
            newAPIMethod()
        }
    }

    // MARK: - Deprecated with Availability
    @available(*, deprecated, message: "Use newMethod instead")
    @available(macOS 10.15, iOS 13.0, *)
    public func oldMethod() {
        print("old")
    }

    public func callOldMethod() {
        if #available(macOS 10.15, iOS 13.0, *) {
            oldMethod() // deprecated warning
        }
    }

    // MARK: - Platform Specific
    #if os(macOS)
    public func macOnlyMethod() {
        print("macOS only")
    }
    #endif

    #if os(iOS)
    public func iOSOnlyMethod() {
        print("iOS only")
    }
    #endif

    // MARK: - Unused Import Style Warning Potential
    public func processNotification() {
        // Using fully qualified names unnecessarily
        let data = Foundation.Data()
        let date = Foundation.Date()
        let uuid = Foundation.UUID()

        print(data, date, uuid)
    }

    // MARK: - Integer Conversion Warnings
    public func integerConversions() {
        let int8: Int8 = 10
        let int16: Int16 = 100
        let int32: Int32 = 1000
        let int64: Int64 = 10000

        // Mixing integer types
        let sum1 = Int(int8) + Int(int16)
        let sum2 = Int(int32) + Int(int64)

        // Potential truncation
        let truncated1 = Int8(truncatingIfNeeded: int16)
        let truncated2 = Int16(truncatingIfNeeded: int32)

        print(sum1, sum2, truncated1, truncated2)
    }

    // MARK: - Unused Function Result Warning
    @discardableResult
    public func discardableMethod() -> Int {
        return 42
    }

    public func nonDiscardable() -> String {
        return "result"
    }

    public func callMethods() {
        discardableMethod() // OK - marked discardable
        nonDiscardable() // Warning - result unused
        nonDiscardable() // Another unused result
    }
}
