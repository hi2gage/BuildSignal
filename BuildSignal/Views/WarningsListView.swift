import SwiftUI
import XCLogParser

/// A wrapper to give each warning a stable ID
private struct IdentifiedWarning: Identifiable {
    let id: String
    let warning: Notice

    init(_ warning: Notice, index: Int) {
        // Create stable ID from warning properties
        self.id = "\(warning.documentURL):\(warning.startingLineNumber):\(warning.title.prefix(50)):\(index)"
        self.warning = warning
    }
}

/// Displays a list of warnings with grouping and filtering options.
struct WarningsListView: View {
    let warnings: [Notice]
    @State private var groupBy: GroupingOption = .file
    @State private var searchText = ""

    enum GroupingOption: String, CaseIterable {
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
    }

    // MARK: - Toolbar

    private var toolbar: some View {
        HStack {
            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search warnings...", text: $searchText)
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

            Spacer()

            // Group by picker
            Picker("Group by", selection: $groupBy) {
                ForEach(GroupingOption.allCases, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 200)

            // Count
            Text("\(filteredWarnings.count) warnings")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    // MARK: - Warnings List

    private var warningsList: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                switch groupBy {
                case .file:
                    groupedByFileContent
                case .type:
                    groupedByTypeContent
                case .none:
                    flatListContent
                }
            }
        }
        .background(Color(nsColor: .textBackgroundColor))
    }

    // MARK: - Grouped by File

    private var groupedByFileContent: some View {
        ForEach(sortedFileGroups, id: \.file) { group in
            Section {
                ForEach(group.identifiedWarnings) { item in
                    WarningRow(warning: item.warning, showFile: false)
                    Divider().padding(.leading, 44)
                }
            } header: {
                sectionHeader(
                    icon: "doc.text",
                    title: group.file,
                    count: group.identifiedWarnings.count,
                    color: .yellow
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
                    Divider().padding(.leading, 44)
                }
            } header: {
                sectionHeader(
                    icon: iconForType(group.type),
                    title: labelForType(group.type),
                    count: group.identifiedWarnings.count,
                    color: colorForType(group.type)
                )
            }
        }
    }

    // MARK: - Flat List

    private var flatListContent: some View {
        ForEach(identifiedFilteredWarnings) { item in
            WarningRow(warning: item.warning, showFile: true)
            Divider().padding(.leading, 44)
        }
    }

    // MARK: - Section Header

    private func sectionHeader(icon: String, title: String, count: Int, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
            Text(title)
                .font(.headline)
            Spacer()
            Text("\(count)")
                .font(.caption)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(color.opacity(0.3))
                .cornerRadius(4)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.bar)
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

    private var filteredWarnings: [Notice] {
        guard !searchText.isEmpty else { return warnings }
        let query = searchText.lowercased()
        return warnings.filter { warning in
            warning.title.lowercased().contains(query) ||
            warning.documentURL.lowercased().contains(query) ||
            (warning.detail?.lowercased().contains(query) ?? false)
        }
    }

    private var identifiedFilteredWarnings: [IdentifiedWarning] {
        filteredWarnings.enumerated().map { IdentifiedWarning($0.element, index: $0.offset) }
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
        .padding(.horizontal)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
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
