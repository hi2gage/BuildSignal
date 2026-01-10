import SwiftUI

/// Main view for selecting an Xcode project to analyze.
/// Uses NavigationSplitView with a sidebar list and detail pane.
struct ProjectSelectionView: View {
    @StateObject private var viewModel = ProjectSelectionViewModel()
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var selection: XcodeProject?

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sidebarContent
                .navigationTitle("Projects")
                .navigationSplitViewColumnWidth(min: 280, ideal: 320, max: 400)
                .searchable(text: $viewModel.searchText, prompt: "Search projects...")
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button {
                            Task { await viewModel.refresh() }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        .help("Refresh project list")
                        .disabled(viewModel.state == .loading)
                    }
                }
        } detail: {
            detailContent
        }
        .task {
            await viewModel.loadProjects()
        }
        .onChange(of: selection) { _, newValue in
            viewModel.selectedProject = newValue
        }
    }

    // MARK: - Sidebar Content

    @ViewBuilder
    private var sidebarContent: some View {
        switch viewModel.state {
        case .idle, .loading:
            loadingView

        case .loaded(let projects) where projects.isEmpty:
            emptyStateView

        case .loaded:
            projectList

        case .error(let message):
            errorView(message: message)
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Scanning DerivedData...")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Looking for Xcode projects")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Projects Found", systemImage: "folder.badge.questionmark")
        } description: {
            Text("Build a project in Xcode to see it here.")
        } actions: {
            Button("Refresh") {
                Task { await viewModel.refresh() }
            }
        }
    }

    private var projectList: some View {
        List(viewModel.filteredProjects, selection: $selection) { project in
            ProjectRowView(project: project)
                .tag(project)
                .contextMenu {
                    Button {
                        viewModel.openInXcode(project)
                    } label: {
                        Label("Open in Xcode", systemImage: "hammer")
                    }

                    Button {
                        viewModel.revealInFinder(project)
                    } label: {
                        Label("Show in Finder", systemImage: "folder")
                    }

                    Divider()

                    Button {
                        copyPath(project.workspacePath.path)
                    } label: {
                        Label("Copy Path", systemImage: "doc.on.doc")
                    }
                }
        }
        .listStyle(.sidebar)
    }

    private func errorView(message: String) -> some View {
        ContentUnavailableView {
            Label("Unable to Load Projects", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Try Again") {
                Task { await viewModel.refresh() }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Detail Content

    @ViewBuilder
    private var detailContent: some View {
        if let project = viewModel.selectedProject {
            ProjectDetailView(project: project)
        } else {
            ContentUnavailableView {
                Label("Select a Project", systemImage: "sidebar.left")
            } description: {
                Text("Choose a project from the sidebar to view its build history.")
            }
        }
    }

    // MARK: - Helpers

    private func copyPath(_ path: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(path, forType: .string)
    }
}

#Preview {
    ProjectSelectionView()
        .frame(width: 800, height: 600)
}
