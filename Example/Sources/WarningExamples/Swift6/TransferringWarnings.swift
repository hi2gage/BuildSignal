// MARK: - Transferring & Sending Warnings - Swift 6

import Foundation

// Classes that should use @unchecked Sendable but don't
public class ThreadSafeButNotSendable {
    private let lock = NSLock()
    private var _value: Int = 0

    public init() {}

    public var value: Int {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _value
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _value = newValue
        }
    }
}

public class AtomicCounter {
    private var _count: Int = 0
    private let lock = NSLock()

    public init() {}

    public func increment() {
        lock.lock()
        _count += 1
        lock.unlock()
    }

    public func get() -> Int {
        lock.lock()
        defer { lock.unlock() }
        return _count
    }
}

// Function parameters that should be sending
public func processData(_ data: NonSendableData) async {
    let actor = DataProcessor()
    await actor.process(data) // Should be sending parameter
}

public func processConfig(_ config: NonSendableConfig) async {
    let actor = ConfigManager()
    await actor.apply(config) // Should be sending parameter
}

public func processMultiple(_ data: NonSendableData, _ config: NonSendableConfig) async {
    let processor = DataProcessor()
    let manager = ConfigManager()
    await processor.process(data)
    await manager.apply(config)
}

// Return values that cross isolation
public actor ValueProducer {
    private var storage: NonSendableData = NonSendableData()

    public init() {}

    public func produce() -> NonSendableData {
        storage // Returning non-Sendable from actor
    }

    public func produceConfig() -> NonSendableConfig {
        NonSendableConfig() // Returning non-Sendable from actor
    }
}

public func consumeProduced() async {
    let producer = ValueProducer()
    let data = await producer.produce() // Receiving non-Sendable from actor
    print(data.value)

    let config = await producer.produceConfig()
    print(config.settings)
}

// Protocol with associated types that aren't Sendable
public protocol DataProviderProtocol {
    associatedtype DataType
    func provide() async -> DataType
}

public class ConcreteDataProvider: DataProviderProtocol {
    public typealias DataType = NonSendableData

    public init() {}

    public func provide() async -> NonSendableData {
        NonSendableData()
    }
}

// Generic functions with Sendable constraints
public func sendToActor<T>(_ value: T) async where T: Sendable {
    let actor = DataProcessor()
    print(value)
    _ = actor
}

public func sendNonSendableGeneric<T>(_ value: T) async {
    // T is not constrained to Sendable
    Task {
        print(value) // May capture non-Sendable
    }
}

// Closure types that should be @Sendable
public class ClosureHolder {
    public var completion: (() -> Void)?
    public var handlers: [() -> Void] = []
    public var asyncHandler: (() async -> Void)?

    public init() {}

    public func setCompletion(_ handler: @escaping () -> Void) {
        completion = handler
    }

    public func addHandler(_ handler: @escaping () -> Void) {
        handlers.append(handler)
    }

    public func executeInTask() {
        Task {
            completion?() // Non-Sendable closure in Task
        }
    }
}

// Sendable closures with captures
public func sendableClosureWithCapture() {
    var mutableValue = 0

    let sendableClosure: @Sendable () -> Void = {
        print(mutableValue) // Capturing mutable in @Sendable
    }

    mutableValue += 1
    sendableClosure()
}

public func multipleSendableClosures() {
    var counter = 0
    let data = NonSendableData()

    let closure1: @Sendable () -> Void = {
        print(counter) // Capturing mutable
    }

    let closure2: @Sendable () -> Void = {
        print(data.value) // Capturing non-Sendable
    }

    closure1()
    closure2()
    counter += 1
}

// Actor methods with non-Sendable parameters
public actor MethodReceiver {
    public init() {}

    public func receive(_ data: NonSendableData) {
        print(data.value)
    }

    public func receiveMultiple(_ a: NonSendableData, _ b: NonSendableConfig) {
        print(a.value, b.settings)
    }

    public func receiveArray(_ items: [NonSendableData]) {
        print(items.count)
    }

    public func receiveDictionary(_ dict: [String: NonSendableData]) {
        print(dict.keys)
    }

    public func receiveClosure(_ handler: () -> Void) {
        handler()
    }
}

public func callMethodReceiver() async {
    let receiver = MethodReceiver()

    await receiver.receive(NonSendableData())
    await receiver.receiveMultiple(NonSendableData(), NonSendableConfig())
    await receiver.receiveArray([NonSendableData(), NonSendableData()])
    await receiver.receiveDictionary(["a": NonSendableData()])
    await receiver.receiveClosure { print("closure") }
}

// Task.detached with non-Sendable captures
public func detachedTaskCaptures() {
    let data = NonSendableData()
    let config = NonSendableConfig()

    Task.detached {
        print(data.value) // Non-Sendable in detached
    }

    Task.detached {
        print(config.settings) // Non-Sendable in detached
    }

    Task.detached {
        print(data.value, config.settings) // Multiple non-Sendable
    }
}

// TaskGroup with non-Sendable
public func taskGroupNonSendable() async {
    let data = NonSendableData()

    await withTaskGroup(of: Void.self) { group in
        group.addTask {
            print(data.value) // Non-Sendable in task group
        }
        group.addTask {
            print(data.name) // Non-Sendable in task group
        }
    }
}
