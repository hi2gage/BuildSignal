// MARK: - EventTracker - Additional Warning Types

import Foundation

// MARK: - Conformance Example
public class ConformanceExample: Equatable {
    public static func == (lhs: ConformanceExample, rhs: ConformanceExample) -> Bool { true }
}

// MARK: - Shadowing Warnings
public class EventTracker {
    public var eventName = "default"

    public init() {}

    public func trackEvent() {
        // Variable shadows instance property
        let eventName = "local"
        print(eventName)

        // More shadowing
        let count = 10
        for count in 0..<5 { // shadows outer count
            print(count)
        }

        // Parameter shadows
        func inner(eventName: String) { // shadows
            print(eventName)
        }
        inner(eventName: "test")
    }

    // MARK: - String Interpolation Debug Description
    public func logObjects() {
        let obj1 = NSObject()
        let obj2 = NSObject()
        let anyArray: [Any] = [1, "two", 3.0]
        let anyDict: [String: Any] = ["key": NSObject()]

        // String interpolation produces debug description
        let msg1 = "Object: \(obj1)"
        let msg2 = "Object: \(obj2)"
        let msg3 = "Array: \(anyArray)"
        let msg4 = "Dict: \(anyDict)"

        print(msg1, msg2, msg3, msg4)
    }

    // MARK: - Implicit Coercion to Any
    public func coerceToAny() {
        var anyArray: [Any] = []

        // Implicit coercion
        anyArray.append(42)
        anyArray.append("string")
        anyArray.append(3.14)
        anyArray.append(true)
        anyArray.append([1, 2, 3])

        print(anyArray)
    }

    // MARK: - Weak reference not needed
    public func unnecessaryWeak() {
        let nonEscaping = { (block: () -> Void) in
            block()
        }

        // weak self not needed in non-escaping closure
        nonEscaping { [weak self] in
            print(self ?? "nil")
        }

        nonEscaping { [weak self] in
            guard let self = self else { return }
            print(self.eventName)
        }
    }
}
