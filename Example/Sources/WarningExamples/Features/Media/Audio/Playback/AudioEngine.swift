// MARK: - AudioEngine - More Warning Varieties

import Foundation

public class AudioEngine {
    public init() {}

    // MARK: - Force Try Warnings
    public func riskyOperations() {
        // Force try - potential crash
        let data1 = try! JSONEncoder().encode(["key": "value"])
        let data2 = try! JSONEncoder().encode([1, 2, 3])

        print(data1.count, data2.count)
    }

    // MARK: - Implicitly Unwrapped Optional Overuse
    public var audioBuffer: Data!
    public var sampleRate: Int!
    public var channels: Int!
    public var bitDepth: Int!
    public var format: String!

    // MARK: - Negative Array Index Potential
    public func arrayAccess() {
        let array = [1, 2, 3, 4, 5]
        let index = -1

        // This would crash but shows the pattern
        if index >= 0 && index < array.count {
            print(array[index])
        }
    }

    // MARK: - Switch with Single Case
    public func singleCaseSwitch() {
        let value = 1

        // Switch with only one meaningful case
        switch value {
        case 1:
            print("one")
        default:
            break
        }

        // Could just be an if statement
        switch value {
        case let x where x > 0:
            print("positive: \(x)")
        default:
            break
        }
    }

    // MARK: - Redundant Break
    public func redundantBreaks() {
        let value = 1

        switch value {
        case 1:
            print("one")
            break // redundant in Swift
        case 2:
            print("two")
            break // redundant
        default:
            print("other")
            break // redundant
        }
    }

    // MARK: - Collection Count vs isEmpty
    public func collectionChecks() {
        let array: [Int] = []
        let dict: [String: Int] = [:]
        let set: Set<Int> = []

        // Using count == 0 instead of isEmpty
        if array.count == 0 {
            print("array empty")
        }

        if dict.count == 0 {
            print("dict empty")
        }

        if set.count == 0 {
            print("set empty")
        }

        // count > 0 instead of !isEmpty
        if array.count > 0 {
            print("not empty")
        }
    }

    // MARK: - Sequence Iteration Warnings
    public func iterationWarnings() {
        let array = [1, 2, 3, 4, 5]

        // Using indices when enumerated would be cleaner
        for i in 0..<array.count {
            print(array[i])
        }

        // Using indices property
        for i in array.indices {
            print(array[i])
        }
    }

    // MARK: - String Concatenation in Loop
    public func stringInLoop() {
        var result = ""

        // Inefficient string concatenation in loop
        for i in 0..<100 {
            result += String(i)
            result += ", "
        }

        print(result)
    }
}
