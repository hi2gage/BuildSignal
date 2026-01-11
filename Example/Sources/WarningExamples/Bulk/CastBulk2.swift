// MARK: - Bulk Cast Warnings Part 2

import Foundation

public class CastBulk2 {
    public init() {}

    public func moreCasts() {
        let arr1 = [1, 2, 3]; let arr2 = [4, 5, 6]; let arr3 = [7, 8, 9]

        if let _ = arr1 as? [Int] { print("1") }
        if let _ = arr2 as? [Int] { print("2") }
        if let _ = arr3 as? [Int] { print("3") }
        if let _ = arr1 as? [Int] { print("4") }
        if let _ = arr2 as? [Int] { print("5") }
        if let _ = arr3 as? [Int] { print("6") }
        if let _ = arr1 as? [Int] { print("7") }
        if let _ = arr2 as? [Int] { print("8") }
        if let _ = arr3 as? [Int] { print("9") }
        if let _ = arr1 as? [Int] { print("10") }
    }

    public func dictCasts() {
        let d1 = ["a": 1]; let d2 = ["b": 2]; let d3 = ["c": 3]

        if let _ = d1 as? [String: Int] { print("1") }
        if let _ = d2 as? [String: Int] { print("2") }
        if let _ = d3 as? [String: Int] { print("3") }
        if let _ = d1 as? [String: Int] { print("4") }
        if let _ = d2 as? [String: Int] { print("5") }
        if let _ = d3 as? [String: Int] { print("6") }
        if let _ = d1 as? [String: Int] { print("7") }
        if let _ = d2 as? [String: Int] { print("8") }
        if let _ = d3 as? [String: Int] { print("9") }
        if let _ = d1 as? [String: Int] { print("10") }
    }

    public func boolCasts() {
        let b1 = true; let b2 = false; let b3 = true

        if let _ = b1 as? Bool { print("1") }
        if let _ = b2 as? Bool { print("2") }
        if let _ = b3 as? Bool { print("3") }
        if let _ = b1 as? Bool { print("4") }
        if let _ = b2 as? Bool { print("5") }
        if let _ = b3 as? Bool { print("6") }
        if let _ = b1 as? Bool { print("7") }
        if let _ = b2 as? Bool { print("8") }
        if let _ = b3 as? Bool { print("9") }
        if let _ = b1 as? Bool { print("10") }
    }

    public func forcedCasts() {
        let x1 = "x1"; let x2 = "x2"; let x3 = "x3"; let x4 = "x4"; let x5 = "x5"

        let _ = x1 as! String
        let _ = x2 as! String
        let _ = x3 as! String
        let _ = x4 as! String
        let _ = x5 as! String

        let n1 = 1; let n2 = 2; let n3 = 3; let n4 = 4; let n5 = 5

        let _ = n1 as! Int
        let _ = n2 as! Int
        let _ = n3 as! Int
        let _ = n4 as! Int
        let _ = n5 as! Int
    }

    public func isChecks() {
        let s = "test"; let n = 42; let d = 3.14

        let _ = s is String
        let _ = s is String
        let _ = s is String
        let _ = s is String
        let _ = s is String
        let _ = n is Int
        let _ = n is Int
        let _ = n is Int
        let _ = n is Int
        let _ = n is Int
        let _ = d is Double
        let _ = d is Double
        let _ = d is Double
        let _ = d is Double
        let _ = d is Double
    }
}
