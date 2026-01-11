// MARK: - Cast Warnings

import Foundation

public class CastWarnings {
    public init() {}

    public func alwaysSucceeds() {
        let s1 = "a"; let s2 = "b"; let s3 = "c"; let s4 = "d"; let s5 = "e"
        if let _ = s1 as? String { print("1") }
        if let _ = s2 as? String { print("2") }
        if let _ = s3 as? String { print("3") }
        if let _ = s4 as? String { print("4") }
        if let _ = s5 as? String { print("5") }

        let n1 = 1; let n2 = 2; let n3 = 3; let n4 = 4; let n5 = 5
        if let _ = n1 as? Int { print("1") }
        if let _ = n2 as? Int { print("2") }
        if let _ = n3 as? Int { print("3") }
        if let _ = n4 as? Int { print("4") }
        if let _ = n5 as? Int { print("5") }
    }

    public func isAlwaysTrue() {
        let s = "test"; let n = 42; let d = 3.14
        if s is String { print("s") }
        if s is String { print("s") }
        if s is String { print("s") }
        if n is Int { print("n") }
        if n is Int { print("n") }
        if n is Int { print("n") }
        if d is Double { print("d") }
        if d is Double { print("d") }
        if d is Double { print("d") }
    }

    public func forcedNoop() {
        let s1 = "s1"; let s2 = "s2"; let s3 = "s3"
        let _ = s1 as! String
        let _ = s2 as! String
        let _ = s3 as! String
        let n1 = 1; let n2 = 2; let n3 = 3
        let _ = n1 as! Int
        let _ = n2 as! Int
        let _ = n3 as! Int
    }
}
