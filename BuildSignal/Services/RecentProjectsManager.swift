import AppKit
import Combine
import Foundation

/// Manages the list of recently opened projects with persistence.
@MainActor
final class RecentProjectsManager: ObservableObject {
    static let shared = RecentProjectsManager()

    @Published private(set) var recentProjects: [RecentProject] = []

    private let userDefaultsKey = "RecentProjects"
    private let maxRecentProjects = 10

    private init() {
        loadRecentProjects()
    }

    /// Add a project to the recent list
    func addRecentProject(_ project: XcodeProject) {
        let recent = RecentProject(
            id: project.id,
            name: project.displayName,
            path: project.workspacePath,
            derivedDataPath: project.derivedDataPath,
            lastOpened: Date()
        )

        // Remove existing entry if present
        recentProjects.removeAll { $0.id == recent.id }

        // Add to front
        recentProjects.insert(recent, at: 0)

        // Trim to max
        if recentProjects.count > maxRecentProjects {
            recentProjects = Array(recentProjects.prefix(maxRecentProjects))
        }

        saveRecentProjects()
    }

    /// Remove a project from the recent list
    func removeRecentProject(_ project: RecentProject) {
        recentProjects.removeAll { $0.id == project.id }
        saveRecentProjects()
    }

    /// Clear all recent projects
    func clearRecentProjects() {
        recentProjects.removeAll()
        saveRecentProjects()
    }

    // MARK: - Persistence

    private func loadRecentProjects() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return }
        do {
            recentProjects = try JSONDecoder().decode([RecentProject].self, from: data)
            // Filter out projects that no longer exist
            recentProjects = recentProjects.filter { FileManager.default.fileExists(atPath: $0.path.path) }
        } catch {
            print("Failed to load recent projects: \(error)")
        }
    }

    private func saveRecentProjects() {
        do {
            let data = try JSONEncoder().encode(recentProjects)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Failed to save recent projects: \(error)")
        }
    }
}

/// A simplified project reference for the recent list
struct RecentProject: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let path: URL
    let derivedDataPath: URL
    let lastOpened: Date

    /// Convert back to an XcodeProject for analysis
    func toXcodeProject() -> XcodeProject? {
        // We need to re-scan the project to get build info
        // For now, create a minimal XcodeProject
        return XcodeProject(
            id: id,
            name: name,
            workspacePath: path,
            derivedDataPath: derivedDataPath,
            lastAccessedDate: lastOpened,
            builds: []  // Will need to re-scan builds
        )
    }

    /// The app icon from the built .app bundle, if available
    var appIcon: NSImage? {
        let productsPath = derivedDataPath.appendingPathComponent("Build/Products")
        let fileManager = FileManager.default

        guard fileManager.fileExists(atPath: productsPath.path) else { return nil }

        guard let configurations = try? fileManager.contentsOfDirectory(
            at: productsPath,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else { return nil }

        // Prefer Debug configurations
        let sortedConfigs = configurations.sorted { url1, url2 in
            let name1 = url1.lastPathComponent
            let name2 = url2.lastPathComponent
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
                if let appBundle = apps.first(where: { $0.pathExtension == "app" }) {
                    return NSWorkspace.shared.icon(forFile: appBundle.path)
                }
            }
        }

        return nil
    }
}
