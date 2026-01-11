// MARK: - Async/Await Warnings - Swift 6 Concurrency

import Foundation

// Async functions with potential issues
public class AsyncService {
    public var cache: [String: Any] = [:]
    public var isConnected: Bool = false

    public init() {}

    // Async function that could be sync
    public func simpleAsyncThatCouldBeSync() async -> Int {
        return 42 // No actual async work
    }

    public func anotherUnnecessaryAsync() async -> String {
        return "hello" // No suspension points
    }

    // Missing try with throwing async
    public func callThrowingAsync() async {
        do {
            try await throwingAsyncFunction()
        } catch {
            print(error)
        }
    }
}

public func throwingAsyncFunction() async throws -> Int {
    return 1
}

// Async let without await
public func asyncLetIssues1() async {
    async let value1 = computeValue1()
    async let value2 = computeValue2()

    // Should await both
    let _ = await value1
    let _ = await value2
}

public func asyncLetIssues2() async {
    async let a = computeValue1()
    async let b = computeValue2()
    async let c = computeValue3()

    let _ = await (a, b, c)
}

public func computeValue1() async -> Int { 1 }
public func computeValue2() async -> Int { 2 }
public func computeValue3() async -> Int { 3 }

// Task group issues
public func taskGroupWarnings1() async {
    await withTaskGroup(of: Int.self) { group in
        group.addTask { 1 }
        group.addTask { 2 }
        group.addTask { 3 }

        // Not consuming all results
        for await _ in group {
            break // Early exit
        }
    }
}

public func taskGroupWarnings2() async {
    await withTaskGroup(of: String.self) { group in
        group.addTask { "a" }
        group.addTask { "b" }
        // Group not fully consumed
    }
}

public func taskGroupWarnings3() async {
    await withThrowingTaskGroup(of: Int.self) { group in
        group.addTask { 1 }
        group.addTask { throw NSError(domain: "", code: 0) }

        do {
            for try await _ in group { }
        } catch {
            // Swallowing error
        }
    }
}

// Continuation issues
public func continuationWarnings1() async -> Int {
    await withCheckedContinuation { continuation in
        continuation.resume(returning: 42)
        // Potential double resume if not careful
    }
}

public func continuationWarnings2() async -> String {
    await withCheckedContinuation { continuation in
        DispatchQueue.global().async {
            continuation.resume(returning: "result")
        }
    }
}

public func continuationWarnings3() async throws -> Int {
    try await withCheckedThrowingContinuation { continuation in
        continuation.resume(returning: 1)
    }
}

// Unsafe continuation
public func unsafeContinuationWarnings1() async -> Int {
    await withUnsafeContinuation { continuation in
        continuation.resume(returning: 42) // Unsafe - no runtime checks
    }
}

public func unsafeContinuationWarnings2() async -> String {
    await withUnsafeContinuation { continuation in
        continuation.resume(returning: "unsafe")
    }
}

// Mixing sync and async incorrectly
public class MixedAsyncSync {
    public var value: Int = 0

    public init() {}

    public func syncMethod() {
        // Calling async from sync without Task
        // This would be an error, but we can show the pattern
        value = 1
    }

    public func asyncMethod() async {
        value = await computeValue1()
    }

    public func bridgeMethod() {
        Task {
            await asyncMethod() // Bridge from sync to async
        }
    }
}

// Async property issues
public class AsyncPropertyClass {
    public var regularProperty: Int = 0

    public init() {}

    // Computed async property
    public var asyncComputed: Int {
        get async {
            return await computeValue1()
        }
    }

    // Throwing async property
    public var throwingAsyncComputed: Int {
        get async throws {
            return try await throwingAsyncFunction()
        }
    }
}

public func accessAsyncProperties() async throws {
    let obj = AsyncPropertyClass()
    let _ = await obj.asyncComputed
    let _ = try await obj.throwingAsyncComputed
}

// Async sequence issues
public struct CustomAsyncSequence: AsyncSequence {
    public typealias Element = Int

    public init() {}

    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator()
    }

    public struct AsyncIterator: AsyncIteratorProtocol {
        var current = 0

        public mutating func next() async -> Int? {
            guard current < 5 else { return nil }
            current += 1
            return current
        }
    }
}

public func consumeAsyncSequence() async {
    let sequence = CustomAsyncSequence()
    for await value in sequence {
        print(value)
    }
}

// Cancellation handling
public func cancellationIssues1() async {
    // Not checking for cancellation
    for i in 0..<1000 {
        print(i)
        // Should check: try Task.checkCancellation()
    }
}

public func cancellationIssues2() async {
    // Ignoring cancellation state
    let _ = Task.isCancelled
    // Should handle cancellation
}

public func cancellationIssues3() async throws {
    try await withTaskCancellationHandler {
        try await Task.sleep(nanoseconds: 1_000_000)
    } onCancel: {
        print("Cancelled") // Non-async cancellation handler
    }
}

// Priority issues
public func priorityIssues() async {
    Task(priority: .background) {
        // Low priority task
        print("background")
    }

    Task(priority: .high) {
        // High priority task
        print("high")
    }

    Task(priority: .userInitiated) {
        // User initiated
        print("user")
    }
}
