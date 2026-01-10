// MARK: - Message - Generic & Type Warnings

import Foundation

// MARK: - Redundant Constraints
public class GenericContainer<T> where T: Any { // T: Any is redundant
    public var value: T
    public init(value: T) { self.value = value }
}

public class AnotherGeneric<T: AnyObject> where T: AnyObject { // Redundant constraint
    public var ref: T
    public init(ref: T) { self.ref = ref }
}

// MARK: - Protocol with Unnecessary Constraint
public protocol DataHolder {
    associatedtype Element
}

// MARK: - Forward Reference Potential
public class Message {
    // Forward reference to nested type
    public var status: MessageStatus = .pending

    public enum MessageStatus {
        case pending
        case sent
        case delivered
        case read
    }

    public init() {}

    // MARK: - Pattern Matching Warnings
    public func checkStatus() {
        // Redundant pattern in switch
        switch status {
        case .pending:
            print("pending")
        case .sent:
            print("sent")
        case .delivered:
            print("delivered")
        case .read:
            print("read")
        }

        // Using if-let with non-optional enum
        let currentStatus = status
        if case .pending = currentStatus {
            print("is pending")
        }
    }

    // MARK: - Explicit Initializer Call
    public func explicitInit() {
        // .init() instead of direct init
        let string1 = String.init("hello")
        let array1 = Array<Int>.init()
        let dict1 = Dictionary<String, Int>.init()

        print(string1, array1, dict1)
    }

    // MARK: - Identical Branch Bodies
    public func identicalBranches() {
        let x = 5

        if x > 3 {
            print("branch a")
        } else {
            print("branch a") // same as if branch
        }

        switch x {
        case 1:
            print("value")
        case 2:
            print("value") // same as case 1
        default:
            print("default")
        }
    }

    // MARK: - Boolean Literal Comparison
    public func booleanComparisons() {
        let flag = true

        // Comparing to boolean literal
        if flag == true {
            print("true")
        }

        if flag == false {
            print("false")
        }

        if flag != true {
            print("not true")
        }
    }
}
