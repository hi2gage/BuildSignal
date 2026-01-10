// MARK: - SyncQueue - Access Control & Visibility Warnings

import Foundation

// MARK: - Internal Declaration in Public Extension
public class SyncQueue {
    internal var internalProperty = 0 // internal in public class

    public init() {}

    // MARK: - Private Setter Public Getter
    public private(set) var readOnlyPublic = 0

    // MARK: - Fileprivate vs Private
    fileprivate var filePrivateVar = 0 // could be private
    fileprivate func filePrivateMethod() {} // could be private

    // MARK: - Public in Private Context
    private struct PrivateStruct {
        public var publicInPrivate = 0 // public meaningless here
        public func publicMethod() {} // public meaningless
    }

    // MARK: - Open vs Public
    // In non-final class context
    public func methodThatCouldBeOverridden() {
        print("base implementation")
    }

    // MARK: - Unused Private Members
    private var unusedPrivate1 = 0
    private var unusedPrivate2 = ""
    private var unusedPrivate3: [Int] = []

    private func unusedPrivateMethod1() {}
    private func unusedPrivateMethod2() -> Int { 0 }
    private func unusedPrivateMethod3(_ param: String) {}

    // MARK: - Access Control Example
    public func accessControlExample() {
        print("example")
    }

    // MARK: - @frozen Without Public
    internal struct InternalFrozen { // @frozen only matters for public
        var x: Int
    }

    // MARK: - Computed Property Access Level
    public var computedPublic: Int {
        internalHelper() // calling internal from public
    }

    internal func internalHelper() -> Int {
        return 42
    }

    // MARK: - Protocol Witness Accessibility
    public func methodUsesInternal() {
        let privateStruct = PrivateStruct()
        print(privateStruct.publicInPrivate)
        filePrivateMethod()
        print(filePrivateVar)
    }

    // MARK: - testable Import Implications
    // Methods that should be internal but are public for testing
    public func _testOnly_resetState() {
        internalProperty = 0
    }
}

// MARK: - Extension with Different Access
internal extension SyncQueue {
    // Internal extension on public type
    func internalExtensionMethod() {
        print("internal extension")
    }
}

private extension SyncQueue {
    // Private extension - methods only usable in this file
    func privateExtensionMethod() {
        print("private extension")
    }
}
