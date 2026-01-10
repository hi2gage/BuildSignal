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

    // MARK: - Initialization

    init(project: XcodeProject) {
        self.project = project
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
    }
}
