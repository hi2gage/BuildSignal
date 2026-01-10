// MARK: - ConflictResolver - Operator & Expression Warnings

import Foundation

public class ConflictResolver {
    public init() {}

    // MARK: - Operator Precedence Warnings
    public func operatorPrecedence() {
        let a = 1
        let b = 2
        let c = 3

        // Unclear precedence
        let result1 = a + b * c // multiplication first
        let result2 = a << b + c // shift vs add
        let result3 = a & b | c // bitwise and vs or

        // Should use parentheses
        let result4 = a + b << 1
        let result5 = a | b & c

        print(result1, result2, result3, result4, result5)
    }

    // MARK: - Ternary Operator Nesting
    public func nestedTernary() {
        let a = true
        let b = false
        let c = true

        // Nested ternary - hard to read
        let result1 = a ? (b ? 1 : 2) : (c ? 3 : 4)
        let result2 = a ? b ? 1 : 2 : c ? 3 : 4 // even worse
        let result3 = a ? b ? c ? 1 : 2 : 3 : 4 // triple nested

        print(result1, result2, result3)
    }

    // MARK: - Nil Coalescing Chain
    public func nilCoalescingChain() {
        let opt1: String? = nil
        let opt2: String? = nil
        let opt3: String? = nil
        let opt4: String? = "value"

        // Long nil coalescing chain
        let result = opt1 ?? opt2 ?? opt3 ?? opt4 ?? "default"

        print(result)
    }

    // MARK: - Complex Boolean Expression
    public func complexBoolean() {
        let a = true
        let b = false
        let c = true
        let d = false
        let e = true

        // Complex boolean - hard to understand
        if a && b || c && !d || e && a && !b {
            print("complex condition met")
        }

        // Negative conditions
        if !(!a || !b) {
            print("double negative")
        }

        // De Morgan's law violations
        if !(a && b) {
            print("could be !a || !b")
        }
    }

    // MARK: - Assignment in Condition
    public func assignmentInCondition() {
        var x = 0

        // Assignment that looks like comparison
        if (x = 5) == () { // assigns, doesn't compare
            print("assigned")
        }

        print(x)
    }

    // MARK: - Increment/Decrement Side Effects
    public func sideEffects() {
        var counter = 0

        // Multiple mutations in expression
        let array = [counter, counter + 1, counter + 2]
        counter += 1

        print(array, counter)
    }

    // MARK: - Range Expression Warnings
    public func rangeExpressions() {
        // Negative range
        let range1 = 5..<3 // empty range
        let range2 = 10...5 // invalid range (would crash)

        // Zero-length range
        let range3 = 0..<0

        print(range1.isEmpty, range3.isEmpty)
        _ = range2
    }
}
