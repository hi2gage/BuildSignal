import SwiftUI
import XCLogParser

/// Helper functions for styling and labeling notice types.
enum NoticeTypeHelpers {
    /// Returns the SF Symbol icon name for a notice type.
    static func icon(for type: NoticeType) -> String {
        switch type {
        case .swiftWarning, .clangWarning:
            return "exclamationmark.triangle.fill"
        case .deprecatedWarning:
            return "clock.arrow.circlepath"
        case .projectWarning:
            return "folder.badge.questionmark"
        case .analyzerWarning:
            return "magnifyingglass"
        case .interfaceBuilderWarning:
            return "rectangle.on.rectangle"
        default:
            return "exclamationmark.circle"
        }
    }

    /// Returns the color for a notice type.
    static func color(for type: NoticeType) -> Color {
        switch type {
        case .swiftWarning, .clangWarning:
            return .yellow
        case .deprecatedWarning:
            return .orange
        case .projectWarning:
            return .purple
        case .analyzerWarning:
            return .blue
        default:
            return .yellow
        }
    }

    /// Returns a human-readable label for a notice type.
    static func label(for type: NoticeType) -> String {
        switch type {
        case .swiftWarning: return "Swift Warnings"
        case .clangWarning: return "C/C++ Warnings"
        case .deprecatedWarning: return "Deprecations"
        case .projectWarning: return "Project Warnings"
        case .analyzerWarning: return "Analyzer Warnings"
        case .interfaceBuilderWarning: return "Interface Builder"
        case .note: return "Notes"
        default: return type.rawValue
        }
    }
}
