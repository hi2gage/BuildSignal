import Foundation
import XCLogParser

/// Service for parsing Xcode build logs using XCLogParser.
actor LogParserService {

    // MARK: - Errors

    enum ParserError: LocalizedError {
        case logFileNotFound(String)
        case parsingFailed(String)
        case encodingFailed

        var errorDescription: String? {
            switch self {
            case .logFileNotFound(let path):
                return "Build log not found at: \(path)"
            case .parsingFailed(let message):
                return "Failed to parse build log: \(message)"
            case .encodingFailed:
                return "Failed to encode parsed data to JSON"
            }
        }
    }

    // MARK: - Public API

    /// Parses a build log and returns the BuildStep tree.
    func parseBuildLog(at url: URL) async throws -> BuildStep {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw ParserError.logFileNotFound(url.path)
        }

        do {
            // Step 1: Parse the raw activity log
            let activityParser = ActivityParser()
            let activityLog = try activityParser.parseActivityLogInURL(
                url,
                redacted: false,
                withoutBuildSpecificInformation: false
            )

            // Step 2: Convert to BuildStep tree
            let buildStepsParser = ParserBuildSteps(
                machineName: nil,
                omitWarningsDetails: false,
                omitNotesDetails: false,
                truncLargeIssues: false
            )

            let buildStep = try buildStepsParser.parse(activityLog: activityLog)
            return buildStep

        } catch {
            throw ParserError.parsingFailed(error.localizedDescription)
        }
    }

    /// Parses a build log and returns it as JSON data.
    func parseBuildLogAsJSON(at url: URL) async throws -> Data {
        let buildStep = try await parseBuildLog(at: url)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        guard let jsonData = try? encoder.encode(buildStep) else {
            throw ParserError.encodingFailed
        }

        return jsonData
    }

    /// Parses a build log and returns it as a JSON string.
    func parseBuildLogAsJSONString(at url: URL) async throws -> String {
        let jsonData = try await parseBuildLogAsJSON(at: url)
        return String(data: jsonData, encoding: .utf8) ?? "{}"
    }

    /// Extracts all warnings from a parsed build log.
    func extractWarnings(from buildStep: BuildStep) -> [Notice] {
        var warnings: [Notice] = []
        collectWarnings(from: buildStep, into: &warnings)
        return warnings
    }

    /// Extracts all errors from a parsed build log.
    func extractErrors(from buildStep: BuildStep) -> [Notice] {
        var errors: [Notice] = []
        collectErrors(from: buildStep, into: &errors)
        return errors
    }

    // MARK: - Private Helpers

    private func collectWarnings(from step: BuildStep, into warnings: inout [Notice]) {
        if let stepWarnings = step.warnings {
            warnings.append(contentsOf: stepWarnings)
        }
        for subStep in step.subSteps {
            collectWarnings(from: subStep, into: &warnings)
        }
    }

    private func collectErrors(from step: BuildStep, into errors: inout [Notice]) {
        if let stepErrors = step.errors {
            errors.append(contentsOf: stepErrors)
        }
        for subStep in step.subSteps {
            collectErrors(from: subStep, into: &errors)
        }
    }
}
