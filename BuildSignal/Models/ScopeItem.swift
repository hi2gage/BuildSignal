import Foundation

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
