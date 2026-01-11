// MARK: - Bulk Unused Result Warnings Part 2

import Foundation

public class UnusedResultBulk2 {
    public init() {}

    public func moreUnusedMaps() {
        let arr = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        arr.map { $0 * 100 }
        arr.map { $0 * 101 }
        arr.map { $0 * 102 }
        arr.map { $0 * 103 }
        arr.map { $0 * 104 }
        arr.map { $0 * 105 }
        arr.map { $0 * 106 }
        arr.map { $0 * 107 }
        arr.map { $0 * 108 }
        arr.map { $0 * 109 }
        arr.map { $0 * 110 }
        arr.map { $0 * 111 }
        arr.map { $0 * 112 }
        arr.map { $0 * 113 }
        arr.map { $0 * 114 }
    }

    public func moreUnusedFilters() {
        let arr = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        arr.filter { $0 > 0 }
        arr.filter { $0 > 1 }
        arr.filter { $0 > 2 }
        arr.filter { $0 > 3 }
        arr.filter { $0 > 4 }
        arr.filter { $0 > 5 }
        arr.filter { $0 > 6 }
        arr.filter { $0 > 7 }
        arr.filter { $0 > 8 }
        arr.filter { $0 > 9 }
        arr.filter { $0 < 10 }
        arr.filter { $0 < 9 }
        arr.filter { $0 < 8 }
        arr.filter { $0 < 7 }
        arr.filter { $0 < 6 }
    }

    public func moreUnusedCompactMap() {
        let arr = [1, 2, 3, 4, 5]
        arr.compactMap { $0 > 0 ? $0 : nil }
        arr.compactMap { $0 > 1 ? $0 : nil }
        arr.compactMap { $0 > 2 ? $0 : nil }
        arr.compactMap { $0 > 3 ? $0 : nil }
        arr.compactMap { $0 > 4 ? $0 : nil }
        arr.compactMap { $0 < 5 ? $0 : nil }
        arr.compactMap { $0 < 4 ? $0 : nil }
        arr.compactMap { $0 < 3 ? $0 : nil }
        arr.compactMap { $0 < 2 ? $0 : nil }
        arr.compactMap { $0 < 1 ? $0 : nil }
    }

    public func moreUnusedOps() {
        let x = 100; let y = 50
        x + y; x + y; x + y; x + y; x + y
        x - y; x - y; x - y; x - y; x - y
        x * y; x * y; x * y; x * y; x * y
        x / y; x / y; x / y; x / y; x / y
        x % y; x % y; x % y; x % y; x % y
    }
}
