// MARK: - Protocol Warnings - Swift 6

import Foundation

// Existential any warnings (ExistentialAny feature)
public protocol Drawable {
    func draw()
}

public protocol Printable {
    func printSelf()
}

public protocol Identifiable2 {
    var id: String { get }
}

public protocol Configurable {
    func configure()
}

public protocol Validatable {
    func validate() -> Bool
}

// Using protocols without 'any' keyword
public func drawSomething(_ drawable: Drawable) { // Should be 'any Drawable'
    drawable.draw()
}

public func printSomething(_ printable: Printable) { // Should be 'any Printable'
    printable.printSelf()
}

public func getId(_ item: Identifiable2) -> String { // Should be 'any Identifiable2'
    item.id
}

public func configureSomething(_ item: Configurable) { // Should be 'any Configurable'
    item.configure()
}

public func validateSomething(_ item: Validatable) -> Bool { // Should be 'any Validatable'
    item.validate()
}

// Arrays of protocols without 'any'
public var drawables: [Drawable] = [] // Should be [any Drawable]
public var printables: [Printable] = [] // Should be [any Printable]
public var identifiables: [Identifiable2] = [] // Should be [any Identifiable2]
public var configurables: [Configurable] = [] // Should be [any Configurable]
public var validatables: [Validatable] = [] // Should be [any Validatable]

// Optional protocols without 'any'
public var optionalDrawable: Drawable? // Should be (any Drawable)?
public var optionalPrintable: Printable? // Should be (any Printable)?
public var optionalIdentifiable: Identifiable2? // Should be (any Identifiable2)?

// Dictionary with protocol values
public var drawableDict: [String: Drawable] = [:] // Should be [String: any Drawable]
public var printableDict: [String: Printable] = [:] // Should be [String: any Printable]

// Protocol composition without 'any'
public func processDrawableAndPrintable(_ item: Drawable & Printable) {
    item.draw()
    item.printSelf()
}

public func processMultipleProtocols(_ item: Drawable & Printable & Configurable) {
    item.draw()
    item.printSelf()
    item.configure()
}

// Return type without 'any'
public func getDrawable() -> Drawable? { // Should return (any Drawable)?
    nil
}

public func getPrintable() -> Printable? { // Should return (any Printable)?
    nil
}

public func getConfigurable() -> Configurable? {
    nil
}

// Class properties with protocol types
public class ProtocolHolder {
    public var drawable: Drawable? // Should be (any Drawable)?
    public var printable: Printable? // Should be (any Printable)?
    public var items: [Drawable] = [] // Should be [any Drawable]

    public init() {}

    public func addDrawable(_ d: Drawable) { // Should be 'any Drawable'
        items.append(d)
    }

    public func getFirst() -> Drawable? { // Should return (any Drawable)?
        items.first
    }
}

// Struct with protocol properties
public struct ProtocolContainer {
    public var drawable: Drawable? // Should be (any Drawable)?
    public var all: [Drawable] // Should be [any Drawable]

    public init(all: [Drawable]) { // Should be [any Drawable]
        self.all = all
    }
}

// Closures with protocol parameters
public var drawHandler: ((Drawable) -> Void)? // Should be ((any Drawable) -> Void)?
public var printHandler: ((Printable) -> Void)?
public var configHandler: ((Configurable) -> Void)?

// Protocol with Self requirement issues
public protocol Copyable {
    func copy() -> Self
}

public protocol Comparable2 {
    func compare(to other: Self) -> Int
}

// Using protocol in generic context
public func processItems<T: Drawable>(_ items: [T]) {
    for item in items {
        item.draw()
    }
}

// Type erasure patterns that generate warnings
public class AnyDrawable: Drawable {
    private let _draw: () -> Void

    public init<D: Drawable>(_ drawable: D) {
        _draw = drawable.draw
    }

    public func draw() {
        _draw()
    }
}

// Multiple protocol conformance issues
public protocol A { func a() }
public protocol B { func b() }
public protocol C { func c() }
public protocol D { func d() }
public protocol E { func e() }

public func processA(_ item: A) { item.a() }
public func processB(_ item: B) { item.b() }
public func processC(_ item: C) { item.c() }
public func processD(_ item: D) { item.d() }
public func processE(_ item: E) { item.e() }

public var aItems: [A] = []
public var bItems: [B] = []
public var cItems: [C] = []
public var dItems: [D] = []
public var eItems: [E] = []

// Protocol metatype without 'any'
public func getType() -> Drawable.Type? {
    nil
}

public func checkType(_ item: Any) -> Bool {
    item is Drawable
}
