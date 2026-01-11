// MARK: - Type Inference Warnings

import Foundation

// Complex type inference that might be unclear
public class TypeInferenceIssues {
    public init() {}

    // Inferred as unexpected types
    public func unexpectedInference() {
        // Inferred as ()
        let void1 = print("hello")
        let void2 = print("world")

        // Inferred as optional
        let dict: [String: Int] = ["a": 1]
        let value = dict["b"] // Optional<Int>

        // Inferred closure types
        let closure1 = { 42 } // () -> Int
        let closure2 = { $0 + 1 } // Needs context

        // Tuple inference
        let tuple1 = (1, "hello") // (Int, String)
        let tuple2 = (1, 2, 3) // (Int, Int, Int)

        _ = (void1, void2, value, closure1, closure2, tuple1, tuple2)
    }

    // Generic type inference
    public func genericInference() {
        // Array literal type inference
        let ints = [1, 2, 3] // [Int]
        let doubles: [Double] = [1, 2, 3] // [Double]
        let mixed: [Any] = [1, "two", 3.0] // [Any]

        // Dictionary inference
        let stringIntDict = ["a": 1, "b": 2] // [String: Int]
        let intStringDict = [1: "a", 2: "b"] // [Int: String]

        // Set inference
        let intSet: Set = [1, 2, 3] // Set<Int>
        let stringSet: Set = ["a", "b", "c"] // Set<String>

        _ = (ints, doubles, mixed, stringIntDict, intStringDict, intSet, stringSet)
    }

    // Result builder inference
    @resultBuilder
    public struct ArrayBuilder<T> {
        public static func buildBlock(_ components: T...) -> [T] {
            components
        }
    }

    @ArrayBuilder<Int>
    public func buildInts() -> [Int] {
        1
        2
        3
    }

    // Chained method inference
    public func chainedInference() {
        let result = [1, 2, 3, 4, 5]
            .filter { $0 > 2 }
            .map { $0 * 2 }
            .reduce(0, +)
        // result is Int

        let complex = ["a", "bb", "ccc"]
            .map { $0.count }
            .sorted()
            .reversed()
        // complex is ReversedCollection<[Int]>

        _ = (result, complex)
    }

    // Optional chaining inference
    public func optionalChainingInference() {
        struct Person {
            var name: String
            var address: Address?
        }

        struct Address {
            var street: String
            var city: City?
        }

        struct City {
            var name: String
            var country: String?
        }

        let person: Person? = Person(name: "Test", address: nil)

        // Deep optional chaining - inferred as String???
        let country = person?.address?.city?.country

        _ = country
    }

    // Ternary expression inference
    public func ternaryInference() {
        let condition = true

        // Same types
        let result1 = condition ? 1 : 2 // Int

        // Different types need common supertype
        let result2 = condition ? 1 : 2.0 // Double (Int promoted)

        // Optional vs non-optional
        let result3 = condition ? "hello" : nil // String?

        // Closure return types
        let result4 = condition ? { 1 } : { 2 } // () -> Int

        _ = (result1, result2, result3, result4)
    }

    // Nil coalescing inference
    public func nilCoalescingInference() {
        let optInt: Int? = nil
        let optString: String? = nil
        let optArray: [Int]? = nil

        let defaultedInt = optInt ?? 0 // Int
        let defaultedString = optString ?? "" // String
        let defaultedArray = optArray ?? [] // [Int]

        // Chained nil coalescing
        let opt1: Int? = nil
        let opt2: Int? = nil
        let opt3: Int? = 42
        let chained = opt1 ?? opt2 ?? opt3 ?? 0 // Int

        _ = (defaultedInt, defaultedString, defaultedArray, chained)
    }

    // Protocol type inference
    public func protocolInference() {
        // Existential inference
        let comparable: any Comparable = 42
        let hashable: any Hashable = "test"
        let codable: any Codable = ["a": 1]

        _ = (comparable, hashable, codable)
    }

    // Keypath inference
    public func keypathInference() {
        struct Example {
            var name: String
            var value: Int
        }

        let namePath = \Example.name // KeyPath<Example, String>
        let valuePath = \Example.value // KeyPath<Example, Int>

        let example = Example(name: "test", value: 42)
        let name = example[keyPath: namePath]
        let value = example[keyPath: valuePath]

        _ = (name, value)
    }

    // Metatype inference
    public func metatypeInference() {
        let intType = Int.self // Int.Type
        let stringType = String.self // String.Type

        let instance1 = intType.init(42)
        let instance2 = stringType.init("hello")

        _ = (instance1, instance2)
    }
}

// Function return type inference issues
public func inferredReturnType() {
    42 // Returns Int implicitly
}

public func complexInferredReturn() {
    let x = 1
    let y = 2
    x + y // Inferred return
}

public func voidInference() {
    print("no explicit return") // Returns ()
}

// Trailing closure inference
public func trailingClosureInference() {
    let numbers = [1, 2, 3]

    // Parameter and return type inferred
    _ = numbers.map { $0 * 2 }
    _ = numbers.filter { $0 > 1 }
    _ = numbers.reduce(0) { $0 + $1 }

    // Multiple trailing closures
    let dict = [1: "one", 2: "two"]
    _ = dict.mapValues { value in
        value.uppercased()
    }
}
