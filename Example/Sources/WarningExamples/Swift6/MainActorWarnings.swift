// MARK: - MainActor Warnings - Swift 6 UI Concurrency

import Foundation

// Classes that should be MainActor but aren't
public class ViewControllerLike {
    public var title: String = ""
    public var isVisible: Bool = false
    public var subviews: [Any] = []

    public init() {}

    public func viewDidLoad() {
        title = "Loaded"
        isVisible = true
    }

    public func updateSubviews() {
        subviews.append("subview")
    }
}

public class ViewModelWithUIAccess {
    public var displayText: String = ""
    public var isLoading: Bool = false
    public var errorMessage: String?

    public init() {}

    @MainActor
    public func updateDisplay(_ text: String) {
        displayText = text
    }

    // Non-MainActor calling MainActor method
    public func load() async {
        isLoading = true
        await updateDisplay("Loading...")
        isLoading = false
    }
}

// MainActor property access from non-MainActor
@MainActor
public var globalUIState: String = ""

@MainActor
public var globalViewData: [String] = []

@MainActor
public var globalIsLoading: Bool = false

public func accessGlobalUI1() async {
    await MainActor.run {
        globalUIState = "updated"
    }
}

public func accessGlobalUI2() async {
    await MainActor.run {
        globalViewData.append("item")
    }
}

public func accessGlobalUI3() async {
    await MainActor.run {
        globalIsLoading = true
    }
}

// Mixed MainActor and non-MainActor methods
public class MixedIsolation {
    @MainActor public var uiProperty: String = ""
    public var regularProperty: Int = 0

    public init() {}

    @MainActor
    public func uiMethod() {
        uiProperty = "updated"
    }

    public func regularMethod() {
        regularProperty += 1
    }

    // Mixing isolation
    public func mixedMethod() async {
        regularProperty += 1
        await uiMethod() // Crossing isolation boundary
    }
}

// Protocol with MainActor requirements
@MainActor
public protocol UIUpdatable {
    var displayValue: String { get set }
    func refresh()
}

// Implementing MainActor protocol in non-MainActor class
public class DataProvider: UIUpdatable {
    public var displayValue: String = ""
    public var internalData: [String] = []

    public init() {}

    public func refresh() {
        displayValue = "refreshed"
    }

    public func loadData() {
        internalData.append("data")
    }
}

// Closures crossing MainActor boundary
@MainActor
public class UIManager {
    public var handlers: [() -> Void] = []
    public var state: String = ""

    public init() {}

    public func addHandler(_ handler: @escaping () -> Void) {
        handlers.append(handler)
    }

    public func executeHandlers() {
        for handler in handlers {
            handler()
        }
    }
}

public func setupHandlers() async {
    let manager = await UIManager()

    // Non-MainActor closure passed to MainActor
    await manager.addHandler {
        print("Handler executed")
    }

    await manager.addHandler {
        print("Another handler")
    }
}

// Task creation from MainActor context
@MainActor
public class AsyncUIController {
    public var result: String = ""
    public var isProcessing: Bool = false

    public init() {}

    public func startBackgroundWork() {
        isProcessing = true

        // Creating Task from MainActor - may inherit isolation
        Task {
            try? await Task.sleep(nanoseconds: 1000)
            self.result = "done" // Accessing MainActor from Task
            self.isProcessing = false
        }
    }

    public func startDetachedWork() {
        Task.detached {
            // Detached task accessing MainActor
            await self.updateResult("detached result")
        }
    }

    public func updateResult(_ value: String) {
        result = value
    }
}

// Async sequences with MainActor
@MainActor
public class StreamConsumer {
    public var values: [Int] = []

    public init() {}

    public func consume(_ stream: AsyncStream<Int>) async {
        for await value in stream {
            values.append(value) // MainActor access in async iteration
        }
    }
}

public func createStream() -> AsyncStream<Int> {
    AsyncStream { continuation in
        continuation.yield(1)
        continuation.yield(2)
        continuation.finish()
    }
}

public func testStreamConsumer() async {
    let consumer = await StreamConsumer()
    let stream = createStream()
    await consumer.consume(stream)
}

// Combine-like patterns with MainActor
@MainActor
public class Publisher {
    public var subscribers: [(String) -> Void] = []
    public var lastValue: String = ""

    public init() {}

    public func subscribe(_ handler: @escaping (String) -> Void) {
        subscribers.append(handler)
    }

    public func publish(_ value: String) {
        lastValue = value
        for subscriber in subscribers {
            subscriber(value)
        }
    }
}

public func setupPublisher() async {
    let publisher = await Publisher()

    await publisher.subscribe { value in
        print("Received: \(value)")
    }

    await publisher.publish("test")
}
