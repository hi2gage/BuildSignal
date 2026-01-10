// MARK: - ReportGenerator - More Warning Types

import Foundation

public class ReportGenerator {
    public init() {}

    // MARK: - Floating Point Equality Comparison
    public func floatComparisons() {
        let float1: Double = 0.1 + 0.2
        let float2: Double = 0.3

        // Comparing floats with == (potentially problematic)
        if float1 == float2 {
            print("equal")
        }

        if float1 == 0.3 {
            print("equal to literal")
        }

        let f1: Float = 1.0
        let f2: Float = 1.0
        if f1 == f2 {
            print("floats equal")
        }
    }

    // MARK: - Redundant Optional Unwrapping
    public func redundantUnwrapping() {
        let nonOptional = "definitely here"

        // Unnecessary nil coalescing on non-optional
        let result1 = nonOptional ?? "default"
        let result2 = "literal" ?? "default"
        let result3 = String("constructed") ?? "default"

        print(result1, result2, result3)

        // Unnecessary optional binding
        if let value = Optional.some("always succeeds") {
            print(value)
        }
    }

    // MARK: - Large Tuple Warning Potential
    public func largeTuples() {
        // Large tuples can be unwieldy
        let tuple1 = (1, 2, 3, 4, 5, 6, 7, 8)
        let tuple2 = ("a", "b", "c", "d", "e", "f", "g", "h")
        let tuple3 = (1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0)

        print(tuple1.0, tuple2.0, tuple3.0)
    }

    // MARK: - Selector Warnings
    #if canImport(ObjectiveC)
    @objc public func selectorTarget() {}

    public func selectorUsage() {
        // Selector with string literal
        let sel1 = Selector("selectorTarget")
        let sel2 = Selector(("dynamicSelector"))

        print(sel1, sel2)
    }
    #endif

    // MARK: - Key Path Type Inference
    public func keyPathUsage() {
        struct Person {
            var name: String
            var age: Int
        }

        let people = [Person(name: "John", age: 30), Person(name: "Jane", age: 25)]

        // Key path expressions
        let names = people.map(\.name)
        let ages = people.map(\.age)

        print(names, ages)
    }

    // MARK: - Empty Collection Literal
    public func emptyCollections() {
        // Type could be inferred differently
        let emptyArray: [Int] = []
        let emptyDict: [String: Int] = [:]
        let emptySet: Set<Int> = []

        print(emptyArray.count, emptyDict.count, emptySet.count)
    }
}
