import SwiftUI

/// The main project view with a sidebar and detail pane.
struct MainProjectView: View {
    let project: XcodeProject
    @StateObject private var viewModel: ProjectDetailViewModel
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    init(project: XcodeProject) {
        self.project = project
        self._viewModel = StateObject(wrappedValue: ProjectDetailViewModel(project: project))
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            ScopeSidebarView(viewModel: viewModel)
                .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 350)
        } detail: {
            ProjectDetailContent(viewModel: viewModel)
        }
        .navigationTitle(project.displayName)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task {
                        await viewModel.parseLatestBuild()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .keyboardShortcut("r", modifiers: .command)
                .help("Refresh from DerivedData")
                .disabled(viewModel.parsingState == .parsing)
            }
        }
        .task {
            // Automatically start analysis when project is opened
            if viewModel.hasLatestBuild && viewModel.parsingState == .idle {
                await viewModel.parseLatestBuild()
            }
        }
        .overlay {
            if case .parsing = viewModel.parsingState {
                AnalyzingOverlay()
            }
        }
    }
}

// MARK: - Analyzing Overlay

private struct AnalyzingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)

                Text("Analyzing Build Log...")
                    .font(.headline)
                    .foregroundStyle(.white)

                Text("This may take a moment")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(32)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }
}
