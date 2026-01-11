import SwiftUI

/// Sidebar view for selecting the warning scope/filter.
struct ScopeSidebarView: View {
    @ObservedObject var viewModel: ProjectDetailViewModel

    var body: some View {
        List {
            Section("Scope") {
                // All
                scopeButton(item: .all, count: viewModel.warnings.count)

                // Project
                if viewModel.projectWarningCount > 0 {
                    scopeButton(item: .project, count: viewModel.projectWarningCount)
                }

                // Package Dependencies
                if viewModel.packageWarningCount > 0 {
                    scopeButton(item: .packageDependencies, count: viewModel.packageWarningCount)
                }
            }

            if !viewModel.directoryTree.isEmpty {
                Section("Directories") {
                    ForEach(viewModel.directoryTree) { node in
                        DirectoryTreeSidebarRow(
                            node: node,
                            selectedScope: viewModel.selectedScope,
                            onSelect: { scope in
                                Task { @MainActor in
                                    viewModel.selectedScope = scope
                                }
                            }
                        )
                    }
                }
            }
        }
        .listStyle(.sidebar)
    }

    private func scopeButton(item: ScopeItem, count: Int) -> some View {
        Button {
            Task { @MainActor in
                viewModel.selectedScope = item
            }
        } label: {
            HStack {
                Label(item.displayName, systemImage: item.icon)
                    .foregroundStyle(viewModel.selectedScope == item ? Color.accentColor : Color.primary)
                Spacer()
                Text("\(count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(4)
            }
        }
        .buttonStyle(.plain)
        .listRowBackground(viewModel.selectedScope == item ? Color.accentColor.opacity(0.15) : Color.clear)
    }
}

// MARK: - Directory Tree Sidebar Row

private struct DirectoryTreeSidebarRow: View {
    let node: DirectoryNode
    let selectedScope: ScopeItem
    let onSelect: (ScopeItem) -> Void

    private var isSelected: Bool {
        if case .directory(let path, _) = selectedScope {
            return path == node.path
        }
        return false
    }

    private var thisScope: ScopeItem {
        .directory(path: node.path, name: node.name)
    }

    var body: some View {
        if node.children.isEmpty {
            // Leaf node - just a button
            Button {
                onSelect(thisScope)
            } label: {
                rowContent
            }
            .buttonStyle(.plain)
            .listRowBackground(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
        } else {
            // Has children - disclosure group
            DisclosureGroup {
                ForEach(node.children) { child in
                    DirectoryTreeSidebarRow(
                        node: child,
                        selectedScope: selectedScope,
                        onSelect: onSelect
                    )
                }
            } label: {
                Button {
                    onSelect(thisScope)
                } label: {
                    rowContent
                }
                .buttonStyle(.plain)
            }
            .listRowBackground(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
        }
    }

    private var rowContent: some View {
        HStack {
            Label(node.name, systemImage: node.children.isEmpty ? "doc" : "folder")
                .foregroundStyle(isSelected ? Color.accentColor : Color.primary)
            Spacer()
            Text("\(node.warningCount)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(4)
        }
    }
}
