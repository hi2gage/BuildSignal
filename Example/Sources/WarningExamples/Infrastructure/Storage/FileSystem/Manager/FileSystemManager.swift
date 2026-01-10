// MARK: - FileSystemManager - Error Handling Warnings

import Foundation

public class FileSystemManager {
    public init() {}

    // MARK: - Empty Catch Blocks
    public func emptyCatches() {
        do {
            try riskyOperation1()
        } catch {
            // Empty catch - swallowing errors
        }

        do {
            try riskyOperation2()
        } catch {
            // Another empty catch
        }

        do {
            try riskyOperation3()
        } catch _ {
            // Explicitly ignoring
        }
    }

    // MARK: - Catch Without Pattern
    public func broadCatch() {
        do {
            try riskyOperation1()
        } catch {
            print(error) // Generic error handling
        }
    }

    // MARK: - Try? Discarding Error Info
    public func tryOptional() {
        // Losing error information
        let result1 = try? riskyOperation1()
        let result2 = try? riskyOperation2()
        let result3 = try? riskyOperation3()

        print(result1 ?? "nil", result2 ?? "nil", result3 ?? "nil")
    }

    private func riskyOperation1() throws -> String {
        throw NSError(domain: "test", code: 1)
    }

    private func riskyOperation2() throws -> String {
        throw NSError(domain: "test", code: 2)
    }

    private func riskyOperation3() throws -> String {
        throw NSError(domain: "test", code: 3)
    }

    // MARK: - Redundant Do Block
    public func redundantDo() {
        do {
            // No throwing calls inside
            let x = 1 + 1
            print(x)
        }

        do {
            let y = "hello"
            print(y)
        }
    }

    // MARK: - Throwing in Defer
    public func throwInDefer() {
        defer {
            // Can't throw in defer, but can have issues
            let _ = try? riskyOperation1()
        }

        print("main body")
    }

    // MARK: - Multiple Returns with Cleanup
    public func multipleReturns() -> Int {
        defer {
            print("cleanup")
        }

        let condition = true
        if condition {
            return 1
        }

        if !condition {
            return 2
        }

        return 3 // might be unreachable
    }

    // MARK: - Guard vs If-Let
    public func guardVsIfLet() {
        let optional: String? = "value"

        // Using if-let when guard would be cleaner
        if let value = optional {
            print(value)
            // More code using value...
            print("still using \(value)")
        }

        // Nested if-lets
        let opt1: Int? = 1
        let opt2: Int? = 2

        if let v1 = opt1 {
            if let v2 = opt2 {
                print(v1 + v2)
            }
        }
    }
}
