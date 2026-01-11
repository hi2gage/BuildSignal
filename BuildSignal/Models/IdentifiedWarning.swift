import Foundation
import XCLogParser

/// A wrapper to give each warning a stable ID for use in SwiftUI Lists.
struct IdentifiedWarning: Identifiable, Hashable {
    let id: String
    let warning: Notice

    init(_ warning: Notice, index: Int) {
        // Create stable ID from warning properties
        self.id = "\(warning.documentURL):\(warning.startingLineNumber):\(warning.title.prefix(50)):\(index)"
        self.warning = warning
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: IdentifiedWarning, rhs: IdentifiedWarning) -> Bool {
        lhs.id == rhs.id
    }
}
