import SwiftUI

/// Displays the list of recently opened projects in the welcome window.
struct RecentProjectsListView: View {
    let recentProjects: [RecentProject]
    let onSelect: (RecentProject) -> Void
    let onRemove: (RecentProject) -> Void

    var body: some View {
        if recentProjects.isEmpty {
            emptyState
        } else {
            projectList
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "clock")
                .font(.title)
                .foregroundStyle(.tertiary)
            Text("No Recent Projects")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("Projects you open will appear here")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private var projectList: some View {
        List {
            ForEach(recentProjects) { project in
                RecentProjectRow(project: project)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onSelect(project)
                    }
                    .contextMenu {
                        Button("Show in Finder") {
                            NSWorkspace.shared.selectFile(
                                project.path.path,
                                inFileViewerRootedAtPath: project.path.deletingLastPathComponent().path
                            )
                        }
                        Divider()
                        Button("Remove from Recent", role: .destructive) {
                            onRemove(project)
                        }
                    }
            }
        }
        .listStyle(.plain)
    }
}

/// A single row displaying a recent project.
struct RecentProjectRow: View {
    let project: RecentProject

    var body: some View {
        HStack(spacing: 12) {
            projectIcon
            projectInfo
            Spacer()
            timestamp
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var projectIcon: some View {
        if let appIcon = project.appIcon {
            Image(nsImage: appIcon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
        } else {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 32, height: 32)
        }
    }

    private var projectInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(project.name)
                .font(.headline)
                .lineLimit(1)

            Text(project.path.path)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }

    private var timestamp: some View {
        Text(project.lastOpened, style: .relative)
            .font(.caption)
            .foregroundStyle(.tertiary)
    }

    private var iconName: String {
        project.path.pathExtension == "xcworkspace" ? "folder.fill" : "hammer.fill"
    }
}
