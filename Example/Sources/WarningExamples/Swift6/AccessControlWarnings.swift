// MARK: - Access Control Warnings

import Foundation

// Public class with internal/private members exposed
public class PublicClassWithIssues {
    // Internal stored property in public class
    var internalProperty: Int = 0

    // Private property (correct)
    private var privateProperty: String = ""

    // Public init exposing internal
    public init(internal value: Int) {
        self.internalProperty = value
    }

    // Public method returning internal type
    public func getInternal() -> Int {
        internalProperty
    }

    // Internal method in public class
    func internalMethod() {
        print("internal")
    }

    // Fileprivate in public class
    fileprivate func fileprivateMethod() {
        print("fileprivate")
    }
}

// Public struct with internal init
public struct PublicStructInternalInit {
    public var value: Int
    var internalValue: String // Internal in public struct

    // Memberwise init is internal by default
    init(value: Int, internalValue: String) {
        self.value = value
        self.internalValue = internalValue
    }

    // Must provide public init
    public init(value: Int) {
        self.value = value
        self.internalValue = ""
    }
}

// Public enum with nested types
public enum PublicEnumIssues {
    case simple
    case withValue(Int)
    case withInternalType(InternalType) // Nested type in public enum

    public struct InternalType { // Made public to fix error but pattern shows access level
        public var value: Int
        public init(value: Int) { self.value = value }
    }
}

// Open class issues
open class OpenClassIssues {
    // Open stored property
    open var openProperty: Int = 0

    // Public but not open - can't override
    public var publicProperty: String = ""

    // Internal in open class
    var internalProperty: Double = 0.0

    public init() {}

    // Open method
    open func openMethod() {}

    // Public but not open
    public func publicMethod() {}

    // Internal method
    func internalMethod() {}
}

// Subclass trying to widen access
public class Subclass: OpenClassIssues {
    // Override must maintain access level
    override open func openMethod() {
        super.openMethod()
    }

    // Can't make more visible than super
    override public func publicMethod() {
        super.publicMethod()
    }
}

// Protocol with access level issues
public protocol PublicProtocolIssues {
    // All requirements implicitly public
    var requiredProperty: Int { get set }
    func requiredMethod()

    // Associatedtype
    associatedtype Element
}

// Internal type conforming to public protocol
internal class InternalConformance: PublicProtocolIssues {
    typealias Element = Int
    var requiredProperty: Int = 0
    func requiredMethod() {}
}

// Extension reducing access
public extension PublicClassWithIssues {
    // These are public
    func publicExtensionMethod() {}

    internal func internalInPublicExtension() {} // Mixed access

    private func privateInPublicExtension() {} // Private in public extension
}

internal extension PublicClassWithIssues {
    // These are all internal despite public type
    func allInternalHere() {}
}

// Nested type access
public class OuterPublic {
    public class NestedPublic {
        public init() {}
    }

    class NestedInternal { // Internal nested in public
        init() {}
    }

    private class NestedPrivate {
        init() {}
    }

    public init() {}

    public func useNested() {
        _ = NestedPublic()
        _ = NestedInternal()
        _ = NestedPrivate()
    }
}

// Setter access level
public class SetterAccessLevels {
    // Public get, private set
    public private(set) var readOnlyPublic: Int = 0

    // Public get, internal set
    public internal(set) var readOnlyInternal: String = ""

    // Internal get, private set
    internal private(set) var internalReadOnly: Double = 0.0

    public init() {}

    internal func modifyInternal() {
        readOnlyPublic = 1
        readOnlyInternal = "modified"
        internalReadOnly = 1.0
    }
}

// Typealias access
public typealias PublicAlias = Int
internal typealias InternalAlias = String
private typealias PrivateAlias = Double

public func useAliases() {
    let _: PublicAlias = 1
    let _: InternalAlias = "hello"
    // Can't use PrivateAlias here
}

// Generic type access
public class GenericPublic<T> {
    public var value: T

    public init(value: T) {
        self.value = value
    }

    // Internal method with public type parameter
    func internalWithT(_ t: T) {}
}

// Protocol inheritance access
public protocol PublicBase {
    func baseMethod()
}

internal protocol InternalDerived: PublicBase {
    func derivedMethod()
}

// Default argument access
public class DefaultArgumentAccess {
    // Public default value for public function
    public static var defaultValue: Int = 42

    public init() {}

    public func publicWithDefault(_ value: Int = DefaultArgumentAccess.defaultValue) {
        print(value)
    }

    // Internal method can use internal default
    static var internalDefault: Int = 100
    func internalWithDefault(_ value: Int = internalDefault) {
        print(value)
    }
}

// Subscript access levels
public class SubscriptAccess {
    private var storage: [String: Int] = [:]

    public init() {}

    // Public subscript
    public subscript(key: String) -> Int? {
        get { storage[key] }
        set { storage[key] = newValue }
    }

    // Internal subscript
    subscript(index: Int) -> Int {
        index * 2
    }
}
