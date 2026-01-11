// MARK: - Sendable Violations - Swift 6 Concurrency Warnings

import Foundation

// Non-Sendable classes used across actor boundaries
public class NonSendableData {
    public var value: Int = 0
    public var name: String = ""
    public var items: [String] = []
    public init() {}
}

public class NonSendableConfig {
    public var settings: [String: Any] = [:]
    public var callback: (() -> Void)?
    public init() {}
}

public class NonSendableState {
    public var count: Int = 0
    public var isActive: Bool = false
    public init() {}
}

public class NonSendableContainer {
    public var data: NonSendableData = NonSendableData()
    public var config: NonSendableConfig = NonSendableConfig()
    public init() {}
}

public class NonSendableCache {
    public var storage: [String: Any] = [:]
    public init() {}
}

public class NonSendableLogger {
    public var logs: [String] = []
    public init() {}
}

public class NonSendableMetrics {
    public var values: [Double] = []
    public init() {}
}

public class NonSendableSession {
    public var token: String?
    public var user: String?
    public init() {}
}

// Actors that receive non-Sendable types
public actor DataProcessor {
    public init() {}
    public func process(_ data: NonSendableData) { print(data.value) }
    public func configure(_ config: NonSendableConfig) { print(config.settings) }
    public func updateState(_ state: NonSendableState) { print(state.count) }
}

public actor ConfigManager {
    public init() {}
    public func apply(_ config: NonSendableConfig) { print(config.settings) }
    public func store(_ container: NonSendableContainer) { print(container.data) }
}

public actor CacheActor2 {
    public init() {}
    public func cache(_ item: NonSendableCache) { print(item.storage) }
    public func log(_ logger: NonSendableLogger) { print(logger.logs) }
}

public actor MetricsActor {
    public init() {}
    public func record(_ metrics: NonSendableMetrics) { print(metrics.values) }
    public func session(_ session: NonSendableSession) { print(session.token ?? "") }
}

// Functions that create Sendable violations
public func sendableViolation1() async {
    let actor = DataProcessor()
    let data = NonSendableData()
    await actor.process(data) // Non-Sendable crossing actor boundary
}

public func sendableViolation2() async {
    let actor = DataProcessor()
    let config = NonSendableConfig()
    await actor.configure(config) // Non-Sendable crossing actor boundary
}

public func sendableViolation3() async {
    let actor = DataProcessor()
    let state = NonSendableState()
    await actor.updateState(state) // Non-Sendable crossing actor boundary
}

public func sendableViolation4() async {
    let actor = ConfigManager()
    let config = NonSendableConfig()
    await actor.apply(config) // Non-Sendable crossing actor boundary
}

public func sendableViolation5() async {
    let actor = ConfigManager()
    let container = NonSendableContainer()
    await actor.store(container) // Non-Sendable crossing actor boundary
}

public func sendableViolation6() async {
    let actor = CacheActor2()
    let cache = NonSendableCache()
    await actor.cache(cache) // Non-Sendable crossing actor boundary
}

public func sendableViolation7() async {
    let actor = CacheActor2()
    let logger = NonSendableLogger()
    await actor.log(logger) // Non-Sendable crossing actor boundary
}

public func sendableViolation8() async {
    let actor = MetricsActor()
    let metrics = NonSendableMetrics()
    await actor.record(metrics) // Non-Sendable crossing actor boundary
}

public func sendableViolation9() async {
    let actor = MetricsActor()
    let session = NonSendableSession()
    await actor.session(session) // Non-Sendable crossing actor boundary
}

public func sendableViolation10() async {
    let actor = DataProcessor()
    let data1 = NonSendableData()
    let data2 = NonSendableData()
    await actor.process(data1)
    await actor.process(data2)
}

// Task capturing non-Sendable
public func taskCapture1() {
    let data = NonSendableData()
    Task {
        print(data.value) // Capturing non-Sendable in Task
    }
}

public func taskCapture2() {
    let config = NonSendableConfig()
    Task {
        print(config.settings) // Capturing non-Sendable in Task
    }
}

public func taskCapture3() {
    let state = NonSendableState()
    Task {
        print(state.count) // Capturing non-Sendable in Task
    }
}

public func taskCapture4() {
    let container = NonSendableContainer()
    Task {
        print(container.data) // Capturing non-Sendable in Task
    }
}

public func taskCapture5() {
    let cache = NonSendableCache()
    Task {
        print(cache.storage) // Capturing non-Sendable in Task
    }
}

public func taskCapture6() {
    let logger = NonSendableLogger()
    Task.detached {
        print(logger.logs) // Capturing non-Sendable in detached Task
    }
}

public func taskCapture7() {
    let metrics = NonSendableMetrics()
    Task.detached {
        print(metrics.values) // Capturing non-Sendable in detached Task
    }
}

public func taskCapture8() {
    let session = NonSendableSession()
    Task.detached {
        print(session.token ?? "") // Capturing non-Sendable in detached Task
    }
}

// Multiple captures in single task
public func multiCapture1() {
    let data = NonSendableData()
    let config = NonSendableConfig()
    Task {
        print(data.value, config.settings)
    }
}

public func multiCapture2() {
    let state = NonSendableState()
    let container = NonSendableContainer()
    Task {
        print(state.count, container.data)
    }
}

public func multiCapture3() {
    let cache = NonSendableCache()
    let logger = NonSendableLogger()
    let metrics = NonSendableMetrics()
    Task {
        print(cache.storage, logger.logs, metrics.values)
    }
}
