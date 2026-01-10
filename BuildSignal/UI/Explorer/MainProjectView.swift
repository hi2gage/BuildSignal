import SwiftUI

/// The main project view with a sidebar and detail pane.
struct MainProjectView: View {
    let project: XcodeProject
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sidebar
        } detail: {
            ProjectDetailView(project: project)
        }
        .navigationTitle(project.displayName)
    }

    // MARK: - Sidebar

    private var sidebar: some View {
        List {
            Section("Project") {
                Label(project.displayName, systemImage: "hammer.fill")
            }

            Section("Analysis") {
                Label("Overview", systemImage: "info.circle")
                Label("Warnings", systemImage: "exclamationmark.triangle")
                Label("Raw JSON", systemImage: "curlybraces")
            }
        }
        .listStyle(.sidebar)
        .navigationSplitViewColumnWidth(min: 180, ideal: 220, max: 300)
    }
}
