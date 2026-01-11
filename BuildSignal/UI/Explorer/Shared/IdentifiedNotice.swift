import Foundation
import XCLogParser

/// A wrapper to give each notice (warning/deprecation) a stable ID for use in SwiftUI Lists.
/// Conforms to SelectableItem for use with SelectionManager.
struct IdentifiedNotice: SelectableItem, Hashable {
    let notice: Notice
    let index: Int

    var id: String {
        "\(notice.documentURL):\(notice.startingLineNumber):\(index)"
    }

    var copyableText: String {
        NoticeUtilities.formatNotice(notice)
    }

    /// Convenience accessor for the underlying notice (for compatibility with existing code).
    var warning: Notice { notice }

    init(_ notice: Notice, index: Int) {
        self.notice = notice
        self.index = index
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: IdentifiedNotice, rhs: IdentifiedNotice) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Type Aliases for Backwards Compatibility

/// Alias for use in WarningsListView (semantically clearer).
typealias IdentifiedWarning = IdentifiedNotice

/// Alias for use in DeprecationsListView (semantically clearer).
typealias IdentifiedDeprecation = IdentifiedNotice
