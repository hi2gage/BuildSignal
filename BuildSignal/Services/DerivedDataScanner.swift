import Foundation

/// Scans DerivedData folder to discover Xcode projects and their build history.
/// Uses Swift actor for thread-safe async operations.
actor DerivedDataScanner {

    // MARK: - Errors

    enum ScanError: LocalizedError {
        case derivedDataNotFound
        case noProjectsFound
        case plistParsingFailed(path: String)

        var errorDescription: String? {
            switch self {
            case .derivedDataNotFound:
                return "DerivedData folder not found. Make sure you've built a project in Xcode."
            case .noProjectsFound:
                return "No Xcode projects found in DerivedData."
            case .plistParsingFailed(let path):
                return "Failed to parse plist at \(path)"
            }
        }
    }

    // MARK: - Properties

    private let derivedDataURL: URL
    private let fileManager = FileManager.default

    // MARK: - Initialization

    init(derivedDataPath: URL? = nil) {
        self.derivedDataURL = derivedDataPath ?? Self.defaultDerivedDataURL
    }

    static var defaultDerivedDataURL: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Developer/Xcode/DerivedData")
    }

    // MARK: - Public API

    /// Scans DerivedData and returns all discovered projects sorted by most recent build.
    func scanProjects() async throws -> [XcodeProject] {
        guard fileManager.fileExists(atPath: derivedDataURL.path) else {
            throw ScanError.derivedDataNotFound
        }

        let projectFolders = try await discoverProjectFolders()

        // Parse projects in parallel for performance
        let projects = await withTaskGroup(of: XcodeProject?.self) { group in
            for folder in projectFolders {
                group.addTask {
                    await self.parseProject(at: folder)
                }
            }

            var results: [XcodeProject] = []
            for await project in group {
                if let project = project {
                    results.append(project)
                }
            }
            return results
        }

        guard !projects.isEmpty else {
            throw ScanError.noProjectsFound
        }

        // Sort by most recent build (or last accessed date if no builds)
        return projects.sorted { project1, project2 in
            let date1 = project1.latestBuild?.endTime ?? project1.lastAccessedDate
            let date2 = project2.latestBuild?.endTime ?? project2.lastAccessedDate
            return date1 > date2
        }
    }

    // MARK: - Private Methods

    /// Discovers valid project folders in DerivedData (skips cache directories).
    private func discoverProjectFolders() async throws -> [URL] {
        let contents = try fileManager.contentsOfDirectory(
            at: derivedDataURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        )

        return contents.filter { url in
            let name = url.lastPathComponent
            // Skip cache and index directories
            guard !name.hasSuffix(".noindex") else { return false }
            guard !name.hasPrefix("ModuleCache") else { return false }
            // Must have info.plist to be a valid project
            let infoPlist = url.appendingPathComponent("info.plist")
            return fileManager.fileExists(atPath: infoPlist.path)
        }
    }

    /// Parses a single project folder and extracts metadata.
    func parseProject(at folderURL: URL) async -> XcodeProject? {
        let infoPlistURL = folderURL.appendingPathComponent("info.plist")
        let logManifestURL = folderURL
            .appendingPathComponent("Logs/Build/LogStoreManifest.plist")

        // Parse info.plist (required)
        guard let infoDict = NSDictionary(contentsOf: infoPlistURL),
              let workspacePathString = infoDict["WorkspacePath"] as? String,
              let lastAccessedDate = infoDict["LastAccessedDate"] as? Date else {
            return nil
        }

        let workspacePath = URL(fileURLWithPath: workspacePathString)

        // Parse LogStoreManifest.plist (optional - may not exist if never built)
        let builds: [BuildLog]
        if let logDict = NSDictionary(contentsOf: logManifestURL),
           let logsDict = logDict["logs"] as? [String: Any] {
            builds = parseBuilds(from: logsDict)
        } else {
            builds = []
        }

        // Extract project name from folder name (ProjectName-hash pattern)
        let folderName = folderURL.lastPathComponent
        let projectName = extractProjectName(from: folderName)

        return XcodeProject(
            id: folderName,
            name: projectName,
            workspacePath: workspacePath,
            derivedDataPath: folderURL,
            lastAccessedDate: lastAccessedDate,
            builds: builds.sorted { $0.endTime > $1.endTime }
        )
    }

    /// Parses build logs from the LogStoreManifest.plist logs dictionary.
    private func parseBuilds(from logsDict: [String: Any]) -> [BuildLog] {
        logsDict.compactMap { (key, value) -> BuildLog? in
            guard let logEntry = value as? [String: Any] else { return nil }

            // Only process build logs
            let domainType = logEntry["domainType"] as? String ?? ""
            guard domainType.contains("BuildLog") else { return nil }

            guard let observable = logEntry["primaryObservable"] as? [String: Any],
                  let statusString = observable["highLevelStatus"] as? String,
                  let status = BuildStatus(rawValue: statusString),
                  let startTime = logEntry["timeStartedRecording"] as? Double,
                  let endTime = logEntry["timeStoppedRecording"] as? Double else {
                return nil
            }

            return BuildLog(
                id: key,
                fileName: logEntry["fileName"] as? String ?? "",
                schemeName: logEntry["schemeIdentifier-schemeName"] as? String ?? "Unknown",
                containerName: logEntry["schemeIdentifier-containerName"] as? String ?? "",
                title: logEntry["title"] as? String ?? "Build",
                status: status,
                warningCount: observable["totalNumberOfWarnings"] as? Int ?? 0,
                errorCount: observable["totalNumberOfErrors"] as? Int ?? 0,
                analyzerIssueCount: observable["totalNumberOfAnalyzerIssues"] as? Int ?? 0,
                testFailureCount: observable["totalNumberOfTestFailures"] as? Int ?? 0,
                startTime: Date(timeIntervalSinceReferenceDate: startTime),
                endTime: Date(timeIntervalSinceReferenceDate: endTime)
            )
        }
    }

    /// Extracts the project name from a DerivedData folder name.
    /// Folder format: "ProjectName-28charHash"
    private func extractProjectName(from folderName: String) -> String {
        // Find the last hyphen and take everything before it
        if let lastHyphenIndex = folderName.lastIndex(of: "-") {
            let name = String(folderName[..<lastHyphenIndex])
            // Replace underscores with spaces for display
            return name.replacingOccurrences(of: "_", with: " ")
        }
        return folderName
    }
}
