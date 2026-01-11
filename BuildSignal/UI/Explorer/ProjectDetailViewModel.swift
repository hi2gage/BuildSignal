import Combine
import Foundation
import XCLogParser

/// ViewModel for the project detail view with parsing capabilities.
@MainActor
final class ProjectDetailViewModel: ObservableObject {

    // MARK: - State

    enum ParsingState: Equatable {
        case idle
        case parsing
        case parsed(json: String)
        case error(String)

        static func == (lhs: ParsingState, rhs: ParsingState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.parsing, .parsing):
                return true
            case (.parsed(let a), .parsed(let b)):
                return a == b
            case (.error(let a), .error(let b)):
                return a == b
            default:
                return false
            }
        }
    }

    // MARK: - Published Properties

    @Published private(set) var parsingState: ParsingState = .idle
    @Published private(set) var parsedBuildStep: BuildStep?
    @Published private(set) var warnings: [Notice] = []
    @Published private(set) var errors: [Notice] = []
    @Published var selectedScope: ScopeItem = .all

    // MARK: - Properties

    let project: XcodeProject
    private let parserService = LogParserService()

    // MARK: - Computed Properties

    var latestLogURL: URL? {
        guard let latestBuild = project.latestBuild else { return nil }
        return project.derivedDataPath
            .appendingPathComponent("Logs/Build")
            .appendingPathComponent(latestBuild.fileName)
    }

    var hasLatestBuild: Bool {
        project.latestBuild != nil
    }

    var projectWarningCount: Int {
        warnings.filter { !isPackageDependency($0) }.count
    }

    var packageWarningCount: Int {
        warnings.filter { isPackageDependency($0) }.count
    }

    var warningsOnlyCount: Int {
        warnings.filter { $0.type != .deprecatedWarning }.count
    }

    var deprecationsCount: Int {
        warnings.filter { $0.type == .deprecatedWarning }.count
    }

    var directoryTree: [DirectoryNode] {
        buildDirectoryTree()
    }

    // MARK: - Initialization

    init(project: XcodeProject) {
        self.project = project
    }

    /// Creates a view model with sample warnings for previews
    static func preview(withWarnings warnings: [Notice] = []) -> ProjectDetailViewModel {
        let project = XcodeProject(
            id: "preview-project",
            name: "PreviewProject",
            workspacePath: URL(fileURLWithPath: "/Users/test/PreviewProject/PreviewProject.xcodeproj"),
            derivedDataPath: URL(fileURLWithPath: "/Users/test/Library/Developer/Xcode/DerivedData/PreviewProject-abc123"),
            lastAccessedDate: Date(),
            builds: []
        )
        let viewModel = ProjectDetailViewModel(project: project)
        viewModel.warnings = warnings
        viewModel.parsingState = .parsed(json: "{}")
        return viewModel
    }

    // MARK: - Public Methods

    /// Parses the latest build log for this project.
    func parseLatestBuild() async {
        guard let logURL = latestLogURL else {
            parsingState = .error("No build log available")
            return
        }

        parsingState = .parsing

        do {
            // Parse to BuildStep
            let buildStep = try await parserService.parseBuildLog(at: logURL)
            self.parsedBuildStep = buildStep

            // Extract warnings and errors
            self.warnings = await parserService.extractWarnings(from: buildStep)
            self.errors = await parserService.extractErrors(from: buildStep)

            // Generate JSON for display
            let jsonString = try await parserService.parseBuildLogAsJSONString(at: logURL)
            parsingState = .parsed(json: jsonString)

        } catch {
            parsingState = .error(error.localizedDescription)
        }
    }

    /// Resets the parsing state.
    func reset() {
        parsingState = .idle
        parsedBuildStep = nil
        warnings = []
        errors = []
        selectedScope = .all
    }

    // MARK: - Scope Helpers

    func isPackageDependency(_ warning: Notice) -> Bool {
        let url = warning.documentURL.lowercased()
        return url.contains("/sourcepackages/") ||
               url.contains("/checkouts/") ||
               url.contains("/.build/") ||
               url.contains("/deriveddata/") && url.contains("/sourcepackages/")
    }

    private func buildDirectoryTree() -> [DirectoryNode] {
        let projectWarnings = warnings.filter { !isPackageDependency($0) && !$0.documentURL.isEmpty }
        guard !projectWarnings.isEmpty else { return [] }

        // Count warnings per file (not directory)
        var pathCounts: [String: Int] = [:]
        for warning in projectWarnings {
            let filePath = getFilePath(from: warning.documentURL)
            guard !filePath.isEmpty else { continue }
            pathCounts[filePath, default: 0] += 1
        }

        guard !pathCounts.isEmpty else { return [] }

        let allPaths = Array(pathCounts.keys).sorted()
        let commonPrefix = findCommonPathPrefix(allPaths)

        class MutableNode {
            let name: String
            let path: String
            let isFile: Bool
            var children: [String: MutableNode] = [:]
            var directCount: Int = 0

            init(name: String, path: String, isFile: Bool = false) {
                self.name = name
                self.path = path
                self.isFile = isFile
            }

            var totalCount: Int {
                directCount + children.values.reduce(0) { $0 + $1.totalCount }
            }

            func getOrCreateChild(name: String, path: String, isFile: Bool = false) -> MutableNode {
                if let existing = children[name] {
                    return existing
                }
                let node = MutableNode(name: name, path: path, isFile: isFile)
                children[name] = node
                return node
            }

            func toDirectoryNode() -> DirectoryNode {
                DirectoryNode(
                    id: path,
                    name: name,
                    path: path,
                    children: children.values
                        .map { $0.toDirectoryNode() }
                        .sorted { $0.warningCount > $1.warningCount },
                    warningCount: totalCount
                )
            }
        }

        let rootContainer = MutableNode(name: "", path: commonPrefix)

        for (fullPath, count) in pathCounts {
            var relativePath = fullPath
            if fullPath.hasPrefix(commonPrefix) {
                relativePath = String(fullPath.dropFirst(commonPrefix.count))
                if relativePath.hasPrefix("/") {
                    relativePath = String(relativePath.dropFirst())
                }
            }

            let components = relativePath.split(separator: "/").map(String.init)
            guard !components.isEmpty else { continue }

            var currentNode = rootContainer
            var currentPath = commonPrefix

            for (index, component) in components.enumerated() {
                currentPath += "/" + component
                let isLastComponent = index == components.count - 1
                currentNode = currentNode.getOrCreateChild(
                    name: component,
                    path: currentPath,
                    isFile: isLastComponent
                )

                if isLastComponent {
                    currentNode.directCount += count
                }
            }
        }

        return rootContainer.children.values
            .map { $0.toDirectoryNode() }
            .sorted { $0.warningCount > $1.warningCount }
    }

    private func getFilePath(from documentURL: String) -> String {
        guard !documentURL.isEmpty else { return "" }

        if documentURL.hasPrefix("file://") {
            if let url = URL(string: documentURL) {
                return url.path
            }
            if let decoded = documentURL.removingPercentEncoding,
               let url = URL(string: decoded) {
                return url.path
            }
            let pathPart = String(documentURL.dropFirst(7))
            return URL(fileURLWithPath: pathPart).path
        }

        return URL(fileURLWithPath: documentURL).path
    }

    private func findCommonPathPrefix(_ paths: [String]) -> String {
        guard let first = paths.first else { return "" }

        let firstComponents = first.split(separator: "/").map(String.init)
        var commonComponents: [String] = []

        for (index, component) in firstComponents.enumerated() {
            let allMatch = paths.allSatisfy { path in
                let components = path.split(separator: "/").map(String.init)
                return index < components.count && components[index] == component
            }
            if allMatch {
                commonComponents.append(component)
            } else {
                break
            }
        }

        if commonComponents.count > 0 {
            commonComponents.removeLast()
        }

        return "/" + commonComponents.joined(separator: "/")
    }
}
