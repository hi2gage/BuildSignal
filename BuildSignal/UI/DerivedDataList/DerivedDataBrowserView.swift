import SwiftUI

/// A view that displays all projects found in DerivedData.
/// Clicking a project triggers the onSelectProject callback.
struct DerivedDataBrowserView: View {
    let onSelectProject: (XcodeProject) -> Void
    @StateObject private var viewModel = DerivedDataBrowserViewModel()
    @State private var searchText = ""

    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()
            searchBar
                .padding(.top, 12)
            contentView
        }
        .frame(width: 600, height: 500)
        .task {
            await viewModel.loadProjects()
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("DerivedData Projects")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Click a project to analyze")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(0.7)
            }

            Button {
                Task { await viewModel.refresh() }
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.isLoading)
        }
        .padding()
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search projects...", text: $searchText)
                .textFieldStyle(.plain)
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(.quaternary)
        .cornerRadius(8)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    // MARK: - Content

    @ViewBuilder
    private var contentView: some View {
        if viewModel.projects.isEmpty && viewModel.isLoading {
            loadingView
        } else if viewModel.projects.isEmpty && viewModel.error != nil {
            errorView(message: viewModel.error!)
        } else if viewModel.projects.isEmpty {
            emptyStateView
        } else {
            projectListView
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Scanning DerivedData...")
                .font(.headline)
                .foregroundStyle(.secondary)
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
            .buttonStyle(.borderedProminent)
        }
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

    private var projectListView: some View {
        List(filteredProjects) { project in
            DerivedDataProjectRow(project: project)
                .contentShape(Rectangle())
                .onTapGesture {
                    onSelectProject(project)
                }
        }
        .listStyle(.inset)
    }

    // MARK: - Helpers

    private var filteredProjects: [XcodeProject] {
        if searchText.isEmpty {
            return viewModel.projects
        }
        let query = searchText.lowercased()
        return viewModel.projects.filter {
            $0.displayName.lowercased().contains(query) ||
            $0.workspacePath.path.lowercased().contains(query)
        }
    }
}
