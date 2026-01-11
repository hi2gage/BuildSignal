import AppKit

extension ScopeOutlineViewController: NSOutlineViewDelegate {

    func outlineView(
        _ outlineView: NSOutlineView,
        viewFor tableColumn: NSTableColumn?,
        item: Any
    ) -> NSView? {
        guard let node = item as? DirectoryNode else { return nil }

        let frameRect = NSRect(
            x: 0,
            y: 0,
            width: tableColumn?.width ?? 200,
            height: Self.rowHeight
        )
        return ScopeTableViewCell(frame: frameRect, node: node)
    }

    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        Self.rowHeight
    }

    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard shouldSendSelectionUpdate else { return }
        guard let outlineView = notification.object as? NSOutlineView else { return }

        let selectedRow = outlineView.selectedRow
        guard selectedRow >= 0,
              let node = outlineView.item(atRow: selectedRow) as? DirectoryNode else {
            return
        }

        onSelectionChanged?(node.path, node.name)
    }

    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        true
    }

    func outlineView(
        _ outlineView: NSOutlineView,
        toolTipFor cell: NSCell,
        rect: NSRectPointer,
        tableColumn: NSTableColumn?,
        item: Any,
        mouseLocation: NSPoint
    ) -> String {
        (item as? DirectoryNode)?.path ?? ""
    }
}
