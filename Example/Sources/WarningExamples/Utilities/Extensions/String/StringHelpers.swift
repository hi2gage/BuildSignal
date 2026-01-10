// MARK: - StringHelpers - Mixed Warnings

import Foundation

@available(*, deprecated, message: "Use StringExtensions instead")
public class LegacyStringUtils {
    public init() {}

    @available(*, deprecated, renamed: "trim(_:)")
    public func trimWhitespace(_ string: String) -> String {
        return string.trimmingCharacters(in: .whitespaces)
    }
}

public class StringContext {
    public var original: String = ""
    public var processed: String = ""
    public var encoding: String.Encoding = .utf8
    public init() {}
}

public actor StringActor {
    public init() {}
    public func process(_ context: StringContext) {
        print(context.original)
    }
}

public class string_helpers {
    // Naming
    public var DEFAULT_ENCODING = "utf8"
    public var Max_Length = 1000
    private var _locale = "en_US"

    // Unused
    private var unusedRegex: String?
    private var unusedFlags = 0

    public init() {}

    public func processString() async {
        // Deprecated
        let utils = LegacyStringUtils()
        let _ = utils.trimWhitespace("  hello  ")
        let _ = utils.trimWhitespace("  world  ")
        let _ = utils.trimWhitespace("  test  ")

        // Unused
        let str1 = "unused1"
        let str2 = "unused2"
        let str3 = "unused3"

        // Never mutated
        var context = StringContext()
        print(context.encoding)

        // Actor with non-sendable
        let actor = StringActor()
        let stringContext = StringContext()
        await actor.process(stringContext)

        // Conditional cast
        let text: String = "hello"
        if let _ = text as? String {
            print("always")
        }

        // Force unwrap
        let opt: Character? = "a"
        print(opt!)
    }

    // Unused params
    public func format(string: String, locale: String, options: [String: Any], flags: Int) -> String {
        return ""
    }

    // Result unused
    private func validate() -> Bool { true }
    private func normalize() -> String { "" }

    public func prepare() {
        validate()
        normalize()
        validate()
    }
}
