import Combine
import Foundation
import SwiftUI

/// ViewModel for the project selection screen.
/// Manages scanning state, project list, and selection.
@MainActor
final class ProjectSelectionViewModel: ObservableObject {

    // MARK: - State

    enum State: Equatable {
        case idle
        case loading
        case loaded([XcodeProject])
        case error(String)

        static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.loading, .loading):
                return true
            case (.loaded(let a), .loaded(let b)):
                return a == b
            case (.error(let a), .error(let b)):
                return a == b
            default:
                return false
            }
        }
    }

    // MARK: - Published Properties

    @Published private(set) var state: State = .idle
    @Published var selectedProject: XcodeProject?
    @Published var searchText: String = ""

    // MARK: - Private Properties

    private let scanner: DerivedDataScanner

    // MARK: - Computed Properties

    /// Projects filtered by search text
    var filteredProjects: [XcodeProject] {
        guard case .loaded(let projects) = state else { return [] }
        guard !searchText.isEmpty else { return projects }

        let query = searchText.lowercased()
        return projects.filter { project in
            project.name.lowercased().contains(query) ||
            project.displayName.lowercased().contains(query) ||
            project.workspacePath.path.lowercased().contains(query)
        }
    }

    /// Whether there are any projects loaded
    var hasProjects: Bool {
        if case .loaded(let projects) = state {
            return !projects.isEmpty
        }
        return false
    }

    /// Total project count
    var projectCount: Int {
        if case .loaded(let projects) = state {
            return projects.count
        }
        return 0
    }

    // MARK: - Initialization

    init(scanner: DerivedDataScanner = DerivedDataScanner()) {
        self.scanner = scanner
    }

    // MARK: - Public Methods

    /// Loads projects from DerivedData
    func loadProjects() async {
        state = .loading

        do {
            let projects = try await scanner.scanProjects()
            state = .loaded(projects)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    /// Refreshes the project list
    func refresh() async {
        await loadProjects()
    }

    /// Selects a project for viewing
    func selectProject(_ project: XcodeProject) {
        selectedProject = project
    }

    /// Clears the current selection
    func clearSelection() {
        selectedProject = nil
    }

    /// Opens the selected project in Xcode
    func openInXcode(_ project: XcodeProject) {
        NSWorkspace.shared.open(project.workspacePath)
    }

    /// Reveals a project in Finder
    func revealInFinder(_ project: XcodeProject) {
        NSWorkspace.shared.selectFile(
            project.workspacePath.path,
            inFileViewerRootedAtPath: project.workspacePath.deletingLastPathComponent().path
        )
    }
}
