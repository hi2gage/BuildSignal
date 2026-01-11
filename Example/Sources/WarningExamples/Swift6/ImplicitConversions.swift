// MARK: - Implicit Conversion Warnings

import Foundation

// Numeric conversions
public func numericConversions() {
    let int: Int = 42
    let int8: Int8 = 10
    let int16: Int16 = 100
    let int32: Int32 = 1000
    let int64: Int64 = 10000

    let uint: UInt = 42
    let uint8: UInt8 = 10
    let uint16: UInt16 = 100
    let uint32: UInt32 = 1000
    let uint64: UInt64 = 10000

    let float: Float = 3.14
    let double: Double = 3.14159

    // These require explicit conversion
    _ = Int(int8) + int
    _ = Int(int16) + int
    _ = Int(int32) + int
    _ = Int(int64) + int

    _ = UInt(uint8) + uint
    _ = UInt(uint16) + uint
    _ = UInt(uint32) + uint
    _ = UInt(uint64) + uint

    _ = Double(float) + double

    // Potential overflow not checked
    let largeInt: Int = Int.max
    let _ = largeInt &+ 1 // Overflow operator

    // Lossy conversions
    let bigDouble: Double = 999999999999999.999
    let _ = Float(bigDouble) // Lossy

    let bigInt: Int64 = Int64.max
    let _ = Int32(truncatingIfNeeded: bigInt) // Truncating
}

// String interpolation implicit conversions
public func stringInterpolationConversions() {
    let opt: Int? = nil
    let _ = "Value: \(opt)" // Implicit conversion of optional to string

    let optString: String? = nil
    let _ = "String: \(optString)" // Optional in interpolation

    let optArray: [Int]? = nil
    let _ = "Array: \(optArray)" // Optional array in interpolation

    let optDict: [String: Int]? = nil
    let _ = "Dict: \(optDict)" // Optional dict in interpolation
}

// Array type conversions
public func arrayConversions() {
    let intArray: [Int] = [1, 2, 3]
    let _ = intArray as [Any] // Upcasting array elements

    let stringArray: [String] = ["a", "b", "c"]
    let _ = stringArray as [Any] // Upcasting array elements

    // NSArray bridging
    let nsArray = intArray as NSArray // Bridging to NSArray
    let _ = nsArray as? [Int] // Bridging back

    let nsStringArray = stringArray as NSArray
    let _ = nsStringArray as? [String]
}

// Dictionary type conversions
public func dictConversions() {
    let dict: [String: Int] = ["a": 1, "b": 2]
    let _ = dict as [String: Any] // Upcasting values

    let anyDict: [String: Any] = ["a": 1, "b": "two"]
    let _ = anyDict as? [String: Int] // Conditional downcast

    // NSDictionary bridging
    let nsDict = dict as NSDictionary
    let _ = nsDict as? [String: Int]
}

// Closure type conversions
public func closureConversions() {
    let intClosure: (Int) -> Int = { $0 + 1 }

    // Assigning to Any
    let _: Any = intClosure

    // Non-escaping to escaping (explicit @escaping needed)
    var escapingClosures: [() -> Void] = []
    func addClosure(_ c: @escaping () -> Void) {
        escapingClosures.append(c)
    }

    addClosure { print("hello") }
}

// Tuple conversions
public func tupleConversions() {
    let tuple: (Int, String) = (1, "hello")
    let _ = tuple as (Any, Any) // Upcasting tuple elements

    let namedTuple: (x: Int, y: Int) = (x: 1, y: 2)
    let _ = namedTuple as (Int, Int) // Losing labels

    // Cannot implicitly convert between different tuple arities
    let triple: (Int, Int, Int) = (1, 2, 3)
    let _ = triple
}

// Enum raw value conversions
public enum Status: Int {
    case active = 1
    case inactive = 0
    case pending = 2
}

public func enumConversions() {
    let status: Status = .active
    let rawValue = status.rawValue // Implicit unwrap of raw value

    let _ = Status(rawValue: rawValue) // Optional return

    // Force unwrap raw value init
    let _ = Status(rawValue: 1)! // Force unwrap

    // Invalid raw value
    let _ = Status(rawValue: 999) // Returns nil
}

// Protocol type conversions
public func protocolConversions() {
    let string: String = "hello"

    // CustomStringConvertible
    let _ = string as CustomStringConvertible

    // Hashable
    let _ = string as Hashable

    // Any
    let _ = string as Any

    // AnyHashable
    let _ = string as AnyHashable
}

// Bridging conversions
public func bridgingConversions() {
    let swiftString: String = "hello"
    let nsString: NSString = swiftString as NSString // Bridging

    let swiftArray: [Int] = [1, 2, 3]
    let nsArray: NSArray = swiftArray as NSArray // Bridging

    let swiftDict: [String: Int] = ["a": 1]
    let nsDict: NSDictionary = swiftDict as NSDictionary // Bridging

    let swiftSet: Set<String> = ["a", "b"]
    let nsSet: NSSet = swiftSet as NSSet // Bridging

    // Back conversions
    let _ = nsString as String
    let _ = nsArray as? [Int]
    let _ = nsDict as? [String: Int]
    let _ = nsSet as? Set<String>
}

// Numeric literal conversions
public func literalConversions() {
    let _: Double = 42 // Int literal to Double
    let _: Float = 42 // Int literal to Float
    let _: CGFloat = 42 // Int literal to CGFloat

    let _: Int = 0xFF // Hex literal
    let _: UInt8 = 0b11111111 // Binary literal
    let _: Int = 0o777 // Octal literal
}

// Optional binding without type annotation
public func optionalBindingTypes() {
    let optInt: Int? = 42
    if let value = optInt {
        print(value)
    }

    let optString: String? = "hello"
    guard let str = optString else { return }
    print(str)

    let optArray: [Int]? = [1, 2, 3]
    if let arr = optArray {
        print(arr)
    }
}
