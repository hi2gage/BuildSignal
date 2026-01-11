import SwiftUI
import XCLogParser

/// Displays a list of warnings with grouping and filtering options.
struct WarningsListView: View {
    @ObservedObject var viewModel: ProjectDetailViewModel
    @ObservedObject private var categoryManager = CategoryManager.shared
    @State private var groupBy: GroupingOption = .smart
    @State private var searchText = ""
    @State private var selectedIDs: Set<String> = []
    @State private var showingCategoryManager = false

    /// Filter type for the tab (warnings only, deprecations only, or all)
    enum FilterType {
        case all
        case warnings
        case deprecations
    }

    let filterType: FilterType

    init(viewModel: ProjectDetailViewModel, filterType: FilterType = .all) {
        self.viewModel = viewModel
        self.filterType = filterType
    }

    private var warnings: [Notice] {
        switch filterType {
        case .all:
            return viewModel.warnings
        case .warnings:
            return viewModel.warnings.filter { $0.type != .deprecatedWarning }
        case .deprecations:
            return viewModel.warnings.filter { $0.type == .deprecatedWarning }
        }
    }
    private var selectedScope: ScopeItem { viewModel.selectedScope }

    enum GroupingOption: String, CaseIterable {
        case smart = "Smart"
        case message = "Message"
        case file = "File"
        case type = "Type"
        case none = "None"
    }

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Divider()

            if warnings.isEmpty {
                emptyState
            } else if filteredWarnings.isEmpty {
                noResultsState
            } else {
                warningsList
            }
        }
        .copyable(copySelectedWarningsText())
        .onDeleteCommand {
            selectedIDs.removeAll()
        }
        .sheet(isPresented: $showingCategoryManager) {
            CategoryManagerView(categoryManager: categoryManager)
        }
    }

    private func copySelectedWarningsText() -> [String] {
        guard !selectedIDs.isEmpty else { return [] }

        let selectedWarnings = filteredWarnings.enumerated()
            .filter { selectedIDs.contains(IdentifiedWarning($0.element, index: $0.offset).id) }
            .map { $0.element }

        let text = selectedWarnings.map { warning in
            let file = extractFileName(from: warning.documentURL)
            let line = warning.startingLineNumber > 0 ? ":\(warning.startingLineNumber)" : ""
            return "\(file)\(line): \(warning.title)"
        }.joined(separator: "\n")

        return [text]
    }

    // MARK: - Toolbar

    private var toolbar: some View {
        HStack {
            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search...", text: $searchText)
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
            .frame(maxWidth: 200)

            // Selection info
            if !selectedIDs.isEmpty {
                Text("\(selectedIDs.count) selected")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Group by picker
            Picker("Group by", selection: $groupBy) {
                ForEach(GroupingOption.allCases, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .frame(width: 300)

            // Manage categories button (only show for Smart grouping)
            if groupBy == .smart {
                Button {
                    showingCategoryManager = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
                .buttonStyle(.borderless)
                .help("Manage Categories")
            }

            // Count
            Text("\(filteredWarnings.count) warnings")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    // MARK: - Warnings List

    private var warningsList: some View {
        List(selection: $selectedIDs) {
            switch groupBy {
            case .smart:
                groupedBySmartContent
            case .message:
                groupedByMessageContent
            case .file:
                groupedByFileContent
            case .type:
                groupedByTypeContent
            case .none:
                flatListContent
            }
        }
        .listStyle(.inset)
    }

    // MARK: - Grouped by Smart Category

    private var groupedBySmartContent: some View {
        ForEach(sortedSmartGroups, id: \.category) { group in
            Section {
                ForEach(group.identifiedWarnings) { item in
                    WarningRow(warning: item.warning, showFile: true)
                        .tag(item.id)
                        .onTapGesture(count: 2) { openInXcode(item.warning) }
                }
            } header: {
                sectionHeader(
                    icon: group.category.icon,
                    title: group.category.name,
                    count: group.identifiedWarnings.count,
                    color: group.category.color,
                    ids: Set(group.identifiedWarnings.map(\.id))
                )
            }
        }
    }

    // MARK: - Grouped by Message

    private var groupedByMessageContent: some View {
        ForEach(sortedMessageGroups, id: \.message) { group in
            Section {
                ForEach(group.identifiedWarnings) { item in
                    WarningRow(warning: item.warning, showFile: true)
                        .tag(item.id)
                        .onTapGesture(count: 2) { openInXcode(item.warning) }
                }
            } header: {
                messageHeader(
                    message: group.message,
                    type: group.type,
                    count: group.identifiedWarnings.count,
                    ids: Set(group.identifiedWarnings.map(\.id))
                )
            }
        }
    }

    private func messageHeader(message: String, type: NoticeType, count: Int, ids: Set<String>) -> some View {
        let allSelected = ids == selectedIDs
        return Button {
            selectedIDs = ids
        } label: {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: iconForType(type))
                    .foregroundStyle(allSelected ? .white : colorForType(type))
                VStack(alignment: .leading, spacing: 2) {
                    Text(message)
                        .font(.headline)
                        .foregroundStyle(allSelected ? .white : .primary)
                        .lineLimit(2)
                }
                Spacer()
                Text("\(count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(allSelected ? .white : .primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(allSelected ? Color.white.opacity(0.3) : colorForType(type).opacity(0.3))
                    .cornerRadius(6)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(allSelected ? Color.accentColor : Color(nsColor: .windowBackgroundColor))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Grouped by File

    private var groupedByFileContent: some View {
        ForEach(sortedFileGroups, id: \.file) { group in
            Section {
                ForEach(group.identifiedWarnings) { item in
                    WarningRow(warning: item.warning, showFile: false)
                        .tag(item.id)
                        .onTapGesture(count: 2) { openInXcode(item.warning) }
                }
            } header: {
                sectionHeader(
                    icon: "doc.text",
                    title: group.file,
                    count: group.identifiedWarnings.count,
                    color: .yellow,
                    ids: Set(group.identifiedWarnings.map(\.id))
                )
            }
        }
    }

    // MARK: - Grouped by Type

    private var groupedByTypeContent: some View {
        ForEach(sortedTypeGroups, id: \.type) { group in
            Section {
                ForEach(group.identifiedWarnings) { item in
                    WarningRow(warning: item.warning, showFile: true)
                        .tag(item.id)
                        .onTapGesture(count: 2) { openInXcode(item.warning) }
                }
            } header: {
                sectionHeader(
                    icon: iconForType(group.type),
                    title: labelForType(group.type),
                    count: group.identifiedWarnings.count,
                    color: colorForType(group.type),
                    ids: Set(group.identifiedWarnings.map(\.id))
                )
            }
        }
    }

    // MARK: - Flat List

    private var flatListContent: some View {
        ForEach(identifiedFilteredWarnings) { item in
            WarningRow(warning: item.warning, showFile: true)
                .tag(item.id)
                .onTapGesture(count: 2) { openInXcode(item.warning) }
        }
    }

    // MARK: - Section Header

    private func sectionHeader(icon: String, title: String, count: Int, color: Color, ids: Set<String>) -> some View {
        let allSelected = ids == selectedIDs
        return Button {
            selectedIDs = ids
        } label: {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(allSelected ? .white.opacity(0.8) : .secondary)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(allSelected ? .white : .primary)
                Spacer()
                Text("\(count)")
                    .font(.caption)
                    .foregroundStyle(allSelected ? .white : .primary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(allSelected ? Color.white.opacity(0.3) : color.opacity(0.3))
                    .cornerRadius(4)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(allSelected ? Color.accentColor : Color(nsColor: .clear))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Empty States

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Warnings", systemImage: "checkmark.circle")
        } description: {
            Text("This build has no warnings. Nice work!")
        }
    }

    private var noResultsState: some View {
        ContentUnavailableView {
            Label("No Results", systemImage: "magnifyingglass")
        } description: {
            Text("No warnings match '\(searchText)'")
        }
    }

    // MARK: - Data Processing

    /// Warnings filtered by scope only (for showing count in scope picker)
    private var scopeFilteredWarnings: [Notice] {
        warnings.filter { matchesScope($0) }
    }

    /// Warnings filtered by both scope and search text
    private var filteredWarnings: [Notice] {
        var result = scopeFilteredWarnings

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter { warning in
                warning.title.lowercased().contains(query) ||
                warning.documentURL.lowercased().contains(query) ||
                (warning.detail?.lowercased().contains(query) ?? false)
            }
        }

        return result
    }

    private var identifiedFilteredWarnings: [IdentifiedWarning] {
        filteredWarnings.enumerated().map { IdentifiedWarning($0.element, index: $0.offset) }
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
            return getDirectoryPath(from: warning.documentURL).hasPrefix(path)
        }
    }

    private func getDirectoryPath(from documentURL: String) -> String {
        guard !documentURL.isEmpty else { return "" }

        if documentURL.hasPrefix("file://") {
            if let url = URL(string: documentURL) {
                return url.deletingLastPathComponent().path
            }
            if let decoded = documentURL.removingPercentEncoding,
               let url = URL(string: decoded) {
                return url.deletingLastPathComponent().path
            }
            let pathPart = String(documentURL.dropFirst(7))
            let url = URL(fileURLWithPath: pathPart)
            return url.deletingLastPathComponent().path
        }

        let url = URL(fileURLWithPath: documentURL)
        return url.deletingLastPathComponent().path
    }

    private var sortedSmartGroups: [(category: WarningCategory, identifiedWarnings: [IdentifiedWarning])] {
        // Use all categories (built-in + custom) from the category manager
        let allCategories = categoryManager.allCategories
        let grouped = Dictionary(grouping: filteredWarnings.enumerated().map { ($0.offset, $0.element) }) {
            WarningCategory.categorize($0.1, using: allCategories)
        }
        return grouped
            .map { (category: $0.key, identifiedWarnings: $0.value.map { IdentifiedWarning($0.1, index: $0.0) }) }
            .filter { !$0.identifiedWarnings.isEmpty }
            .sorted { $0.category.sortOrder < $1.category.sortOrder }
    }

    private var sortedMessageGroups: [(message: String, type: NoticeType, identifiedWarnings: [IdentifiedWarning])] {
        let grouped = Dictionary(grouping: filteredWarnings.enumerated().map { ($0.offset, $0.element) }) {
            $0.1.title
        }
        return grouped
            .map { key, value in
                let warnings = value.map { IdentifiedWarning($0.1, index: $0.0) }
                let type = value.first?.1.type ?? .swiftWarning
                return (message: key, type: type, identifiedWarnings: warnings)
            }
            .sorted {
                if $0.identifiedWarnings.count != $1.identifiedWarnings.count {
                    return $0.identifiedWarnings.count > $1.identifiedWarnings.count
                }
                return $0.message < $1.message
            }
    }

    private var sortedFileGroups: [(file: String, identifiedWarnings: [IdentifiedWarning])] {
        let grouped = Dictionary(grouping: filteredWarnings.enumerated().map { ($0.offset, $0.element) }) {
            extractFileName(from: $0.1.documentURL)
        }
        return grouped
            .map { (file: $0.key, identifiedWarnings: $0.value.map { IdentifiedWarning($0.1, index: $0.0) }) }
            .sorted {
                if $0.identifiedWarnings.count != $1.identifiedWarnings.count {
                    return $0.identifiedWarnings.count > $1.identifiedWarnings.count
                }
                return $0.file < $1.file
            }
    }

    private var sortedTypeGroups: [(type: NoticeType, identifiedWarnings: [IdentifiedWarning])] {
        let grouped = Dictionary(grouping: filteredWarnings.enumerated().map { ($0.offset, $0.element) }) {
            $0.1.type
        }
        return grouped
            .map { (type: $0.key, identifiedWarnings: $0.value.map { IdentifiedWarning($0.1, index: $0.0) }) }
            .sorted {
                if $0.identifiedWarnings.count != $1.identifiedWarnings.count {
                    return $0.identifiedWarnings.count > $1.identifiedWarnings.count
                }
                return $0.type.rawValue < $1.type.rawValue
            }
    }

    // MARK: - Helpers

    private func extractFileName(from documentURL: String) -> String {
        guard !documentURL.isEmpty else { return "(Project)" }
        let url = URL(string: documentURL) ?? URL(fileURLWithPath: documentURL)
        return url.lastPathComponent
    }

    private func iconForType(_ type: NoticeType) -> String {
        switch type {
        case .swiftWarning, .clangWarning:
            return "exclamationmark.triangle.fill"
        case .deprecatedWarning:
            return "clock.arrow.circlepath"
        case .projectWarning:
            return "folder.badge.questionmark"
        case .analyzerWarning:
            return "magnifyingglass"
        case .interfaceBuilderWarning:
            return "rectangle.on.rectangle"
        default:
            return "exclamationmark.circle"
        }
    }

    private func colorForType(_ type: NoticeType) -> Color {
        switch type {
        case .swiftWarning, .clangWarning:
            return .yellow
        case .deprecatedWarning:
            return .orange
        case .projectWarning:
            return .purple
        case .analyzerWarning:
            return .blue
        default:
            return .yellow
        }
    }

    private func labelForType(_ type: NoticeType) -> String {
        switch type {
        case .swiftWarning: return "Swift Warnings"
        case .clangWarning: return "C/C++ Warnings"
        case .deprecatedWarning: return "Deprecations"
        case .projectWarning: return "Project Warnings"
        case .analyzerWarning: return "Analyzer Warnings"
        case .interfaceBuilderWarning: return "Interface Builder"
        case .note: return "Notes"
        default: return type.rawValue
        }
    }

    /// Opens the warning location in Xcode
    private func openInXcode(_ warning: Notice) {
        guard !warning.documentURL.isEmpty else { return }

        // Parse the file URL
        let filePath: String
        if warning.documentURL.hasPrefix("file://") {
            if let url = URL(string: warning.documentURL) {
                filePath = url.path
            } else if let decoded = warning.documentURL.removingPercentEncoding,
                      let url = URL(string: decoded) {
                filePath = url.path
            } else {
                filePath = String(warning.documentURL.dropFirst(7))
            }
        } else {
            filePath = warning.documentURL
        }

        // Use xed to open file at specific line in Xcode
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/xed")
        task.arguments = ["--line", "\(warning.startingLineNumber)", filePath]

        do {
            try task.run()
        } catch {
            print("Failed to open in Xcode: \(error)")
        }
    }
}

