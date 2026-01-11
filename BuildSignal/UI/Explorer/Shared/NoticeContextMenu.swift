import SwiftUI
import XCLogParser

/// A reusable context menu for notice items (warnings, deprecations).
struct NoticeContextMenu: View {
    let notice: Notice
    let onOpenInXcode: () -> Void
    let onRevealInNavigator: () -> Void
    let onCopy: () -> Void

    var body: some View {
        Button {
            onOpenInXcode()
        } label: {
            Label("Open in Xcode", systemImage: "hammer")
        }

        Button {
            onRevealInNavigator()
        } label: {
            Label("Reveal in Navigator", systemImage: "sidebar.left")
        }

        Divider()

        Button {
            onCopy()
        } label: {
            Label("Copy", systemImage: "doc.on.doc")
        }
    }

    /// Convenience initializer with default actions using shared utilities.
    init(
        notice: Notice,
        viewModel: ProjectDetailViewModel,
        customCopy: (() -> Void)? = nil
    ) {
        self.notice = notice
        self.onOpenInXcode = { NoticeUtilities.openInXcode(notice) }
        self.onRevealInNavigator = {
            let filePath = NoticeUtilities.getFilePath(from: notice.documentURL)
            guard !filePath.isEmpty else { return }
            let fileName = URL(fileURLWithPath: filePath).lastPathComponent
            viewModel.selectedScope = .directory(path: filePath, name: fileName)
        }
        self.onCopy = customCopy ?? { NoticeUtilities.copyToClipboard(notice) }
    }

    /// Full control initializer for custom actions.
    init(
        notice: Notice,
        onOpenInXcode: @escaping () -> Void,
        onRevealInNavigator: @escaping () -> Void,
        onCopy: @escaping () -> Void
    ) {
        self.notice = notice
        self.onOpenInXcode = onOpenInXcode
        self.onRevealInNavigator = onRevealInNavigator
        self.onCopy = onCopy
    }
}

// MARK: - View Modifier for Applying Context Menu

extension View {
    /// Applies a standard notice context menu to the view.
    func noticeContextMenu(
        notice: Notice,
        viewModel: ProjectDetailViewModel
    ) -> some View {
        self.contextMenu {
            NoticeContextMenu(notice: notice, viewModel: viewModel)
        }
    }
}
