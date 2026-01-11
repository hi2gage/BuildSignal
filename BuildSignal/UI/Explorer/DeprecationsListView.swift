import AppKit
import SwiftUI
import XCLogParser

/// Displays a list of deprecation warnings grouped by message.
struct DeprecationsListView: View {
    @ObservedObject var viewModel: ProjectDetailViewModel
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    @StateObject private var selectionManager = SelectionManager<IdentifiedDeprecation>()
    @State private var searchText = ""
    @State private var showFavoritesOnly = false

    private var selectedScope: ScopeItem { viewModel.selectedScope }

    private var deprecations: [Notice] {
        viewModel.warnings.filter { $0.type == .deprecatedWarning }
    }

    private var filteredDeprecations: [Notice] {
        var result = deprecations

        // Apply scope filter
        result = result.filter { matchesScope($0) }

        // Apply search filter
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.title.lowercased().contains(query) ||
                $0.documentURL.lowercased().contains(query)
            }
        }

        // Apply favorites filter
        if showFavoritesOnly {
            result = result.filter { isFavorite($0.title) }
        }

        return result
    }

    private var allIdentifiedItems: [IdentifiedDeprecation] {
        filteredDeprecations.enumerated().map { IdentifiedDeprecation($0.element, index: $0.offset) }
    }

    private var groupedByMessage: [(message: String, items: [IdentifiedDeprecation], isFavorite: Bool)] {
        let grouped = Dictionary(grouping: filteredDeprecations.enumerated().map { ($0.offset, $0.element) }) {
            $0.1.title
        }
        return grouped
            .map { (message: $0.key,
                    items: $0.value.map { IdentifiedDeprecation($0.1, index: $0.0) }
                        .sorted { $0.notice.documentURL < $1.notice.documentURL },
                    isFavorite: isFavorite($0.key)) }
            .sorted {
                // Sort by count descending, then by message alphabetically for stability
                // (favorites are visually marked but don't affect sort order)
                if $0.items.count != $1.items.count {
                    return $0.items.count > $1.items.count
                }
                return $0.message < $1.message
            }
    }

    private var favoritesCount: Int {
        Set(deprecations.map(\.title)).filter { isFavorite($0) }.count
    }

    // MARK: - Favorites Helpers

    private func isFavorite(_ message: String) -> Bool {
        favoritesManager.isFavorite(FavoritesManager.identifier(forDeprecationMessage: message))
    }

    private func toggleFavorite(_ message: String) {
        favoritesManager.toggleFavorite(FavoritesManager.identifier(forDeprecationMessage: message))
    }

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Divider()

            if deprecations.isEmpty {
                emptyState
            } else if filteredDeprecations.isEmpty {
                noResultsState
            } else {
                deprecationsList
            }
        }
        .selectableList(manager: selectionManager)
        .onChange(of: deprecations.count) { _, _ in
            selectionManager.items = allIdentifiedItems
        }
        .onChange(of: searchText) { _, _ in
            selectionManager.items = allIdentifiedItems
        }
        .onChange(of: showFavoritesOnly) { _, _ in
            selectionManager.items = allIdentifiedItems
        }
        .onChange(of: selectedScope) { _, _ in
            selectionManager.items = allIdentifiedItems
        }
        .onAppear {
            selectionManager.items = allIdentifiedItems
        }
        .background {
            Button("Reveal in Navigator") {
                revealSelectedInNavigator()
            }
            .keyboardShortcut("j", modifiers: [.command, .shift])
            .hidden()
        }
    }

    private func revealSelectedInNavigator() {
        guard let firstSelectedID = selectionManager.selectedIDs.first,
              let selectedItem = allIdentifiedItems.first(where: { $0.id == firstSelectedID }) else {
            return
        }
        revealInNavigator(notice: selectedItem.notice)
    }

    // MARK: - Deprecation Row with Context Menu

    @ViewBuilder
    private func deprecationRowWithContextMenu(item: IdentifiedDeprecation) -> some View {
        DeprecationRow(deprecation: item.notice)
            .tag(item.id)
            .onTapGesture(count: 2) { NoticeUtilities.openInXcode(item.notice) }
            .noticeContextMenu(notice: item.notice, viewModel: viewModel)
    }

    private func revealInNavigator(notice: Notice) {
        let filePath = NoticeUtilities.getFilePath(from: notice.documentURL)
        guard !filePath.isEmpty else { return }

        let fileName = URL(fileURLWithPath: filePath).lastPathComponent
        viewModel.selectedScope = .directory(path: filePath, name: fileName)
    }

    // MARK: - Toolbar

    private var toolbar: some View {
        HStack {
            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search deprecations...", text: $searchText)
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
            .frame(maxWidth: 250)

            // Favorites filter
            Button {
                showFavoritesOnly.toggle()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: showFavoritesOnly ? "star.fill" : "star")
                        .foregroundStyle(showFavoritesOnly ? .yellow : .secondary)
                    if favoritesCount > 0 {
                        Text("\(favoritesCount)")
                            .font(.caption)
                    }
                }
            }
            .buttonStyle(.bordered)
            .help(showFavoritesOnly ? "Show All" : "Show Favorites Only")

            // Selection info
            SelectionInfoView(count: selectionManager.selectionCount)

            Spacer()

            Text("\(filteredDeprecations.count) deprecations")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    // MARK: - Empty States

    private var emptyState: some View {
        VStack {
            Spacer()
            ContentUnavailableView {
                Label("No Deprecations", systemImage: "checkmark.circle")
            } description: {
                Text("Great news! No deprecated APIs found in this build.")
            }
            Spacer()
        }
    }

    private var noResultsState: some View {
        VStack {
            Spacer()
            if showFavoritesOnly && searchText.isEmpty {
                // Starred filter is on but no starred items
                ContentUnavailableView {
                    Label("No Starred Deprecations", systemImage: "star")
                } description: {
                    Text("You haven't starred any deprecations yet.")
                } actions: {
                    Button("Show All") {
                        showFavoritesOnly = false
                    }
                }
            } else if showFavoritesOnly {
                // Both filters active, no matches
                ContentUnavailableView {
                    Label("No Results", systemImage: "magnifyingglass")
                } description: {
                    Text("No starred deprecations match \"\(searchText)\"")
                } actions: {
                    Button("Show All Starred") {
                        searchText = ""
                    }
                    Button("Show All Deprecations") {
                        searchText = ""
                        showFavoritesOnly = false
                    }
                }
            } else {
                // Just search filter, no matches
                ContentUnavailableView {
                    Label("No Results", systemImage: "magnifyingglass")
                } description: {
                    Text("No deprecations match \"\(searchText)\"")
                } actions: {
                    Button("Clear Search") {
                        searchText = ""
                    }
                }
            }
            Spacer()
        }
    }

    // MARK: - List

    private var deprecationsList: some View {
        List(selection: selectionManager.selectionBinding) {
            ForEach(groupedByMessage, id: \.message) { group in
                Section {
                    ForEach(group.items) { item in
                        deprecationRowWithContextMenu(item: item)
                    }
                } header: {
                    HStack(alignment: .top) {
                        // Favorite button
                        Button {
                            toggleFavorite(group.message)
                        } label: {
                            Image(systemName: group.isFavorite ? "star.fill" : "star")
                                .foregroundStyle(group.isFavorite ? .yellow : .secondary)
                        }
                        .buttonStyle(.plain)
                        .help(group.isFavorite ? "Remove from Favorites" : "Add to Favorites")

                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundStyle(.orange)

                        Text(group.message)
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Spacer()

                        Text("\(group.items.count)")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(.orange.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
            }
        }
        .listStyle(.inset)
    }

    // MARK: - Scope Filtering

    private func matchesScope(_ warning: Notice) -> Bool {
        switch selectedScope {
        case .all:
            return true
        case .packageDependencies:
            return viewModel.isPackageDependency(warning)
        case .project:
            return !viewModel.isPackageDependency(warning)
        case .directory(let path, _):
            return NoticeUtilities.getFilePath(from: warning.documentURL).hasPrefix(path)
        }
    }
}

// MARK: - Deprecation Row

private struct DeprecationRow: View {
    let deprecation: Notice

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "doc.text")
                .foregroundStyle(.secondary)
                .font(.body)

            Text(fileName)
                .font(.body)

            Spacer()

            if deprecation.startingLineNumber > 0 {
                Text("Line \(deprecation.startingLineNumber)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var fileName: String {
        guard !deprecation.documentURL.isEmpty else { return "(Unknown)" }
        let url = URL(string: deprecation.documentURL) ?? URL(fileURLWithPath: deprecation.documentURL)
        return url.lastPathComponent
    }
}
