import SwiftUI
import XCLogParser

/// Displays a list of deprecation warnings grouped by message.
struct DeprecationsListView: View {
    @ObservedObject var viewModel: ProjectDetailViewModel
    @State private var searchText = ""
    @State private var selectedIDs: Set<String> = []

    private var deprecations: [Notice] {
        viewModel.warnings.filter { $0.type == .deprecatedWarning }
    }

    private var filteredDeprecations: [Notice] {
        guard !searchText.isEmpty else { return deprecations }
        let query = searchText.lowercased()
        return deprecations.filter {
            $0.title.lowercased().contains(query) ||
            $0.documentURL.lowercased().contains(query)
        }
    }

    private var groupedBySymbol: [(symbol: String, items: [IdentifiedDeprecation])] {
        let grouped = Dictionary(grouping: filteredDeprecations.enumerated().map { ($0.offset, $0.element) }) {
            extractDeprecatedSymbol(from: $0.1.title)
        }
        return grouped
            .map { (symbol: $0.key, items: $0.value.map { IdentifiedDeprecation($0.1, index: $0.0) }) }
            .sorted { $0.items.count > $1.items.count }
    }

    /// Extracts the deprecated symbol name from a deprecation message
    private func extractDeprecatedSymbol(from title: String) -> String {
        // Common patterns:
        // "'UIWebView' is deprecated"
        // "'NSURLConnection' was deprecated in iOS 9.0"
        // "init(coder:) has been deprecated"

        // Try to extract quoted symbol first
        if let range = title.range(of: #"'([^']+)'"#, options: .regularExpression) {
            let match = title[range]
            // Remove the quotes
            return String(match.dropFirst().dropLast())
        }

        // Fall back to the full title if no pattern matches
        return title
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

            Spacer()

            Text("\(filteredDeprecations.count) deprecations")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    // MARK: - Empty States

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Deprecations", systemImage: "checkmark.circle")
        } description: {
            Text("Great news! No deprecated APIs found in this build.")
        }
    }

    private var noResultsState: some View {
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

    // MARK: - List

    private var deprecationsList: some View {
        List(selection: $selectedIDs) {
            ForEach(groupedBySymbol, id: \.symbol) { group in
                Section {
                    ForEach(group.items) { item in
                        DeprecationRow(deprecation: item.notice)
                            .tag(item.id)
                            .onTapGesture(count: 2) { openInXcode(item.notice) }
                    }
                } header: {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundStyle(.orange)

                        Text(group.symbol)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .lineLimit(1)

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

    // MARK: - Helpers

    private func openInXcode(_ notice: Notice) {
        guard !notice.documentURL.isEmpty else { return }

        let filePath: String
        if notice.documentURL.hasPrefix("file://") {
            if let url = URL(string: notice.documentURL) {
                filePath = url.path
            } else if let decoded = notice.documentURL.removingPercentEncoding,
                      let url = URL(string: decoded) {
                filePath = url.path
            } else {
                filePath = String(notice.documentURL.dropFirst(7))
            }
        } else {
            filePath = notice.documentURL
        }

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/xed")
        task.arguments = ["--line", "\(notice.startingLineNumber)", filePath]

        do {
            try task.run()
        } catch {
            print("Failed to open in Xcode: \(error)")
        }
    }
}

// MARK: - Supporting Types

private struct IdentifiedDeprecation: Identifiable {
    let notice: Notice
    let index: Int

    var id: String { "\(notice.documentURL):\(notice.startingLineNumber):\(index)" }

    init(_ notice: Notice, index: Int) {
        self.notice = notice
        self.index = index
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
