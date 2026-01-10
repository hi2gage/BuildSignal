import SwiftUI

/// Represents the high-level status of an Xcode build.
/// Maps to the `highLevelStatus` field in LogStoreManifest.plist.
enum BuildStatus: String, CaseIterable, Hashable {
    case success = "S"
    case warning = "W"
    case error = "E"

    /// SF Symbol name for this status
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.circle.fill"
        }
    }

    /// Display color for this status
    var color: Color {
        switch self {
        case .success: return .green
        case .warning: return .yellow
        case .error: return .red
        }
    }

    /// Human-readable label
    var label: String {
        switch self {
        case .success: return "Succeeded"
        case .warning: return "Warnings"
        case .error: return "Failed"
        }
    }
}
