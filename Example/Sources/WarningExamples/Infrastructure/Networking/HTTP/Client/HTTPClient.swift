// MARK: - HTTPClient - Protocol & Type Warnings

import Foundation

// MARK: - Protocol Inheritance Issues
public protocol BaseProtocol {
    func baseMethod()
}

public protocol DerivedProtocol: BaseProtocol, BaseProtocol { // redundant inheritance
    func derivedMethod()
}

// MARK: - Existential Any Warnings (Swift 6)
public protocol DataSource {
    func fetchData() -> Data
}

public protocol Transformer {
    func transform(_ data: Data) -> Data
}

public class HTTPClient {
    // Using protocol without 'any' - Swift 6 warning
    public var dataSource: DataSource?
    public var transformer: Transformer?
    public var sources: [DataSource] = []
    public var transformers: [Transformer] = []

    public init() {}

    // MARK: - Parameter accepts protocol type
    public func process(source: DataSource) {
        let data = source.fetchData()
        print(data)
    }

    public func transform(using transformer: Transformer, data: Data) {
        let result = transformer.transform(data)
        print(result)
    }

    // MARK: - Optional Protocol Type
    public func optionalProtocol(source: DataSource?) {
        guard let source = source else { return }
        let data = source.fetchData()
        print(data)
    }

    // MARK: - Class Constraint Issues
    public func classConstraints() {
        // AnyObject constraint
        class Container<T: AnyObject> {
            var value: T
            init(value: T) { self.value = value }
        }

        let container = Container(value: NSObject())
        print(container.value)
    }

    // MARK: - Unnecessary Type Annotation
    public func unnecessaryAnnotations() {
        let string: String = "obvious"
        let number: Int = 42
        let decimal: Double = 3.14
        let flag: Bool = true
        let array: [Int] = [1, 2, 3]

        print(string, number, decimal, flag, array)
    }

    // MARK: - Computed Property with Setter Warning
    private var _value: Int = 0
    public var value: Int {
        get { return _value }
        set { _value = newValue }
    }

    // MARK: - Lazy Var with Immediate Use
    public lazy var lazyValue: Int = {
        return 42
    }()

    public func useLazy() {
        // Accessing lazy var immediately after init
        let _ = lazyValue
    }
}
