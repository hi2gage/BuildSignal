import Foundation

/// Represents a single build log entry from LogStoreManifest.plist.
/// Contains metadata about the build without parsing the actual .xcactivitylog file.
struct BuildLog: Identifiable, Hashable {
    /// Unique identifier (UUID from the plist)
    let id: String

    /// The .xcactivitylog filename
    let fileName: String

    /// Scheme name that was built
    let schemeName: String

    /// Container name (e.g., "ProjectName project")
    let containerName: String

    /// Build title (e.g., "Build ProjectName")
    let title: String

    /// High-level build status
    let status: BuildStatus

    /// Total number of warnings in this build
    let warningCount: Int

    /// Total number of errors in this build
    let errorCount: Int

    /// Total number of analyzer issues
    let analyzerIssueCount: Int

    /// Total number of test failures
    let testFailureCount: Int

    /// When the build started
    let startTime: Date

    /// When the build finished
    let endTime: Date

    /// Build duration in seconds
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }

    /// Formatted duration string
    var formattedDuration: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: duration) ?? "\(Int(duration))s"
    }
}
