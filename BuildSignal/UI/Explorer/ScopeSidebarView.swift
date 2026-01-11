import SwiftUI

/// Sidebar view for selecting the warning scope/filter.
struct ScopeSidebarView: View {
    @ObservedObject var viewModel: ProjectDetailViewModel

    /// The currently selected directory path (nil if a non-directory scope is selected)
    private var selectedDirectoryPath: String? {
        if case .directory(let path, _) = viewModel.selectedScope {
            return path
        }
        return nil
    }

    var body: some View {
        VStack(spacing: 0) {
            // Scope filter section (SwiftUI)
            ScopeFilterSection(viewModel: viewModel)
                .padding(.top, 8)

            if !viewModel.directoryTree.isEmpty {
                Divider()
                    .padding(.vertical, 8)

                // Section header
                HStack {
                    Text("Directories")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 4)

                // Directory tree (NSOutlineView)
                ScopeOutlineView(
                    nodes: viewModel.directoryTree,
                    selectedPath: selectedDirectoryPath,
                    onSelect: { path, name in
                        viewModel.selectedScope = .directory(path: path, name: name)
                    }
                )
            }
        }
    }
}

// MARK: - Scope Filter Section

private struct ScopeFilterSection: View {
    @ObservedObject var viewModel: ProjectDetailViewModel

    var body: some View {
        VStack(spacing: 2) {
            scopeButton(item: .all, count: viewModel.activeTotalCount)

            if viewModel.activeProjectCount > 0 {
                scopeButton(item: .project, count: viewModel.activeProjectCount)
            }

            if viewModel.activePackageCount > 0 {
                scopeButton(item: .packageDependencies, count: viewModel.activePackageCount)
            }
        }
        .padding(.horizontal, 8)
    }

    private func scopeButton(item: ScopeItem, count: Int) -> some View {
        Button {
            viewModel.selectedScope = item
        } label: {
            HStack(spacing: 8) {
                Image(systemName: item.icon)
                    .font(.system(size: 12))
                    .frame(width: 16)
                Text(item.displayName)
                    .font(.system(size: 13))
                Spacer()
                Text("\(count)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 3))
            }
            .contentShape(Rectangle())
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
        .foregroundStyle(viewModel.selectedScope == item ? Color.accentColor : Color.primary)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(viewModel.selectedScope == item ? Color.accentColor.opacity(0.15) : Color.clear)
        )
    }
}
