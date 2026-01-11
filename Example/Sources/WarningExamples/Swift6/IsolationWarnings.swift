// MARK: - Isolation Warnings - Swift 6 Strict Mode

import Foundation

// Nonisolated access to isolated state
public actor IsolatedActor1 {
    public var state: Int = 0
    public var data: [String] = []

    public init() {}

    nonisolated public func getNonisolated() {
        // Accessing isolated state from nonisolated - would be error in Swift 6
        // let _ = state // Can't access
    }

    public func isolated() {
        state += 1
        data.append("item")
    }
}

public actor IsolatedActor2 {
    public var counter: Int = 0
    public var items: [Int] = []

    public init() {}

    // Returning non-Sendable from actor
    public func getItems() -> [Int] {
        items
    }

    public func addItem(_ item: Int) {
        items.append(item)
        counter += 1
    }
}

// Shared mutable state that should be actor-isolated
public final class SharedMutableState1 {
    public static var shared = SharedMutableState1()
    public var value: Int = 0

    public init() {}

    public func increment() {
        value += 1 // Not thread-safe
    }
}

public final class SharedMutableState2 {
    public static var shared = SharedMutableState2()
    public var items: [String] = []

    public init() {}

    public func add(_ item: String) {
        items.append(item) // Not thread-safe
    }
}

public final class SharedMutableState3 {
    public static let shared = SharedMutableState3()
    public var cache: [String: Any] = [:]

    public init() {}

    public func store(_ key: String, value: Any) {
        cache[key] = value // Not thread-safe
    }
}

// Accessing shared state from multiple isolation domains
public func accessSharedState1() async {
    SharedMutableState1.shared.increment()
    SharedMutableState2.shared.add("item")
    SharedMutableState3.shared.store("key", value: 1)
}

public func accessSharedState2() {
    Task {
        SharedMutableState1.shared.increment() // Race
    }
    Task {
        SharedMutableState1.shared.increment() // Race
    }
}

// Mixing isolation domains
@MainActor
public class MainActorIsolated1 {
    public var uiState: String = ""

    public init() {}

    public func updateUI() {
        uiState = "updated"
    }
}

public class NonIsolated1 {
    public var data: String = ""

    public init() {}

    public func process() async {
        let ui = await MainActorIsolated1()
        await ui.updateUI() // Crossing isolation boundary
    }
}

// Protocol conformance with isolation mismatch
public protocol NonIsolatedProtocol {
    func doWork()
}

@MainActor
public class MainActorConformance1: NonIsolatedProtocol {
    public init() {}

    // Implementing non-isolated protocol in MainActor class
    nonisolated public func doWork() {
        print("work")
    }
}

@MainActor
public class MainActorConformance2: NonIsolatedProtocol {
    public var state: Int = 0

    public init() {}

    nonisolated public func doWork() {
        // Can't access state here
        print("work")
    }
}

// Non-Sendable class for isolation tests
public class IsolationTestData {
    public var value: Int = 0
    public init() {}
}

// Closure isolation issues
public func closureIsolation1() {
    let data = IsolationTestData()

    // Closure inheriting no isolation but capturing non-Sendable
    let closure = {
        print(data.value)
    }

    Task {
        closure() // Calling from Task
    }
}

public func closureIsolation2() {
    var counter = 0

    let increment = {
        counter += 1 // Capturing mutable local
    }

    Task {
        increment() // Race condition
    }

    increment()
}

// Actor inheritance issues
public actor BaseActor {
    public var baseValue: Int = 0

    public init() {}

    public func baseMethod() {
        baseValue += 1
    }
}

// Actors can't inherit from other actors or classes
// This pattern shows isolation mismatches

// Global actor with mutable state
@globalActor
public actor CustomActor1 {
    public static let shared = CustomActor1()
    public var globalState: Int = 0
}

@CustomActor1
public var customActorGlobal1: Int = 0

@CustomActor1
public var customActorGlobal2: String = ""

@CustomActor1
public func customActorFunction1() {
    customActorGlobal1 += 1
    customActorGlobal2 = "updated"
}

// Accessing global actor state from non-isolated
public func accessCustomActorState() async {
    await customActorFunction1()
}

// Sendable conformance issues with stored properties
public struct SendableWithNonSendable: Sendable { // Warning: contains non-Sendable
    public let value: Int
    // If we had: public let data: NonSendableData // Would be error

    public init(value: Int) {
        self.value = value
    }
}

// Preconcurrency imports pattern
// @preconcurrency import SomeModule // Would suppress warnings from that module

// Async property access
public actor PropertyActor {
    public var asyncProperty: Int = 0

    public init() {}

    public var computedAsync: Int {
        asyncProperty * 2
    }
}

public func accessAsyncProperty() async {
    let actor = PropertyActor()
    let _ = await actor.asyncProperty
    let _ = await actor.computedAsync
}

// Isolated parameters
public func isolatedParameter(
    _ actor: isolated IsolatedActor1
) {
    // Can access actor state directly here
    actor.state += 1
}

public func callIsolatedParameter() async {
    let actor = IsolatedActor1()
    await isolatedParameter(actor)
}
