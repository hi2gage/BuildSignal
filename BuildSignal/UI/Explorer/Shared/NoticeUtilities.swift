import AppKit
import Foundation
import XCLogParser

/// Utility functions shared between WarningsListView and DeprecationsListView.
enum NoticeUtilities {
    /// Opens the notice location in Xcode at the specified line.
    static func openInXcode(_ notice: Notice) {
        guard !notice.documentURL.isEmpty else { return }

        let filePath = getFilePath(from: notice.documentURL)

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/xed")
        task.arguments = ["--line", "\(notice.startingLineNumber)", filePath]

        do {
            try task.run()
        } catch {
            print("Failed to open in Xcode: \(error)")
        }
    }

    /// Extracts a file path from a document URL (handles file:// prefix and percent encoding).
    static func getFilePath(from documentURL: String) -> String {
        guard !documentURL.isEmpty else { return "" }

        if documentURL.hasPrefix("file://") {
            if let url = URL(string: documentURL) {
                return url.path
            }
            if let decoded = documentURL.removingPercentEncoding,
               let url = URL(string: decoded) {
                return url.path
            }
            let pathPart = String(documentURL.dropFirst(7))
            return URL(fileURLWithPath: pathPart).path
        }

        return URL(fileURLWithPath: documentURL).path
    }

    /// Extracts the directory path from a document URL.
    static func getDirectoryPath(from documentURL: String) -> String {
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

    /// Extracts the filename from a document URL.
    static func extractFileName(from documentURL: String, fallback: String = "(Unknown)") -> String {
        guard !documentURL.isEmpty else { return fallback }
        let url = URL(string: documentURL) ?? URL(fileURLWithPath: documentURL)
        return url.lastPathComponent
    }

    /// Copies notice information to the clipboard in a standard format.
    static func copyToClipboard(_ notice: Notice) {
        let fileName = extractFileName(from: notice.documentURL)
        let line = notice.startingLineNumber > 0 ? ":\(notice.startingLineNumber)" : ""
        let text = "\(fileName)\(line): \(notice.title)"
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    /// Creates a formatted string for a notice (file:line: message).
    static func formatNotice(_ notice: Notice, fallbackFileName: String = "(Unknown)") -> String {
        let fileName = extractFileName(from: notice.documentURL, fallback: fallbackFileName)
        let line = notice.startingLineNumber > 0 ? ":\(notice.startingLineNumber)" : ""
        return "\(fileName)\(line): \(notice.title)"
    }
}
