// MARK: - Actor Isolation Warnings - Swift 6 Concurrency

import Foundation

// Actor with isolation violations
public actor IsolatedCounter {
    public var count: Int = 0
    public var name: String = "counter"
    public var history: [Int] = []

    public init() {}

    public func increment() { count += 1 }
    public func decrement() { count -= 1 }
    public func getCount() -> Int { count }
}

public actor IsolatedStorage {
    public var items: [String: Any] = [:]
    public var metadata: [String: String] = [:]

    public init() {}

    public func store(_ key: String, value: Any) { items[key] = value }
    public func retrieve(_ key: String) -> Any? { items[key] }
}

public actor IsolatedQueue {
    public var queue: [String] = []
    public var processing: Bool = false

    public init() {}

    public func enqueue(_ item: String) { queue.append(item) }
    public func dequeue() -> String? { queue.isEmpty ? nil : queue.removeFirst() }
}

// Classes that access actor state incorrectly
public class CounterClient {
    public let counter = IsolatedCounter()

    public init() {}

    // Synchronous access to actor - requires await
    public func badAccess1() {
        Task {
            // These should generate isolation warnings
            let _ = await counter.count
            let _ = await counter.name
        }
    }

    // Nonisolated context accessing isolated state
    nonisolated public func badAccess2() async {
        let c = IsolatedCounter()
        await c.increment()
        let _ = await c.getCount()
    }
}

public class StorageClient {
    public let storage = IsolatedStorage()

    public init() {}

    public func accessStorage() async {
        await storage.store("key1", value: "value1")
        await storage.store("key2", value: 123)
        let _ = await storage.retrieve("key1")
        let _ = await storage.retrieve("key2")
    }
}

public class QueueClient {
    public let queue = IsolatedQueue()

    public init() {}

    public func processQueue() async {
        await queue.enqueue("item1")
        await queue.enqueue("item2")
        let _ = await queue.dequeue()
    }
}

// Global actor isolation issues
@globalActor
public actor CustomGlobalActor {
    public static let shared = CustomGlobalActor()
}

@CustomGlobalActor
public class GloballyIsolated {
    public var state: Int = 0
    public var data: [String] = []

    public init() {}

    public func update() {
        state += 1
        data.append("item")
    }
}

// Accessing globally isolated from non-isolated context
public func accessGloballyIsolated1() async {
    let obj = await GloballyIsolated()
    await obj.update()
}

public func accessGloballyIsolated2() async {
    let obj = await GloballyIsolated()
    let _ = await obj.state
}

public func accessGloballyIsolated3() async {
    let obj = await GloballyIsolated()
    let _ = await obj.data
}

// MainActor isolation
@MainActor
public class MainActorClass {
    public var uiState: String = ""
    public var viewData: [String] = []
    public var isLoading: Bool = false

    public init() {}

    public func updateUI() {
        uiState = "updated"
        isLoading = false
    }

    public func loadData() {
        isLoading = true
        viewData = ["item1", "item2"]
    }
}

// Non-MainActor accessing MainActor
public func accessMainActor1() async {
    let obj = await MainActorClass()
    await obj.updateUI()
}

public func accessMainActor2() async {
    let obj = await MainActorClass()
    await obj.loadData()
}

public func accessMainActor3() async {
    let obj = await MainActorClass()
    let _ = await obj.uiState
    let _ = await obj.viewData
}

// Actor reentrancy issues
public actor ReentrantActor {
    public var value: Int = 0

    public init() {}

    public func updateWithSuspension() async {
        value = 1
        try? await Task.sleep(nanoseconds: 1000)
        value = 2 // May not be 1 due to reentrancy
    }

    public func chainedCall() async {
        await updateWithSuspension()
        value = 3 // Reentrancy concern
    }
}

public func reentrancyTest1() async {
    let actor = ReentrantActor()
    await actor.updateWithSuspension()
    await actor.chainedCall()
}

public func reentrancyTest2() async {
    let actor = ReentrantActor()
    async let a = actor.updateWithSuspension()
    async let b = actor.chainedCall()
    _ = await (a, b)
}

// Closure capturing actor-isolated self
public actor ClosureCapturingActor {
    public var data: [String] = []

    public init() {}

    public func setupCallback() {
        // Capturing actor-isolated self in non-isolated closure
        let callback = {
            self.data.append("item") // Implicit self capture in actor
        }
        callback()
    }

    public func anotherCallback() {
        let process = {
            print(self.data) // Capturing self
        }
        process()
    }
}
