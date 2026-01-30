import AppKit
import SwiftUI
import XCLogParser

/// Displays a list of deprecation warnings grouped by message.
struct DeprecationsListView: View {
    @ObservedObject var viewModel: ProjectDetailViewModel
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    @ObservedObject private var hiddenManager = HiddenManager.shared
    @StateObject private var selectionManager = SelectionManager<IdentifiedDeprecation>()
    @State private var searchText = ""
    @State private var showFavoritesOnly = false
    @State private var showHiddenItems = false
    @State private var scrollPosition: String?

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

        // Apply favorites filter (checks both group and individual favorites)
        if showFavoritesOnly {
            result = result.filter { isAnyFavorite($0) }
        }

        // Apply hidden filter
        if showHiddenItems {
            // Show ONLY hidden items
            result = result.filter { isAnyHidden($0) }
        } else {
            // Exclude hidden items
            result = result.filter { !isAnyHidden($0) }
        }

        return result
    }

    private var allIdentifiedItems: [IdentifiedDeprecation] {
        filteredDeprecations.enumerated().map { IdentifiedDeprecation($0.element, index: $0.offset) }
    }

    private var groupedByMessage: [(message: String, items: [IdentifiedDeprecation], isFavorite: Bool, isHidden: Bool)] {
        let grouped = Dictionary(grouping: filteredDeprecations.enumerated().map { ($0.offset, $0.element) }) {
            $0.1.title
        }
        return grouped
            .map { (message: $0.key,
                    items: $0.value.map { IdentifiedDeprecation($0.1, index: $0.0) }
                        .sorted { $0.notice.documentURL < $1.notice.documentURL },
                    isFavorite: isFavorite($0.key),
                    isHidden: isHidden($0.key)) }
            .sorted { $0.message < $1.message }
    }

    private var favoritesCount: Int {
        // Count unique favorited groups
        let groupCount = Set(deprecations.map(\.title)).filter { isFavorite($0) }.count
        // Count individual favorites (that aren't already in a favorited group)
        let individualCount = deprecations.filter { !isFavorite($0.title) && isIndividualFavorite($0) }.count
        return groupCount + individualCount
    }

    // MARK: - Favorites Helpers

    /// Checks if a deprecation message (group) is favorited
    private func isFavorite(_ message: String) -> Bool {
        favoritesManager.isFavorite(FavoritesManager.identifier(forDeprecationMessage: message))
    }

    /// Checks if an individual deprecation is favorited
    private func isIndividualFavorite(_ notice: Notice) -> Bool {
        favoritesManager.isFavorite(
            FavoritesManager.identifier(
                forIndividualDeprecation: notice.documentURL,
                line: notice.startingLineNumber
            )
        )
    }

    /// Checks if a deprecation is favorited (either by group or individually)
    private func isAnyFavorite(_ notice: Notice) -> Bool {
        isFavorite(notice.title) || isIndividualFavorite(notice)
    }

    private func toggleFavorite(_ message: String) {
        favoritesManager.toggleFavorite(FavoritesManager.identifier(forDeprecationMessage: message))
    }

    // MARK: - Hidden Helpers

    /// Checks if a deprecation message (group) is hidden
    private func isHidden(_ message: String) -> Bool {
        hiddenManager.isHidden(HiddenManager.identifier(forDeprecationMessage: message))
    }

    /// Checks if an individual deprecation is hidden
    private func isIndividualHidden(_ notice: Notice) -> Bool {
        hiddenManager.isHidden(
            HiddenManager.identifier(
                forIndividualDeprecation: notice.documentURL,
                line: notice.startingLineNumber
            )
        )
    }

    /// Checks if a deprecation is hidden (either by group or individually)
    private func isAnyHidden(_ notice: Notice) -> Bool {
        isHidden(notice.title) || isIndividualHidden(notice)
    }

    private func toggleHidden(_ message: String) {
        hiddenManager.toggleHidden(HiddenManager.identifier(forDeprecationMessage: message))
    }

    /// Count of hidden deprecations (unique messages + individual items not in hidden groups)
    private var hiddenCount: Int {
        deprecations.filter { isAnyHidden($0) }.count
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
        .onChange(of: showHiddenItems) { _, _ in
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

            Button("Open in Xcode") {
                openSelectedInXcode()
            }
            .keyboardShortcut("o", modifiers: .command)
            .hidden()

            Button("Hide Selected") {
                hideSelected()
            }
            .keyboardShortcut("h", modifiers: .option)
            .hidden()

            Button("Show Selected") {
                showSelected()
            }
            .keyboardShortcut("s", modifiers: .option)
            .hidden()
        }
    }

    private func openSelectedInXcode() {
        guard let firstSelectedID = selectionManager.selectedIDs.first,
              let selectedItem = allIdentifiedItems.first(where: { $0.id == firstSelectedID }) else {
            return
        }
        NoticeUtilities.openInXcode(selectedItem.notice)
    }

    private func revealSelectedInNavigator() {
        guard let firstSelectedID = selectionManager.selectedIDs.first,
              let selectedItem = allIdentifiedItems.first(where: { $0.id == firstSelectedID }) else {
            return
        }
        revealInNavigator(notice: selectedItem.notice)
    }

    private func hideSelected() {
        let selectedItems = allIdentifiedItems.filter { selectionManager.selectedIDs.contains($0.id) }
        guard !selectedItems.isEmpty else { return }

        let identifiers = selectedItems.map { item in
            HiddenManager.identifier(
                forIndividualDeprecation: item.notice.documentURL,
                line: item.notice.startingLineNumber
            )
        }
        hiddenManager.hideAll(identifiers)
        selectionManager.deselectAll()
    }

    private func showSelected() {
        let selectedItems = allIdentifiedItems.filter { selectionManager.selectedIDs.contains($0.id) }
        guard !selectedItems.isEmpty else { return }

        // Collect both individual and group identifiers since items can be hidden either way
        var identifiers: [String] = []
        for item in selectedItems {
            // Individual identifier
            identifiers.append(
                HiddenManager.identifier(
                    forIndividualDeprecation: item.notice.documentURL,
                    line: item.notice.startingLineNumber
                )
            )
            // Group identifier (by message)
            identifiers.append(
                HiddenManager.identifier(forDeprecationMessage: item.notice.title)
            )
        }
        hiddenManager.showAll(identifiers)
        selectionManager.deselectAll()
    }

    private func hideSingleItem(_ item: IdentifiedDeprecation) {
        hiddenManager.hide(
            HiddenManager.identifier(
                forIndividualDeprecation: item.notice.documentURL,
                line: item.notice.startingLineNumber
            )
        )
    }

    private func showSingleItem(_ item: IdentifiedDeprecation) {
        // Remove both individual and group identifiers
        hiddenManager.show(
            HiddenManager.identifier(
                forIndividualDeprecation: item.notice.documentURL,
                line: item.notice.startingLineNumber
            )
        )
        hiddenManager.show(
            HiddenManager.identifier(forDeprecationMessage: item.notice.title)
        )
    }

    // MARK: - Deprecation Row with Context Menu

    @ViewBuilder
    private func deprecationRowWithContextMenu(item: IdentifiedDeprecation) -> some View {
        DeprecationRow(deprecation: item.notice, favoritesManager: favoritesManager, showStar: !showHiddenItems)
            .contentShape(Rectangle())
            .onDoubleClickComplex { NoticeUtilities.openInXcode(item.notice) }
            .tag(item.id)
            .contextMenu {
                // Standard notice actions
                Button {
                    NoticeUtilities.openInXcode(item.notice)
                } label: {
                    Label("Open in Xcode", systemImage: "hammer")
                }

                Button {
                    NoticeUtilities.copyToClipboard(item.notice)
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }

                Divider()

                // Hide/Show action with selection count
                let selectedCount = selectionManager.selectionCount
                let hasMultipleSelected = selectedCount > 1

                if showHiddenItems {
                    Button {
                        if hasMultipleSelected {
                            showSelected()
                        } else {
                            showSingleItem(item)
                        }
                    } label: {
                        Label(
                            hasMultipleSelected ? "Show (\(selectedCount))" : "Show",
                            systemImage: "eye"
                        )
                    }
                } else {
                    Button {
                        if hasMultipleSelected {
                            hideSelected()
                        } else {
                            hideSingleItem(item)
                        }
                    } label: {
                        Label(
                            hasMultipleSelected ? "Hide (\(selectedCount))" : "Hide",
                            systemImage: "eye.slash"
                        )
                    }
                }
            }
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

            // Hidden items toggle
            Button {
                showHiddenItems.toggle()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "eye.slash")
                        .foregroundStyle(.secondary)
                    if hiddenCount > 0 {
                        Text("\(hiddenCount)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(showHiddenItems ? .white : .secondary)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(showHiddenItems ? Color.orange : Color.secondary.opacity(0.3))
                            .clipShape(Capsule())
                    }
                }
            }
            .buttonStyle(.bordered)
            .help(showHiddenItems ? "Hide Hidden Items" : "Show \(hiddenCount) Hidden Items")

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
                        // Favorite button (hidden when viewing hidden items)
                        if !showHiddenItems {
                            Button {
                                toggleFavorite(group.message)
                            } label: {
                                Image(systemName: group.isFavorite ? "star.fill" : "star")
                                    .foregroundStyle(group.isFavorite ? .yellow : .secondary)
                            }
                            .buttonStyle(.plain)
                            .help(group.isFavorite ? "Remove from Favorites" : "Add to Favorites")
                        }

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
                    .contentShape(Rectangle())
                    .contextMenu {
                        Button {
                            toggleFavorite(group.message)
                        } label: {
                            Label(
                                group.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                                systemImage: group.isFavorite ? "star.slash" : "star"
                            )
                        }

                        Divider()

                        if group.isHidden {
                            Button {
                                toggleHidden(group.message)
                            } label: {
                                Label("Show This Group", systemImage: "eye")
                            }
                        } else {
                            Button {
                                toggleHidden(group.message)
                            } label: {
                                Label("Hide This Group", systemImage: "eye.slash")
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.inset)
        .scrollPosition(id: $scrollPosition)
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
    @ObservedObject var favoritesManager: FavoritesManager
    var showStar: Bool = true

    private var isIndividualFavorite: Bool {
        favoritesManager.isFavorite(
            FavoritesManager.identifier(
                forIndividualDeprecation: deprecation.documentURL,
                line: deprecation.startingLineNumber
            )
        )
    }

    private func toggleIndividualFavorite() {
        favoritesManager.toggleFavorite(
            FavoritesManager.identifier(
                forIndividualDeprecation: deprecation.documentURL,
                line: deprecation.startingLineNumber
            )
        )
    }

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            // Individual star button (hidden when viewing hidden items)
            if showStar {
                Button {
                    toggleIndividualFavorite()
                } label: {
                    Image(systemName: isIndividualFavorite ? "star.fill" : "star")
                        .foregroundStyle(isIndividualFavorite ? Color.yellow : Color.secondary.opacity(0.5))
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .help(isIndividualFavorite ? "Remove from Favorites" : "Add to Favorites")
            }

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
