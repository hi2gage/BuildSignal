import SwiftUI
import XCLogParser

/// A row displaying a single warning with its icon, message, file, and line number.
struct WarningRow: View {
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

// MARK: - Previews

#Preview("Swift Warning") {
    WarningRow(
        warning: Notice(
            type: .swiftWarning,
            title: "Variable 'result' was never mutated; consider changing to 'let' constant",
            clangFlag: nil,
            documentURL: "file:///Users/dev/MyApp/Sources/ViewModel.swift",
            severity: 1,
            startingLineNumber: 42,
            endingLineNumber: 42,
            startingColumnNumber: 10,
            endingColumnNumber: 16,
            characterRangeEnd: 0,
            characterRangeStart: 0,
            interfaceBuilderIdentifier: nil,
            detail: nil
        ),
        showFile: true
    )
    .padding()
}

#Preview("Deprecation Warning") {
    WarningRow(
        warning: Notice(
            type: .deprecatedWarning,
            title: "'UIWebView' is deprecated: first deprecated in iOS 12.0",
            clangFlag: nil,
            documentURL: "file:///Users/dev/MyApp/Sources/WebController.swift",
            severity: 1,
            startingLineNumber: 15,
            endingLineNumber: 15,
            startingColumnNumber: 5,
            endingColumnNumber: 14,
            characterRangeEnd: 0,
            characterRangeStart: 0,
            interfaceBuilderIdentifier: nil,
            detail: nil
        ),
        showFile: true
    )
    .padding()
}

#Preview("Without File") {
    WarningRow(
        warning: Notice(
            type: .swiftWarning,
            title: "Non-sendable type 'MyClass' passed in implicitly asynchronous call",
            clangFlag: nil,
            documentURL: "file:///Users/dev/MyApp/Sources/AsyncHelper.swift",
            severity: 1,
            startingLineNumber: 88,
            endingLineNumber: 88,
            startingColumnNumber: 1,
            endingColumnNumber: 20,
            characterRangeEnd: 0,
            characterRangeStart: 0,
            interfaceBuilderIdentifier: nil,
            detail: nil
        ),
        showFile: false
    )
    .padding()
}

#Preview("Project Warning") {
    WarningRow(
        warning: Notice(
            type: .projectWarning,
            title: "The iOS deployment target is set to 12.0, but the range of supported versions is 14.0 to 17.0",
            clangFlag: nil,
            documentURL: "",
            severity: 1,
            startingLineNumber: 0,
            endingLineNumber: 0,
            startingColumnNumber: 0,
            endingColumnNumber: 0,
            characterRangeEnd: 0,
            characterRangeStart: 0,
            interfaceBuilderIdentifier: nil,
            detail: nil
        ),
        showFile: true
    )
    .padding()
}
