import Foundation

/// Represents an Xcode project discovered in DerivedData.
/// Contains project metadata and its build history.
struct XcodeProject: Identifiable, Hashable {
    /// Unique identifier (the DerivedData folder name)
    let id: String

    /// Project name extracted from the folder name
    let name: String

    /// Full path to the .xcodeproj or .xcworkspace
    let workspacePath: URL

    /// Path to this project's DerivedData folder
    let derivedDataPath: URL

    /// When this project was last accessed in Xcode
    let lastAccessedDate: Date

    /// All builds for this project, sorted by most recent first
    let builds: [BuildLog]

    /// The most recent build, if any
    var latestBuild: BuildLog? {
        builds.first
    }

    /// Clean display name extracted from workspace path
    var displayName: String {
        workspacePath.deletingPathExtension().lastPathComponent
    }

    /// Whether the original project still exists on disk
    var projectExists: Bool {
        FileManager.default.fileExists(atPath: workspacePath.path)
    }

    /// File extension of the workspace (.xcodeproj or .xcworkspace)
    var workspaceType: String {
        workspacePath.pathExtension
    }

    /// Total warnings across all builds (for the latest build)
    var totalWarnings: Int {
        latestBuild?.warningCount ?? 0
    }

    /// Total errors across all builds (for the latest build)
    var totalErrors: Int {
        latestBuild?.errorCount ?? 0
    }
}
