// MARK: - Literal Expressibility Warnings

import Foundation

// ExpressibleBy protocol conformances with issues
public struct CustomInt: ExpressibleByIntegerLiteral {
    public var value: Int

    public init(integerLiteral value: Int) {
        self.value = value
    }
}

public struct CustomString: ExpressibleByStringLiteral {
    public var value: String

    public init(stringLiteral value: String) {
        self.value = value
    }
}

public struct CustomFloat: ExpressibleByFloatLiteral {
    public var value: Double

    public init(floatLiteral value: Double) {
        self.value = value
    }
}

public struct CustomBool: ExpressibleByBooleanLiteral {
    public var value: Bool

    public init(booleanLiteral value: Bool) {
        self.value = value
    }
}

public struct CustomArray: ExpressibleByArrayLiteral {
    public var items: [Int]

    public init(arrayLiteral elements: Int...) {
        self.items = elements
    }
}

public struct CustomDict: ExpressibleByDictionaryLiteral {
    public var pairs: [(String, Int)]

    public init(dictionaryLiteral elements: (String, Int)...) {
        self.pairs = elements
    }
}

// Using custom expressible types
public func useCustomExpressible() {
    let customInt: CustomInt = 42
    let customString: CustomString = "hello"
    let customFloat: CustomFloat = 3.14
    let customBool: CustomBool = true
    let customArray: CustomArray = [1, 2, 3]
    let customDict: CustomDict = ["a": 1, "b": 2]

    print(customInt.value, customString.value, customFloat.value)
    print(customBool.value, customArray.items, customDict.pairs)
}

// Nil literal issues
public struct CustomOptional<T>: ExpressibleByNilLiteral {
    public var value: T?

    public init(nilLiteral: ()) {
        self.value = nil
    }

    public init(_ value: T) {
        self.value = value
    }
}

public func nilLiteralUsage() {
    let opt1: CustomOptional<Int> = nil
    let opt2: CustomOptional<String> = nil

    print(opt1.value ?? 0, opt2.value ?? "")
}

// String interpolation expressibility
public struct LogMessage: ExpressibleByStringInterpolation {
    public var message: String

    public init(stringLiteral value: String) {
        self.message = value
    }

    public init(stringInterpolation: DefaultStringInterpolation) {
        self.message = String(stringInterpolation: stringInterpolation)
    }
}

public func stringInterpolationUsage() {
    let name = "World"
    let log: LogMessage = "Hello, \(name)!"
    print(log.message)
}

// Unicode scalar expressibility
public struct CustomChar: ExpressibleByUnicodeScalarLiteral {
    public var char: Character

    public init(unicodeScalarLiteral value: Character) {
        self.char = value
    }
}

// Extended grapheme cluster
public struct CustomGrapheme: ExpressibleByExtendedGraphemeClusterLiteral {
    public var grapheme: Character

    public init(extendedGraphemeClusterLiteral value: Character) {
        self.grapheme = value
    }
}

// Literal protocol inheritance issues
public struct MultiExpressible: ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
    public var value: Double

    public init(integerLiteral value: Int) {
        self.value = Double(value)
    }

    public init(floatLiteral value: Double) {
        self.value = value
    }
}

public func multiExpressibleUsage() {
    let fromInt: MultiExpressible = 42
    let fromFloat: MultiExpressible = 3.14

    print(fromInt.value, fromFloat.value)
}

// Raw representable with expressibility
public enum Status: String, ExpressibleByStringLiteral {
    case active
    case inactive
    case pending

    public init(stringLiteral value: String) {
        self = Status(rawValue: value) ?? .pending
    }
}

public func rawRepresentableUsage() {
    let status1: Status = "active"
    let status2: Status = "invalid" // Falls back to .pending

    print(status1, status2)
}

// Codable with expressibility
public struct JSONValue: Codable, ExpressibleByStringLiteral, ExpressibleByIntegerLiteral, ExpressibleByBooleanLiteral, ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral {
    public enum Value: Codable {
        case string(String)
        case int(Int)
        case bool(Bool)
        case array([JSONValue])
        case dict([String: JSONValue])
    }

    public var value: Value

    public init(stringLiteral value: String) {
        self.value = .string(value)
    }

    public init(integerLiteral value: Int) {
        self.value = .int(value)
    }

    public init(booleanLiteral value: Bool) {
        self.value = .bool(value)
    }

    public init(arrayLiteral elements: JSONValue...) {
        self.value = .array(elements)
    }

    public init(dictionaryLiteral elements: (String, JSONValue)...) {
        var dict: [String: JSONValue] = [:]
        for (key, value) in elements {
            dict[key] = value
        }
        self.value = .dict(dict)
    }
}

public func jsonValueUsage() {
    let json: JSONValue = ["name": "test", "count": 42, "active": true]
    print(json)
}

// Literal conversion warnings
public func literalConversionWarnings() {
    // These might generate warnings about literal conversion
    let _: Double = 42 // Int literal to Double
    let _: Float = 42 // Int literal to Float
    let _: CGFloat = 42 // Int literal to CGFloat

    let _: String = "hello" // String literal
    let _: Substring = "hello" // String literal to Substring
}
