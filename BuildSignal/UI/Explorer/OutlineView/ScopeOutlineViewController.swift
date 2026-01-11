import AppKit

/// NSViewController managing an NSOutlineView for displaying the directory tree in the scope sidebar.
final class ScopeOutlineViewController: NSViewController {

    // MARK: - Views

    private(set) var scrollView: NSScrollView!
    private(set) var outlineView: NSOutlineView!

    // MARK: - Data

    var nodes: [DirectoryNode] = []
    var onSelectionChanged: ((String, String) -> Void)?

    // MARK: - State

    /// Flag to prevent selection update loops between SwiftUI and AppKit
    var shouldSendSelectionUpdate = true

    // MARK: - Constants

    static let rowHeight: CGFloat = 24

    // MARK: - Lifecycle

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.scrollerStyle = .overlay
        scrollView.drawsBackground = false
        view = scrollView

        outlineView = NSOutlineView()
        outlineView.dataSource = self
        outlineView.delegate = self
        outlineView.headerView = nil
        outlineView.rowHeight = Self.rowHeight
        outlineView.allowsMultipleSelection = false
        outlineView.autosaveExpandedItems = true
        outlineView.autosaveName = "ScopeSidebarExpansion"
        outlineView.indentationPerLevel = 14
        outlineView.style = .sourceList

        // Single column for cells
        let column = NSTableColumn(identifier: .init(rawValue: "DirectoryCell"))
        column.title = ""
        outlineView.addTableColumn(column)
        outlineView.outlineTableColumn = column

        scrollView.documentView = outlineView
        scrollView.contentView.contentInsets = NSEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
    }

    // MARK: - Selection Management

    /// Update selection from SwiftUI state
    func updateSelection(path: String?) {
        guard let path = path else {
            shouldSendSelectionUpdate = false
            outlineView.deselectAll(nil)
            shouldSendSelectionUpdate = true
            return
        }

        // Find the node with this path and select it
        if let node = findNode(withPath: path, in: nodes) {
            expandParents(of: node)
            let row = outlineView.row(forItem: node)
            if row >= 0 {
                shouldSendSelectionUpdate = false
                outlineView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
                outlineView.scrollRowToVisible(row)
                shouldSendSelectionUpdate = true
            }
        }
    }

    /// Find a node by its path in the tree
    func findNode(withPath path: String, in nodes: [DirectoryNode]) -> DirectoryNode? {
        for node in nodes {
            if node.path == path { return node }
            if let found = findNode(withPath: path, in: node.children) {
                return found
            }
        }
        return nil
    }

    /// Expand all parent nodes to reveal a target node
    private func expandParents(of targetNode: DirectoryNode) {
        // Build the path from root to target
        var pathToTarget: [DirectoryNode] = []
        for rootNode in nodes {
            if findPathToNode(target: targetNode, current: rootNode, path: &pathToTarget) {
                break
            }
        }

        // Expand each node in the path (from root to parent of target)
        // We expand all except the last one (which is the target itself)
        for i in 0..<max(0, pathToTarget.count - 1) {
            let nodeToExpand = pathToTarget[i]
            outlineView.expandItem(nodeToExpand)
        }
    }

    /// Find the path from root to target node, returns true if found
    private func findPathToNode(target: DirectoryNode, current: DirectoryNode, path: inout [DirectoryNode]) -> Bool {
        path.append(current)

        if current.path == target.path {
            return true
        }

        for child in current.children {
            if findPathToNode(target: target, current: child, path: &path) {
                return true
            }
        }

        path.removeLast()
        return false
    }

    // MARK: - Expansion State Management

    /// Get all currently expanded item paths
    func getExpandedPaths() -> Set<String> {
        var expandedPaths = Set<String>()
        collectExpandedPaths(from: nodes, into: &expandedPaths)
        return expandedPaths
    }

    private func collectExpandedPaths(from nodes: [DirectoryNode], into paths: inout Set<String>) {
        for node in nodes {
            if outlineView.isItemExpanded(node) {
                paths.insert(node.path)
                collectExpandedPaths(from: node.children, into: &paths)
            }
        }
    }

    /// Restore expansion state from a set of paths
    func restoreExpandedPaths(_ paths: Set<String>) {
        restoreExpansion(for: nodes, expandedPaths: paths)
    }

    private func restoreExpansion(for nodes: [DirectoryNode], expandedPaths: Set<String>) {
        for node in nodes {
            if expandedPaths.contains(node.path) {
                outlineView.expandItem(node)
                restoreExpansion(for: node.children, expandedPaths: expandedPaths)
            }
        }
    }
}
