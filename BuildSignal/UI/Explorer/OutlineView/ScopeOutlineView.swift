import SwiftUI

/// SwiftUI wrapper for the NSOutlineView-based directory tree.
struct ScopeOutlineView: NSViewControllerRepresentable {

    let nodes: [DirectoryNode]
    let selectedPath: String?
    let onSelect: (String, String) -> Void // (path, name)

    func makeNSViewController(context: Context) -> ScopeOutlineViewController {
        let controller = ScopeOutlineViewController()
        controller.nodes = nodes
        controller.onSelectionChanged = onSelect
        context.coordinator.controller = controller
        return controller
    }

    func updateNSViewController(_ controller: ScopeOutlineViewController, context: Context) {
        // Only update nodes if the structure actually changed
        // Compare by checking if paths and counts are the same
        let nodesChanged = !nodesAreEquivalent(controller.nodes, nodes)
        if nodesChanged {
            // Save expansion state before reload
            let expandedPaths = controller.getExpandedPaths()

            controller.nodes = nodes
            controller.outlineView?.reloadData()

            // Restore expansion state after reload
            controller.restoreExpandedPaths(expandedPaths)
        }

        // Sync selection from SwiftUI -> NSOutlineView
        controller.updateSelection(path: selectedPath)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject {
        weak var controller: ScopeOutlineViewController?
    }

    /// Compare nodes by their essential data (path and warning count) to avoid unnecessary reloads
    private func nodesAreEquivalent(_ lhs: [DirectoryNode], _ rhs: [DirectoryNode]) -> Bool {
        guard lhs.count == rhs.count else { return false }
        for (l, r) in zip(lhs, rhs) {
            if !nodeIsEquivalent(l, r) { return false }
        }
        return true
    }

    private func nodeIsEquivalent(_ lhs: DirectoryNode, _ rhs: DirectoryNode) -> Bool {
        guard lhs.path == rhs.path,
              lhs.warningCount == rhs.warningCount,
              lhs.children.count == rhs.children.count else {
            return false
        }
        for (l, r) in zip(lhs.children, rhs.children) {
            if !nodeIsEquivalent(l, r) { return false }
        }
        return true
    }
}
