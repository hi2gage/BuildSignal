// MARK: - Unused Warnings

import Foundation

public class UnusedWarnings {
    public init() {}

    public func unusedVars() {
        let a1 = "a1"; let a2 = "a2"; let a3 = "a3"; let a4 = "a4"; let a5 = "a5"
        let b1 = 1; let b2 = 2; let b3 = 3; let b4 = 4; let b5 = 5
        let c1 = 1.0; let c2 = 2.0; let c3 = 3.0; let c4 = 4.0; let c5 = 5.0
        _ = (a1, a2, a3, a4, a5, b1, b2, b3, b4, b5, c1, c2, c3, c4, c5)
    }

    public func unusedResults() {
        let arr = [1, 2, 3, 4, 5]
        arr.map { $0 * 2 }
        arr.filter { $0 > 2 }
        arr.sorted()
        arr.reversed()
        arr.reduce(0, +)
    }

    public func varNeverMutated() {
        var x1 = 1; var x2 = 2; var x3 = 3; var x4 = 4; var x5 = 5
        print(x1, x2, x3, x4, x5)
    }
}
