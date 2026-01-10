import SwiftUI
import UniformTypeIdentifiers

/// Detail view showing information about the selected project with tabs.
struct ProjectDetailView: View {
    let project: XcodeProject
    @StateObject private var viewModel: ProjectDetailViewModel

    init(project: XcodeProject) {
        self.project = project
        self._viewModel = StateObject(wrappedValue: ProjectDetailViewModel(project: project))
    }

    var body: some View {
        TabView {
            // Overview Tab
            OverviewTabView(project: project, viewModel: viewModel)
                .tabItem {
                    Label("Overview", systemImage: "info.circle")
                }

            // Warnings List Tab
            WarningsListView(warnings: viewModel.warnings)
                .tabItem {
                    Label("Warnings", systemImage: "exclamationmark.triangle")
                }
                .badge(viewModel.warnings.count)

            // Raw JSON Tab
            RawJSONTabView(viewModel: viewModel)
                .tabItem {
                    Label("Raw JSON", systemImage: "curlybraces")
                }
        }
        .padding()
    }
}

// MARK: - Overview Tab

private struct OverviewTabView: View {
    let project: XcodeProject
    @ObservedObject var viewModel: ProjectDetailViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                Divider()

                if let latestBuild = project.latestBuild {
                    buildSummarySection(latestBuild)
                } else {
                    noBuildSection
                }

                Divider()
                actionsSection

                Spacer()
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: projectIcon)
                .font(.system(size: 48))
                .foregroundStyle(.tint)

            Text(project.displayName)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(project.workspacePath.path)
                .font(.caption)
                .foregroundStyle(.secondary)
                .textSelection(.enabled)
                .multilineTextAlignment(.center)

            Text(project.workspaceType == "xcworkspace" ? "Workspace" : "Project")
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(.quaternary)
                .clipShape(Capsule())
        }
    }

    private var projectIcon: String {
        project.workspaceType == "xcworkspace" ? "folder.fill" : "hammer.fill"
    }

    // MARK: - Build Summary

    private func buildSummarySection(_ build: BuildLog) -> some View {
        GroupBox {
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: build.status.icon)
                        .font(.title)
                        .foregroundStyle(build.status.color)

                    Text(build.status.label)
                        .font(.title2)
                        .fontWeight(.semibold)

                    Spacer()

                    Text(build.endTime, style: .relative)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Divider()

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    buildStatCard(title: "Duration", value: build.formattedDuration, icon: "timer", color: .blue)
                    buildStatCard(title: "Warnings", value: "\(build.warningCount)", icon: "exclamationmark.triangle.fill", color: build.warningCount > 0 ? .yellow : .gray)
                    buildStatCard(title: "Errors", value: "\(build.errorCount)", icon: "xmark.circle.fill", color: build.errorCount > 0 ? .red : .gray)
                }

                HStack {
                    Label(build.schemeName, systemImage: "target")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("Build #\(project.builds.count)")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(8)
        } label: {
            Label("Latest Build", systemImage: "clock.arrow.circlepath")
        }
    }

    private func buildStatCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title3)
                .fontWeight(.semibold)

            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    // MARK: - No Build

    private var noBuildSection: some View {
        GroupBox {
            VStack(spacing: 12) {
                Image(systemName: "hammer.circle")
                    .font(.system(size: 36))
                    .foregroundStyle(.tertiary)

                Text("No Build History")
                    .font(.headline)

                Text("Build this project in Xcode to see build information here.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
        } label: {
            Label("Build Status", systemImage: "clock.arrow.circlepath")
        }
    }

    // MARK: - Actions

    private var actionsSection: some View {
        VStack(spacing: 16) {
            // Primary action - Analyze
            if viewModel.hasLatestBuild {
                analyzeButton
            }

            // Secondary actions
            HStack(spacing: 16) {
                Button {
                    NSWorkspace.shared.open(project.workspacePath)
                } label: {
                    Label("Open in Xcode", systemImage: "hammer")
                }

                Button {
                    NSWorkspace.shared.selectFile(
                        project.workspacePath.path,
                        inFileViewerRootedAtPath: project.workspacePath.deletingLastPathComponent().path
                    )
                } label: {
                    Label("Show in Finder", systemImage: "folder")
                }
            }
        }
    }

    @ViewBuilder
    private var analyzeButton: some View {
        switch viewModel.parsingState {
        case .idle:
            Button {
                Task { await viewModel.parseLatestBuild() }
            } label: {
                Label("Analyze Build Log", systemImage: "wand.and.stars")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

        case .parsing:
            HStack(spacing: 12) {
                ProgressView()
                    .controlSize(.small)
                Text("Analyzing...")
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 8)

        case .parsed:
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("Analysis complete")
                    .foregroundStyle(.secondary)
                Text("•")
                    .foregroundStyle(.tertiary)
                Text("\(viewModel.warnings.count) warnings")
                    .foregroundStyle(.yellow)
            }
            .font(.callout)

        case .error(let message):
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                    Text("Analysis failed")
                        .foregroundStyle(.secondary)
                }
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                Button("Retry") {
                    Task { await viewModel.parseLatestBuild() }
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

// MARK: - Raw JSON Tab

private struct RawJSONTabView: View {
    @ObservedObject var viewModel: ProjectDetailViewModel

    var body: some View {
        VStack {
            switch viewModel.parsingState {
            case .idle:
                idleView

            case .parsing:
                parsingView

            case .parsed(let json):
                jsonView(json)

            case .error(let message):
                errorView(message)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var idleView: some View {
        ContentUnavailableView {
            Label("No Build Selected", systemImage: "doc.text")
        } description: {
            Text("Select a project with build history to view the parsed log.")
        }
    }

    private var parsingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Parsing build log...")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("This may take a moment for large builds")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    private func jsonView(_ json: String) -> some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                Text("Parsed Build Log")
                    .font(.headline)

                Spacer()

                Button {
                    saveToFile(json)
                } label: {
                    Label("Save", systemImage: "square.and.arrow.down")
                }
                .buttonStyle(.bordered)

                Button {
                    copyToClipboard(json)
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
                .buttonStyle(.bordered)

                Text("\(json.count.formatted()) chars")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()

            Divider()

            // JSON content - use NSTextView wrapper for large content
            JSONTextView(text: json)
        }
    }

    private func saveToFile(_ json: String) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "build-log.json"

        if panel.runModal() == .OK, let url = panel.url {
            try? json.write(to: url, atomically: true, encoding: .utf8)
        }
    }

    private func errorView(_ message: String) -> some View {
        ContentUnavailableView {
            Label("Parsing Failed", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Retry") {
                Task {
                    await viewModel.parseLatestBuild()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}

#Preview {
    ProjectDetailView(
        project: XcodeProject(
            id: "test-abc123",
            name: "TestProject",
            workspacePath: URL(fileURLWithPath: "/Users/test/Projects/TestProject/TestProject.xcodeproj"),
            derivedDataPath: URL(fileURLWithPath: "/Users/test/Library/Developer/Xcode/DerivedData/TestProject-abc123"),
            lastAccessedDate: Date(),
            builds: [
                BuildLog(
                    id: "build-1",
                    fileName: "build.xcactivitylog",
                    schemeName: "TestProject",
                    containerName: "TestProject project",
                    title: "Build TestProject",
                    status: .warning,
                    warningCount: 142,
                    errorCount: 0,
                    analyzerIssueCount: 3,
                    testFailureCount: 0,
                    startTime: Date().addingTimeInterval(-3600),
                    endTime: Date().addingTimeInterval(-3545)
                )
            ]
        )
    )
    .frame(width: 600, height: 700)
}
