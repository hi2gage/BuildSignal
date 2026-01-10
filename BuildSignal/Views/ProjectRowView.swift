import SwiftUI

/// A single row in the project list showing project name, status, and build info.
struct ProjectRowView: View {
    let project: XcodeProject

    var body: some View {
        HStack(spacing: 12) {
            // Status indicator
            statusIndicator

            VStack(alignment: .leading, spacing: 4) {
                // Project name
                Text(project.displayName)
                    .font(.headline)
                    .lineLimit(1)

                // Last build info
                if let latestBuild = project.latestBuild {
                    HStack(spacing: 8) {
                        // Relative time
                        Text(latestBuild.endTime, style: .relative)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        // Warning badge
                        if latestBuild.warningCount > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text("\(latestBuild.warningCount)")
                            }
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                        }

                        // Error badge
                        if latestBuild.errorCount > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "xmark.circle.fill")
                                Text("\(latestBuild.errorCount)")
                            }
                            .font(.caption2)
                            .foregroundStyle(.red)
                        }
                    }
                } else {
                    Text("No builds")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                // Project path
                Text(project.workspacePath.path)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var statusIndicator: some View {
        if let latestBuild = project.latestBuild {
            Image(systemName: latestBuild.status.icon)
                .font(.title2)
                .foregroundStyle(latestBuild.status.color)
        } else {
            Image(systemName: "questionmark.circle")
                .font(.title2)
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    List {
        ProjectRowView(project: XcodeProject(
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
                    warningCount: 42,
                    errorCount: 0,
                    analyzerIssueCount: 0,
                    testFailureCount: 0,
                    startTime: Date().addingTimeInterval(-3600),
                    endTime: Date().addingTimeInterval(-3590)
                )
            ]
        ))

        ProjectRowView(project: XcodeProject(
            id: "another-xyz789",
            name: "AnotherProject",
            workspacePath: URL(fileURLWithPath: "/Users/test/Projects/AnotherProject/AnotherProject.xcworkspace"),
            derivedDataPath: URL(fileURLWithPath: "/Users/test/Library/Developer/Xcode/DerivedData/AnotherProject-xyz789"),
            lastAccessedDate: Date().addingTimeInterval(-86400),
            builds: []
        ))
    }
    .frame(width: 350)
}
