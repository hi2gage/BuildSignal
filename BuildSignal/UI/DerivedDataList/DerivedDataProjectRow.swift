import SwiftUI

/// A row displaying a single project in the DerivedData browser.
struct DerivedDataProjectRow: View {
    let project: XcodeProject

    var body: some View {
        HStack(spacing: 12) {
            projectIcon
            projectInfo
            Spacer()
            buildInfo
        }
        .padding(.vertical, 6)
    }

    // MARK: - Project Icon

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

    private var iconName: String {
        project.workspaceType == "xcworkspace" ? "folder.fill" : "hammer.fill"
    }

    // MARK: - Project Info

    private var projectInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(project.displayName)
                .font(.headline)
                .lineLimit(1)

            Text(project.workspacePath.path)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }

    // MARK: - Build Info

    @ViewBuilder
    private var buildInfo: some View {
        if let build = project.latestBuild {
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 6) {
                    if build.warningCount > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.yellow)
                            Text("\(build.warningCount)")
                                .fontWeight(.medium)
                        }
                        .font(.caption)
                    }

                    Image(systemName: build.status.icon)
                        .foregroundStyle(build.status.color)
                }

                Text(build.endTime, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        } else {
            Text("No builds")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .italic()
        }
    }
}
