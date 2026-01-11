// MARK: - Naming Convention Warnings

import Foundation

// Class names should be UpperCamelCase
public class lowercase_class_name { // Wrong
    public init() {}
}

public class camelCaseClass { // Wrong - should start uppercase
    public init() {}
}

public class ALLCAPSCLASS { // Wrong
    public init() {}
}

public class Mixed_Case_Class { // Wrong
    public init() {}
}

public class snake_case_class { // Wrong
    public init() {}
}

// Struct names
public struct lowercase_struct { // Wrong
    public init() {}
}

public struct camelCaseStruct { // Wrong
    public init() {}
}

public struct ALLCAPSSTRUCT { // Wrong
    public init() {}
}

// Enum names
public enum lowercase_enum { // Wrong
    case value
}

public enum camelCaseEnum { // Wrong
    case value
}

public enum ALLCAPSENUM { // Wrong
    case VALUE
}

// Variable and property names should be lowerCamelCase
public class NamingIssuesClass {
    // Wrong naming conventions
    public var UpperCaseProperty: Int = 0 // Should be lowerCamelCase
    public var ALLCAPS: String = "" // Should be lowerCamelCase
    public var snake_case_var: Double = 0.0 // Should be lowerCamelCase
    public var PascalCase: Bool = false // Should be lowerCamelCase

    // Multiple underscore issues
    public var __doubleUnderscore: Int = 0
    public var underscore_in_middle: String = ""
    public var trailing_underscore_: Int = 0

    // Single letter (too short)
    public var x: Int = 0
    public var y: Int = 0
    public var z: Int = 0
    public var a: String = ""
    public var b: String = ""

    // Abbreviations not following conventions
    public var XMLParser: Any?
    public var URLString: String = ""
    public var HTMLContent: String = ""

    public init() {}

    // Method names
    public func UpperCaseMethod() {} // Should be lowerCamelCase
    public func snake_case_method() {} // Wrong
    public func ALLCAPSMETHOD() {} // Wrong

    // Boolean naming
    public var isValid: Bool = false // Correct
    public var valid: Bool = false // Missing 'is' prefix
    public var enabled: Bool = false // Could use 'is' prefix
    public var hasValue: Bool = false // Correct
    public var value_exists: Bool = false // Wrong naming

    // Constants should still be lowerCamelCase in Swift
    public let CONSTANT_VALUE: Int = 100 // Wrong
    public let MAX_SIZE: Int = 1000 // Wrong
    public let MIN_VALUE: Int = 0 // Wrong
}

// Protocol naming (should be UpperCamelCase, often end in -able, -ible, -ing)
public protocol lowercase_protocol { // Wrong
    func method()
}

public protocol snake_case_protocol { // Wrong
    func method()
}

// Generic type parameters
public class GenericNaming<t> { // Should be uppercase T
    public var value: t

    public init(value: t) {
        self.value = value
    }
}

public class MultipleGenerics<first, second> { // Should be First, Second or T, U
    public var a: first
    public var b: second

    public init(a: first, b: second) {
        self.a = a
        self.b = b
    }
}

// Function parameter naming
public func badParameterNaming(
    FirstParam: Int, // Should be lowerCamelCase
    SECOND_PARAM: String, // Wrong
    third_param: Double // Wrong
) {
    print(FirstParam, SECOND_PARAM, third_param)
}

// Enum case naming
public enum CaseNamingIssues {
    case UpperCaseCase // Should be lowerCamelCase
    case ALLCAPSCASE // Wrong
    case snake_case_case // Wrong
    case Mixed_Case // Wrong
}

// Typealias naming
public typealias ALLCAPS_ALIAS = Int // Wrong
public typealias snake_case_alias = String // Wrong
public typealias lowerCamelCaseAlias = Double // Wrong - should be UpperCamelCase

// Associated type naming
public protocol AssociatedTypeNaming {
    associatedtype element // Should be UpperCamelCase
    associatedtype ITEM // Wrong - should be Item
    associatedtype value_type // Wrong
}

// Closure parameter naming
public func closureNaming() {
    let closure: (Int, String) -> Void = { Number, STRING in // Wrong
        print(Number, STRING)
    }

    let another: (Double) -> Double = { VALUE in // Wrong
        VALUE * 2
    }

    closure(1, "test")
    _ = another(2.0)
}

// Tuple element naming
public func tupleNaming() -> (FIRST: Int, second_value: String, Third: Double) { // Mixed issues
    (FIRST: 1, second_value: "test", Third: 2.0)
}

// File-private and private naming
fileprivate var FILE_PRIVATE_VAR: Int = 0 // Wrong
private var PRIVATE_VAR: String = "" // Wrong

fileprivate func FILE_PRIVATE_FUNC() {} // Wrong
private func PRIVATE_FUNC() {} // Wrong

// Static and class naming
public class StaticNaming {
    public static var STATIC_VAR: Int = 0 // Wrong
    public static let STATIC_CONST: String = "" // Wrong

    public class var CLASS_VAR: Int { 0 } // Wrong

    public static func STATIC_METHOD() {} // Wrong

    public init() {}
}
