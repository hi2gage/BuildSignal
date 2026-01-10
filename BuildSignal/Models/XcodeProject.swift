import AppKit
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

    /// Path to the first .app bundle found in Build/Products
    var appBundlePath: URL? {
        let productsPath = derivedDataPath.appendingPathComponent("Build/Products")
        let fileManager = FileManager.default

        guard fileManager.fileExists(atPath: productsPath.path) else { return nil }

        // Search through product configurations (Debug-iphonesimulator, Release-iphoneos, Debug, etc.)
        guard let configurations = try? fileManager.contentsOfDirectory(
            at: productsPath,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else { return nil }

        // Prefer Debug configurations, then any configuration
        let sortedConfigs = configurations.sorted { url1, url2 in
            let name1 = url1.lastPathComponent
            let name2 = url2.lastPathComponent
            // Prioritize Debug builds
            if name1.hasPrefix("Debug") && !name2.hasPrefix("Debug") { return true }
            if !name1.hasPrefix("Debug") && name2.hasPrefix("Debug") { return false }
            return name1 < name2
        }

        for configURL in sortedConfigs {
            if let apps = try? fileManager.contentsOfDirectory(
                at: configURL,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            ) {
                // Find the first .app bundle
                if let appBundle = apps.first(where: { $0.pathExtension == "app" }) {
                    return appBundle
                }
            }
        }

        return nil
    }

    /// The app icon from the built .app bundle, if available
    var appIcon: NSImage? {
        guard let appPath = appBundlePath else { return nil }
        return NSWorkspace.shared.icon(forFile: appPath.path)
    }
}
