import Combine
import SwiftUI

// MARK: - Selectable Item Protocol

/// Protocol for items that can be selected and copied in a list.
protocol SelectableItem: Identifiable {
    /// Unique identifier for selection tracking
    var id: String { get }

    /// Text representation for copying to clipboard
    var copyableText: String { get }
}

// MARK: - Selection Manager

/// Observable manager for tracking selection state in lists.
/// Use this to manage selection across any list view.
@MainActor
final class SelectionManager<Item: SelectableItem>: ObservableObject {
    @Published var selectedIDs: Set<String> = []

    /// All items currently available (set by the view)
    var items: [Item] = []

    /// Currently selected items
    var selectedItems: [Item] {
        items.filter { selectedIDs.contains($0.id) }
    }

    /// Whether any items are selected
    var hasSelection: Bool {
        !selectedIDs.isEmpty
    }

    /// Number of selected items
    var selectionCount: Int {
        selectedIDs.count
    }

    // MARK: - Selection Actions

    func select(_ item: Item) {
        selectedIDs.insert(item.id)
    }

    func deselect(_ item: Item) {
        selectedIDs.remove(item.id)
    }

    func toggle(_ item: Item) {
        if selectedIDs.contains(item.id) {
            selectedIDs.remove(item.id)
        } else {
            selectedIDs.insert(item.id)
        }
    }

    func selectAll() {
        selectedIDs = Set(items.map(\.id))
    }

    func deselectAll() {
        selectedIDs.removeAll()
    }

    func selectItems(_ items: [Item]) {
        for item in items {
            selectedIDs.insert(item.id)
        }
    }

    func isSelected(_ item: Item) -> Bool {
        selectedIDs.contains(item.id)
    }

    // MARK: - Copy Support

    /// Returns the combined copyable text for all selected items
    func copyableText(separator: String = "\n") -> String {
        selectedItems.map(\.copyableText).joined(separator: separator)
    }

    /// Copies selected items to the clipboard
    func copyToClipboard() {
        guard hasSelection else { return }
        let text = copyableText()
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}

// MARK: - Selectable List View Modifier

/// View modifier that adds selection and copy support to a list.
struct SelectableListModifier<Item: SelectableItem>: ViewModifier {
    @ObservedObject var selectionManager: SelectionManager<Item>

    func body(content: Content) -> some View {
        content
            .copyable(selectionManager.hasSelection ? [selectionManager.copyableText()] : [])
            .onDeleteCommand {
                selectionManager.deselectAll()
            }
    }
}

extension View {
    /// Makes a view support selection and copying using a SelectionManager.
    func selectableList<Item: SelectableItem>(manager: SelectionManager<Item>) -> some View {
        modifier(SelectableListModifier(selectionManager: manager))
    }
}

// MARK: - Selection Binding Helper

/// Creates a binding to Set<String> from a SelectionManager for use with List(selection:)
extension SelectionManager {
    var selectionBinding: Binding<Set<String>> {
        Binding(
            get: { self.selectedIDs },
            set: { newValue in
                DispatchQueue.main.async {
                    self.selectedIDs = newValue
                }
            }
        )
    }
}

// MARK: - Toolbar Selection Info

/// A view that displays selection count info, suitable for toolbars.
struct SelectionInfoView: View {
    let count: Int

    var body: some View {
        if count > 0 {
            Text("\(count) selected")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Select All Button

/// A button that toggles select all / deselect all.
struct SelectAllButton<Item: SelectableItem>: View {
    @ObservedObject var selectionManager: SelectionManager<Item>
    let itemCount: Int

    private var allSelected: Bool {
        selectionManager.selectionCount == itemCount && itemCount > 0
    }

    var body: some View {
        Button {
            if allSelected {
                selectionManager.deselectAll()
            } else {
                selectionManager.selectAll()
            }
        } label: {
            Image(systemName: allSelected ? "checkmark.circle.fill" : "checkmark.circle")
        }
        .help(allSelected ? "Deselect All" : "Select All")
        .disabled(itemCount == 0)
    }
}
