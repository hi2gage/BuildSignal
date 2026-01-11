import AppKit

extension ScopeOutlineViewController: NSOutlineViewDataSource {

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let node = item as? DirectoryNode {
            return node.children.count
        }
        return nodes.count // Root level
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let node = item as? DirectoryNode {
            return node.children[index]
        }
        return nodes[index]
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let node = item as? DirectoryNode {
            return !node.isLeaf
        }
        return false
    }

    // MARK: - Expansion Persistence

    func outlineView(_ outlineView: NSOutlineView, persistentObjectForItem item: Any?) -> Any? {
        (item as? DirectoryNode)?.path
    }

    func outlineView(_ outlineView: NSOutlineView, itemForPersistentObject object: Any) -> Any? {
        guard let path = object as? String else { return nil }
        return findNode(withPath: path, in: nodes)
    }
}
