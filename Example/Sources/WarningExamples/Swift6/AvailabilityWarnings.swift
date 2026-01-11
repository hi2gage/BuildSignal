// MARK: - Availability Warnings

import Foundation

// Using APIs without availability checks
public class AvailabilityIssues {
    public init() {}

    // Using newer APIs without checks
    @available(macOS 15.0, iOS 18.0, *)
    public func newAPIMethod() {
        print("New API")
    }

    @available(macOS 14.0, iOS 17.0, *)
    public func anotherNewMethod() {
        print("Another new method")
    }

    @available(macOS 13.0, iOS 16.0, *)
    public func iOS16Method() {
        print("iOS 16 method")
    }

    // Calling without proper checks
    public func callWithoutCheck() {
        if #available(macOS 15.0, iOS 18.0, *) {
            newAPIMethod()
        }

        if #available(macOS 14.0, iOS 17.0, *) {
            anotherNewMethod()
        }
    }
}

// Deprecated with availability
@available(*, deprecated, message: "Use NewClass instead")
public class DeprecatedClass1 {
    public init() {}
    public func method() {}
}

@available(*, deprecated, renamed: "RenamedClass")
public class OldClassName1 {
    public init() {}
}

@available(macOS, deprecated: 14.0, message: "Use new API")
@available(iOS, deprecated: 17.0, message: "Use new API")
public class PlatformDeprecated1 {
    public init() {}
    public func doWork() {}
}

@available(macOS, deprecated: 13.0)
@available(iOS, deprecated: 16.0)
public class OlderDeprecated1 {
    public init() {}
}

// Using deprecated APIs
public func useDeprecated() {
    let _ = DeprecatedClass1()
    let _ = OldClassName1()
    let _ = PlatformDeprecated1()
    let _ = OlderDeprecated1()

    let obj = DeprecatedClass1()
    obj.method()

    let platform = PlatformDeprecated1()
    platform.doWork()
}

// Obsoleted APIs
@available(*, unavailable, message: "This was removed")
public class RemovedClass {
    public init() {}
}

@available(macOS, obsoleted: 14.0)
@available(iOS, obsoleted: 17.0)
public class ObsoletedClass {
    public init() {}
}

// Introduced in future version
@available(macOS 99.0, iOS 99.0, *)
public class FutureClass {
    public init() {}
    public func futureMethod() {}
}

@available(macOS 15.0, iOS 18.0, *)
public class RecentClass {
    public init() {}

    public func method1() {}
    public func method2() {}
    public func method3() {}
}

// Conditional availability patterns
public func conditionalAvailability() {
    if #available(macOS 15.0, iOS 18.0, *) {
        let recent = RecentClass()
        recent.method1()
        recent.method2()
    } else {
        // Fallback code
        print("Not available")
    }

    guard #available(macOS 14.0, iOS 17.0, *) else {
        return
    }

    // Available here
    let issues = AvailabilityIssues()
    issues.anotherNewMethod()
}

// Protocol with availability
@available(macOS 14.0, iOS 17.0, *)
public protocol NewProtocol {
    func newRequirement()
}

@available(macOS 14.0, iOS 17.0, *)
public class NewProtocolImpl: NewProtocol {
    public init() {}
    public func newRequirement() {}
}

// Stored property with availability
public class PropertyAvailability {
    @available(macOS 14.0, iOS 17.0, *)
    public var newProperty: String = ""

    @available(macOS 15.0, iOS 18.0, *)
    public var evenNewerProperty: Int = 0

    public init() {}

    public func accessProperties() {
        if #available(macOS 14.0, iOS 17.0, *) {
            print(newProperty)
        }

        if #available(macOS 15.0, iOS 18.0, *) {
            print(evenNewerProperty)
        }
    }
}

// Extension with availability
@available(macOS 14.0, iOS 17.0, *)
public extension String {
    var newStringProperty: Bool {
        !isEmpty
    }

    func newStringMethod() -> String {
        uppercased()
    }
}

// Nested types with availability
public class OuterAvailability {
    public init() {}

    @available(macOS 14.0, iOS 17.0, *)
    public class NestedNew {
        public init() {}
        public func nestedMethod() {}
    }

    @available(macOS 15.0, iOS 18.0, *)
    public struct NestedStruct {
        public init() {}
        public var value: Int = 0
    }
}

// Generic constraints with availability
@available(macOS 14.0, iOS 17.0, *)
public func genericWithAvailability<T: NewProtocol>(_ value: T) {
    value.newRequirement()
}

// Enum with availability
public enum MixedAvailabilityEnum {
    case always
    case alsoAlways

    @available(macOS 14.0, iOS 17.0, *)
    case newCase

    @available(macOS 15.0, iOS 18.0, *)
    case newerCase
}

public func switchMixedEnum(_ value: MixedAvailabilityEnum) {
    switch value {
    case .always:
        print("always")
    case .alsoAlways:
        print("also always")
    case .newCase:
        if #available(macOS 14.0, iOS 17.0, *) {
            print("new case")
        }
    case .newerCase:
        if #available(macOS 15.0, iOS 18.0, *) {
            print("newer case")
        }
    }
}

// Backdeployment - requires function to be available before the backDeploy version
@available(macOS 13.0, iOS 16.0, *)
@backDeployed(before: macOS 14.0, iOS 17.0)
public func backdeployedFunction() -> Int {
    42
}
