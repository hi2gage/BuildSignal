// MARK: - Memory Safety Warnings

import Foundation

// Overlapping access warnings
public class OverlappingAccess {
    public var value: Int = 0
    public var array: [Int] = [1, 2, 3, 4, 5]

    public init() {}

    // Overlapping read-write access
    public func overlappingModify() {
        // Modifying during iteration
        for i in 0..<array.count {
            if array[i] > 2 {
                array.append(array[i] * 2) // Modifying during access
            }
        }
    }

    // Multiple inout parameters that might alias
    public func swapValues(_ a: inout Int, _ b: inout Int) {
        let temp = a
        a = b
        b = temp
    }

    public func dangerousSwap() {
        // This could cause overlapping access if called incorrectly
        // swapValues(&value, &value) // Would be error
        var x = 1
        var y = 2
        swapValues(&x, &y)
    }
}

// Escaping closure capturing inout
public func escapingWithInout() {
    var value = 10

    // Escaping closure can't capture inout
    let closure = { [value] in
        print(value) // Captured by value instead
    }

    value += 1
    closure()
}

// Unsafe pointer operations
public class UnsafePointerOperations {
    public init() {}

    public func unsafePointerUsage() {
        let array = [1, 2, 3, 4, 5]

        array.withUnsafeBufferPointer { buffer in
            // Using pointer after it might be invalidated
            let first = buffer.baseAddress
            print(first?.pointee ?? 0)
        }

        // Manual memory management
        let ptr = UnsafeMutablePointer<Int>.allocate(capacity: 10)
        ptr.initialize(repeating: 0, count: 10)

        // Accessing before initialization would be undefined
        print(ptr.pointee)

        ptr.deinitialize(count: 10)
        ptr.deallocate()
    }

    public func unsafeRawPointer() {
        var value: Int = 42

        withUnsafePointer(to: &value) { ptr in
            let raw = UnsafeRawPointer(ptr)
            let _ = raw.load(as: Int.self)
        }
    }

    public func unsafeMutableRawPointer() {
        var value: Int = 42

        withUnsafeMutablePointer(to: &value) { ptr in
            let raw = UnsafeMutableRawPointer(ptr)
            raw.storeBytes(of: 100, as: Int.self)
        }
    }
}

// Weak reference cycles and memory leaks
public class Node {
    public var value: Int
    public var next: Node? // Strong reference - potential cycle
    public weak var previous: Node? // Weak to break cycle

    public init(value: Int) {
        self.value = value
    }
}

public class StrongCycleA {
    public var b: StrongCycleB?
    public init() {}
    deinit { print("A deinit") }
}

public class StrongCycleB {
    public var a: StrongCycleA? // Strong - creates cycle
    public init() {}
    deinit { print("B deinit") }
}

public func createCycle() {
    let a = StrongCycleA()
    let b = StrongCycleB()
    a.b = b
    b.a = a // Cycle created - memory leak
}

// Closure capture cycles
public class ClosureCycle {
    public var closure: (() -> Void)?
    public var value: Int = 0

    public init() {}

    public func setupClosure() {
        // Strong self capture - potential cycle
        closure = {
            self.value += 1 // Captures self strongly
        }
    }

    public func setupWithWeak() {
        // Correct: weak capture
        closure = { [weak self] in
            self?.value += 1
        }
    }

    public func setupWithUnowned() {
        // Unowned - dangerous if self deallocated
        closure = { [unowned self] in
            self.value += 1
        }
    }
}

// Unowned vs weak in different scenarios
public class Owner {
    public var owned: Owned?

    public init() {}
}

public class Owned {
    public unowned var owner: Owner // Unowned - must always be valid

    public init(owner: Owner) {
        self.owner = owner
    }
}

public func unownedDanger() {
    var owner: Owner? = Owner()
    let owned = Owned(owner: owner!)
    owner!.owned = owned

    owner = nil // Owner deallocated
    // owned.owner would crash if accessed
    _ = owned
}

// Implicitly unwrapped optionals
public class ImplicitlyUnwrapped {
    public var required: String! // IUO - can cause crash
    public var alsoRequired: Int! // IUO
    public var anotherIUO: [String]! // IUO

    public init() {}

    public func useBeforeSet() {
        // These could crash if not set
        print(required ?? "nil")
        print(alsoRequired ?? 0)
        print(anotherIUO ?? [])
    }
}

// Force unwrap chains
public func forceUnwrapChain() {
    let dict: [String: [String: Int?]] = ["a": ["b": 42]]

    // Dangerous chain of force unwraps
    let _ = dict["a"]!["b"]!! // Multiple force unwraps

    let optArray: [[Int?]]? = [[1, nil, 3]]
    let _ = optArray![0][0]! // Force unwrap chain

    let nested: [String: [String: [Int]?]]? = ["x": ["y": [1, 2, 3]]]
    let _ = nested!["x"]!["y"]!![0] // Long chain - unwrap the optional array
}

// Unsafe casts
public func unsafeCasts() {
    let any: Any = "string"

    // Force cast
    let _ = any as! String // Could crash if wrong type
    let _ = any as! Int // Would crash

    let array: [Any] = [1, "two", 3.0]
    let _ = array as! [Int] // Would crash

    let dict: [String: Any] = ["a": 1]
    let _ = dict as! [String: String] // Would crash
}

// Buffer overrun potential
public class BufferOperations {
    public var buffer: [Int] = Array(repeating: 0, count: 10)

    public init() {}

    public func unsafeAccess(_ index: Int) -> Int {
        // No bounds checking
        return buffer[index] // Could crash if out of bounds
    }

    public func unsafeWrite(_ index: Int, value: Int) {
        buffer[index] = value // Could crash if out of bounds
    }

    public func saferAccess(_ index: Int) -> Int? {
        guard index >= 0 && index < buffer.count else { return nil }
        return buffer[index]
    }
}
