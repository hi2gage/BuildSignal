// MARK: - Data Race Warnings - Swift 6 Safety

import Foundation

// Mutable shared state without synchronization
public class UnsafeSharedState {
    public static var sharedCounter: Int = 0
    public static var sharedData: [String] = []
    public static var sharedDict: [String: Any] = [:]

    public init() {}

    public func unsafeIncrement() {
        UnsafeSharedState.sharedCounter += 1 // Data race
    }

    public func unsafeAppend(_ item: String) {
        UnsafeSharedState.sharedData.append(item) // Data race
    }

    public func unsafeStore(_ key: String, value: Any) {
        UnsafeSharedState.sharedDict[key] = value // Data race
    }
}

// Class with mutable state accessed concurrently
public class ConcurrentAccessClass {
    public var value: Int = 0
    public var items: [String] = []
    public var isActive: Bool = false

    public init() {}

    public func modifyFromMultipleTasks() {
        Task {
            self.value += 1 // Potential race
        }
        Task {
            self.value += 2 // Potential race
        }
    }

    public func appendFromMultipleTasks() {
        Task {
            self.items.append("a") // Potential race
        }
        Task {
            self.items.append("b") // Potential race
        }
    }
}

// Global mutable state
public var globalMutableInt: Int = 0
public var globalMutableArray: [String] = []
public var globalMutableDict: [String: Int] = [:]
public var globalMutableBool: Bool = false
public var globalMutableOptional: String?

public func modifyGlobalState1() {
    Task {
        globalMutableInt += 1 // Race on global
    }
}

public func modifyGlobalState2() {
    Task {
        globalMutableArray.append("item") // Race on global
    }
}

public func modifyGlobalState3() {
    Task {
        globalMutableDict["key"] = 1 // Race on global
    }
}

public func modifyGlobalState4() {
    Task {
        globalMutableBool = true // Race on global
    }
}

public func modifyGlobalState5() {
    Task {
        globalMutableOptional = "value" // Race on global
    }
}

// Struct with reference semantics via class property
public struct StructWithClassProperty {
    public var classProperty: NonSendableData = NonSendableData()

    public init() {}

    public mutating func modify() {
        classProperty.value += 1
    }
}

public func structWithClassWarning() {
    var s = StructWithClassProperty()
    Task {
        s.modify() // Capturing mutable struct
    }
}

// Escaping closures with mutable capture
public class EscapingClosureIssues {
    public var handlers: [() -> Void] = []

    public init() {}

    public func addHandler() {
        var localValue = 0

        handlers.append {
            localValue += 1 // Capturing mutable local in escaping closure
            print(localValue)
        }

        handlers.append {
            localValue += 2 // Multiple closures capture same mutable
            print(localValue)
        }
    }

    public func anotherEscaping() {
        var counter = 0
        var name = "initial"

        let handler: () -> Void = {
            counter += 1
            name = "modified"
            print(counter, name)
        }

        handlers.append(handler)
    }
}

// Lazy var in concurrent context
public class LazyVarConcurrency {
    public lazy var lazyValue: Int = {
        print("Computing lazy value")
        return 42
    }()

    public lazy var anotherLazy: String = {
        "hello"
    }()

    public init() {}

    public func accessLazyConcurrently() {
        Task {
            print(self.lazyValue) // Lazy var access from Task
        }
        Task {
            print(self.lazyValue) // Race on lazy initialization
        }
    }
}

// inout parameters with concurrency
public func inoutWithTask(_ value: inout Int) {
    let captured = value
    Task {
        print(captured) // Can't use inout in Task directly
    }
    value = captured + 1
}

public func multipleInout(_ a: inout Int, _ b: inout String) {
    let capturedA = a
    let capturedB = b
    Task {
        print(capturedA, capturedB)
    }
    a += 1
    b += "x"
}

// Dispatch queue mixing with async
public class DispatchAndAsync {
    public var value: Int = 0
    private let queue = DispatchQueue(label: "test")

    public init() {}

    public func mixDispatchAndAsync() async {
        queue.async {
            self.value += 1 // Mixing dispatch and async
        }

        await withCheckedContinuation { continuation in
            queue.async {
                self.value += 1
                continuation.resume()
            }
        }
    }

    public func dispatchFromAsync() async {
        queue.sync {
            self.value = 10 // sync on queue from async
        }
    }
}

// Unsafe bit patterns
public class UnsafeBitCastWarnings {
    public init() {}

    public func unsafeCasts() {
        let int: Int = 42
        let _ = unsafeBitCast(int, to: UInt.self) // Unsafe

        let ptr = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        ptr.pointee = 42
        let _ = unsafeBitCast(ptr, to: Int.self) // Very unsafe
        ptr.deallocate()
    }
}

// Unowned and weak in concurrent context
public class WeakUnownedConcurrency {
    public var callback: (() -> Void)?

    public init() {}

    public func setupWithWeak() {
        Task { [weak self] in
            self?.callback?() // Weak self in Task
        }
    }

    public func setupWithUnowned() {
        Task { [unowned self] in
            self.callback?() // Unowned self in Task - dangerous
        }
    }
}
