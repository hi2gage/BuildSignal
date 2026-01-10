import SwiftUI
import XCLogParser

/// A wrapper to give each warning a stable ID
private struct IdentifiedWarning: Identifiable, Hashable {
    let id: String
    let warning: Notice

    init(_ warning: Notice, index: Int) {
        // Create stable ID from warning properties
        self.id = "\(warning.documentURL):\(warning.startingLineNumber):\(warning.title.prefix(50)):\(index)"
        self.warning = warning
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: IdentifiedWarning, rhs: IdentifiedWarning) -> Bool {
        lhs.id == rhs.id
    }
}

/// Represents a scope for filtering warnings by path
enum ScopeItem: Hashable {
    case all
    case packageDependencies
    case project
    case directory(path: String, name: String)

    var displayName: String {
        switch self {
        case .all: return "All"
        case .packageDependencies: return "Package Dependencies"
        case .project: return "Project"
        case .directory(_, let name): return name
        }
    }

    var icon: String {
        switch self {
        case .all: return "square.stack.3d.up"
        case .packageDependencies: return "shippingbox"
        case .project: return "folder.badge.gearshape"
        case .directory: return "folder"
        }
    }
}

/// A node in the directory tree for scope selection
struct DirectoryNode: Identifiable, Hashable {
    let id: String
    let name: String
    let path: String
    var children: [DirectoryNode]
    var warningCount: Int

    var isLeaf: Bool { children.isEmpty }
}

/// Displays a list of warnings with grouping and filtering options.
struct WarningsListView: View {
    let warnings: [Notice]
    @ObservedObject private var categoryManager = CategoryManager.shared
    @State private var groupBy: GroupingOption = .smart
    @State private var searchText = ""
    @State private var selectedIDs: Set<String> = []
    @State private var showingCategoryManager = false
    @State private var selectedScope: ScopeItem = .all
    @State private var showingScopePicker = false

    enum GroupingOption: String, CaseIterable {
        case smart = "Smart"
        case message = "Message"
        case file = "File"
        case type = "Type"
        case none = "None"
    }

    var body: some View {
        VStack(spacing: 0) {
            scopeBar
            Divider()
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

    // MARK: - Scope Bar

    private var scopeBar: some View {
        HStack(spacing: 12) {
            Text("Scope")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button {
                showingScopePicker = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: selectedScope.icon)
                        .foregroundStyle(.secondary)
                    Text(selectedScope.displayName)
                        .fontWeight(.medium)
                    if selectedScope != .all {
                        Text("(\(scopeFilteredWarnings.count))")
                            .foregroundStyle(.secondary)
                    }
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.quaternary)
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showingScopePicker, arrowEdge: .bottom) {
                ScopePickerView(
                    warnings: warnings,
                    selectedScope: $selectedScope,
                    isPresented: $showingScopePicker,
                    projectWarningCount: warnings.filter { !isPackageDependency($0) }.count,
                    packageWarningCount: warnings.filter { isPackageDependency($0) }.count,
                    directoryTree: directoryTree
                )
            }

            if selectedScope != .all {
                Button {
                    selectedScope = .all
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(nsColor: .controlBackgroundColor))
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
            .background(allSelected ? Color.accentColor : Color(nsColor: .windowBackgroundColor))
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
            return isPackageDependency(warning)
        case .project:
            return !isPackageDependency(warning)
        case .directory(let path, _):
            return getDirectoryPath(from: warning.documentURL).hasPrefix(path)
        }
    }

    private func isPackageDependency(_ warning: Notice) -> Bool {
        let url = warning.documentURL.lowercased()
        return url.contains("/sourcepackages/") ||
               url.contains("/checkouts/") ||
               url.contains("/.build/") ||
               url.contains("/deriveddata/") && url.contains("/sourcepackages/")
    }

    private func getDirectoryPath(from documentURL: String) -> String {
        guard !documentURL.isEmpty else { return "" }

        // Handle file:// URLs
        if documentURL.hasPrefix("file://") {
            // Try URL(string:) first, then try with percent encoding
            if let url = URL(string: documentURL) {
                return url.deletingLastPathComponent().path
            }
            // Try decoding percent-encoded URL
            if let decoded = documentURL.removingPercentEncoding,
               let url = URL(string: decoded) {
                return url.deletingLastPathComponent().path
            }
            // Strip file:// prefix and treat as path
            let pathPart = String(documentURL.dropFirst(7)) // "file://".count
            let url = URL(fileURLWithPath: pathPart)
            return url.deletingLastPathComponent().path
        }

        // Regular file path
        let url = URL(fileURLWithPath: documentURL)
        return url.deletingLastPathComponent().path
    }

    private func getFilePath(from documentURL: String) -> String {
        guard !documentURL.isEmpty else { return "" }

        if documentURL.hasPrefix("file://") {
            if let url = URL(string: documentURL) {
                return url.path
            }
            if let decoded = documentURL.removingPercentEncoding,
               let url = URL(string: decoded) {
                return url.path
            }
            // Strip file:// prefix and treat as path
            return String(documentURL.dropFirst(7))
        }

        return documentURL
    }

    // MARK: - Directory Tree

    private var directoryTree: [DirectoryNode] {
        // Get all file paths from project warnings
        let projectWarnings = warnings.filter { !isPackageDependency($0) && !$0.documentURL.isEmpty }
        guard !projectWarnings.isEmpty else { return [] }

        // Collect all directory paths with counts
        var pathCounts: [String: Int] = [:]
        for warning in projectWarnings {
            let dirPath = getDirectoryPath(from: warning.documentURL)
            guard !dirPath.isEmpty else { continue }
            pathCounts[dirPath, default: 0] += 1
        }

        guard !pathCounts.isEmpty else { return [] }

        // Find common prefix (project root)
        let allPaths = Array(pathCounts.keys).sorted()
        let commonPrefix = findCommonPathPrefix(allPaths)

        // Build the tree using a helper class (reference type for proper mutation)
        class MutableNode {
            let name: String
            let path: String
            var children: [String: MutableNode] = [:]
            var directCount: Int = 0

            init(name: String, path: String) {
                self.name = name
                self.path = path
            }

            var totalCount: Int {
                directCount + children.values.reduce(0) { $0 + $1.totalCount }
            }

            // Get or create a child node
            func getOrCreateChild(name: String, path: String) -> MutableNode {
                if let existing = children[name] {
                    return existing
                }
                let node = MutableNode(name: name, path: path)
                children[name] = node
                return node
            }

            func toDirectoryNode() -> DirectoryNode {
                DirectoryNode(
                    id: path,
                    name: name,
                    path: path,
                    children: children.values
                        .map { $0.toDirectoryNode() }
                        .sorted { $0.warningCount > $1.warningCount },
                    warningCount: totalCount
                )
            }
        }

        // Root container to hold top-level nodes
        let rootContainer = MutableNode(name: "", path: commonPrefix)

        for (fullPath, count) in pathCounts {
            // Get path relative to common prefix
            var relativePath = fullPath
            if fullPath.hasPrefix(commonPrefix) {
                relativePath = String(fullPath.dropFirst(commonPrefix.count))
                if relativePath.hasPrefix("/") {
                    relativePath = String(relativePath.dropFirst())
                }
            }

            let components = relativePath.split(separator: "/").map(String.init)
            guard !components.isEmpty else { continue }

            // Navigate/create through the tree
            var currentNode = rootContainer
            var currentPath = commonPrefix

            for (index, component) in components.enumerated() {
                currentPath += "/" + component
                currentNode = currentNode.getOrCreateChild(name: component, path: currentPath)

                // If this is the last component, add the direct count
                if index == components.count - 1 {
                    currentNode.directCount += count
                }
            }
        }

        return rootContainer.children.values
            .map { $0.toDirectoryNode() }
            .sorted { $0.warningCount > $1.warningCount }
    }

    private func findCommonPathPrefix(_ paths: [String]) -> String {
        guard let first = paths.first else { return "" }

        let firstComponents = first.split(separator: "/").map(String.init)
        var commonComponents: [String] = []

        for (index, component) in firstComponents.enumerated() {
            let allMatch = paths.allSatisfy { path in
                let components = path.split(separator: "/").map(String.init)
                return index < components.count && components[index] == component
            }
            if allMatch {
                commonComponents.append(component)
            } else {
                break
            }
        }

        // Keep at least one level less than the minimum depth to show some structure
        if commonComponents.count > 0 {
            commonComponents.removeLast()
        }

        return "/" + commonComponents.joined(separator: "/")
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
}

// MARK: - Warning Row

private struct WarningRow: View {
    let warning: Notice
    let showFile: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Warning icon
            Image(systemName: iconForType(warning.type))
                .foregroundStyle(colorForType(warning.type))
                .font(.title3)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(warning.title)
                    .font(.body)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 4) {
                    if showFile && !warning.documentURL.isEmpty {
                        Text(fileName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if warning.startingLineNumber > 0 {
                        Text("Line \(warning.startingLineNumber)")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    private var fileName: String {
        let url = URL(string: warning.documentURL) ?? URL(fileURLWithPath: warning.documentURL)
        return url.lastPathComponent
    }

    private func iconForType(_ type: NoticeType) -> String {
        switch type {
        case .swiftWarning, .clangWarning: return "exclamationmark.triangle.fill"
        case .deprecatedWarning: return "clock.arrow.circlepath"
        case .projectWarning: return "folder.badge.questionmark"
        case .analyzerWarning: return "magnifyingglass"
        default: return "exclamationmark.circle"
        }
    }

    private func colorForType(_ type: NoticeType) -> Color {
        switch type {
        case .swiftWarning, .clangWarning: return .yellow
        case .deprecatedWarning: return .orange
        case .projectWarning: return .purple
        case .analyzerWarning: return .blue
        default: return .yellow
        }
    }
}

// MARK: - Scope Picker View

private struct ScopePickerView: View {
    let warnings: [Notice]
    @Binding var selectedScope: ScopeItem
    @Binding var isPresented: Bool
    let projectWarningCount: Int
    let packageWarningCount: Int
    let directoryTree: [DirectoryNode]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Text("Scope")
                .font(.headline)
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 8)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    // All
                    ScopeRowView(
                        icon: ScopeItem.all.icon,
                        title: "All",
                        count: warnings.count,
                        isSelected: selectedScope == .all,
                        indentLevel: 0
                    ) {
                        selectedScope = .all
                        isPresented = false
                    }

                    Divider()
                        .padding(.vertical, 4)

                    // Project
                    if projectWarningCount > 0 {
                        ScopeRowView(
                            icon: ScopeItem.project.icon,
                            title: "Project",
                            count: projectWarningCount,
                            isSelected: selectedScope == .project,
                            indentLevel: 0
                        ) {
                            selectedScope = .project
                            isPresented = false
                        }
                    }

                    // Package Dependencies
                    if packageWarningCount > 0 {
                        ScopeRowView(
                            icon: ScopeItem.packageDependencies.icon,
                            title: "Package Dependencies",
                            count: packageWarningCount,
                            isSelected: selectedScope == .packageDependencies,
                            indentLevel: 0
                        ) {
                            selectedScope = .packageDependencies
                            isPresented = false
                        }
                    }

                    if !directoryTree.isEmpty {
                        Divider()
                            .padding(.vertical, 4)

                        Text("Directories")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)

                        // Directory tree
                        ForEach(directoryTree) { node in
                            DirectoryTreeRow(
                                node: node,
                                selectedScope: $selectedScope,
                                isPresented: $isPresented,
                                indentLevel: 0
                            )
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .frame(width: 280)
        .frame(maxHeight: 400)
    }
}

// MARK: - Scope Row View

private struct ScopeRowView: View {
    let icon: String
    let title: String
    let count: Int
    let isSelected: Bool
    let indentLevel: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(isSelected ? .white : .secondary)
                    .frame(width: 16)

                Text(title)
                    .foregroundStyle(isSelected ? .white : .primary)

                Spacer()

                Text("\(count)")
                    .font(.caption)
                    .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(isSelected ? Color.white.opacity(0.2) : Color.secondary.opacity(0.2))
                    .cornerRadius(4)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .padding(.leading, CGFloat(indentLevel * 20))
            .background(isSelected ? Color.accentColor : Color.clear)
            .cornerRadius(4)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 4)
    }
}

// MARK: - Directory Tree Row

private struct DirectoryTreeRow: View {
    let node: DirectoryNode
    @Binding var selectedScope: ScopeItem
    @Binding var isPresented: Bool
    let indentLevel: Int

    private var isSelected: Bool {
        if case .directory(let path, _) = selectedScope {
            return path == node.path
        }
        return false
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // This row
            Button {
                selectedScope = .directory(path: node.path, name: node.name)
                isPresented = false
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: node.children.isEmpty ? "doc" : "folder.fill")
                        .foregroundStyle(isSelected ? .white : .blue)
                        .font(.system(size: 14))
                        .frame(width: 16)

                    Text(node.name)
                        .foregroundStyle(isSelected ? .white : .primary)
                        .lineLimit(1)

                    Spacer()

                    Text("\(node.warningCount)")
                        .font(.caption)
                        .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .padding(.leading, CGFloat(indentLevel * 18))
                .background(isSelected ? Color.accentColor : Color.clear)
                .cornerRadius(4)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 4)

            // Children (always shown, nested)
            ForEach(node.children) { child in
                DirectoryTreeRow(
                    node: child,
                    selectedScope: $selectedScope,
                    isPresented: $isPresented,
                    indentLevel: indentLevel + 1
                )
            }
        }
    }
}
