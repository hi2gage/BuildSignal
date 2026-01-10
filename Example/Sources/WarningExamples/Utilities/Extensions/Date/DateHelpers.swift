// MARK: - DateHelpers - Mixed Warnings

import Foundation

@available(*, deprecated, message: "Use DateExtensions instead")
public struct LegacyDateFormatter {
    public var format: String
    public init(format: String) {
        self.format = format
    }

    @available(*, deprecated)
    public func string(from date: Date) -> String {
        return "\(date)"
    }
}

public class DateContext {
    public var date: Date = Date()
    public var timezone: TimeZone = .current
    public var locale: Locale = .current
    public init() {}
}

@MainActor
public class DatePresenter {
    public var context: DateContext?
    public init() {}
    public func present(_ context: DateContext) {
        self.context = context
    }
}

public class DATE_HELPERS {
    // Naming
    public var DEFAULT_FORMAT = "yyyy-MM-dd"
    public var Time_Zone = "UTC"
    private var __calendar: Calendar?

    // Unused
    private var unusedLocale: Locale?
    private var unusedEra = 1

    public init() {}

    public func formatDate() async {
        // Deprecated
        let formatter1 = LegacyDateFormatter(format: "yyyy-MM-dd")
        let formatter2 = LegacyDateFormatter(format: "HH:mm:ss")
        let _ = formatter1.string(from: Date())
        let _ = formatter2.string(from: Date())

        // Unused
        let date1 = Date()
        let date2 = Date()
        let interval1 = 3600.0

        // Never mutated
        var context = DateContext()
        print(context.timezone)

        // MainActor crossing
        let presenter = await DatePresenter()
        let dateContext = DateContext()
        await presenter.present(dateContext)

        // Conditional cast
        let now: Date = Date()
        if let _ = now as? Date {
            print("always")
        }

        // Nil comparison
        let timestamp = 0
        if timestamp == nil {
            print("never")
        }
    }

    // Unused params
    public func parse(string: String, format: String, timezone: TimeZone?, locale: Locale?) -> Date? {
        return nil
    }

    // Unreachable
    public func reset() {
        return
        __calendar = nil
    }
}
