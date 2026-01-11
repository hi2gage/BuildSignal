import Combine
import Foundation

/// Manager for tracking hidden deprecations with persistence.
/// Items are identified by a string key (typically the deprecation message).
@MainActor
final class HiddenManager: ObservableObject {
    static let shared = HiddenManager()

    /// Set of hidden item identifiers
    @Published private(set) var hiddenItems: Set<String> = []

    private let userDefaultsKey = "HiddenDeprecations"

    private init() {
        loadHiddenItems()
    }

    // MARK: - Public API

    /// Check if an item is hidden
    func isHidden(_ identifier: String) -> Bool {
        hiddenItems.contains(identifier)
    }

    /// Toggle hidden status for an item
    func toggleHidden(_ identifier: String) {
        if hiddenItems.contains(identifier) {
            hiddenItems.remove(identifier)
        } else {
            hiddenItems.insert(identifier)
        }
        saveHiddenItems()
    }

    /// Hide an item
    func hide(_ identifier: String) {
        hiddenItems.insert(identifier)
        saveHiddenItems()
    }

    /// Show a hidden item
    func show(_ identifier: String) {
        hiddenItems.remove(identifier)
        saveHiddenItems()
    }

    /// Hide multiple items
    func hideAll(_ identifiers: [String]) {
        for id in identifiers {
            hiddenItems.insert(id)
        }
        saveHiddenItems()
    }

    /// Show multiple items
    func showAll(_ identifiers: [String]) {
        for id in identifiers {
            hiddenItems.remove(id)
        }
        saveHiddenItems()
    }

    /// Clear all hidden items (show everything)
    func clearAll() {
        hiddenItems.removeAll()
        saveHiddenItems()
    }

    /// Count of hidden items
    var count: Int {
        hiddenItems.count
    }

    // MARK: - Persistence

    private func loadHiddenItems() {
        if let array = UserDefaults.standard.stringArray(forKey: userDefaultsKey) {
            hiddenItems = Set(array)
        }
    }

    private func saveHiddenItems() {
        UserDefaults.standard.set(Array(hiddenItems), forKey: userDefaultsKey)
    }
}

// MARK: - Hidden Identifier Helpers

extension HiddenManager {
    /// Creates a unique identifier for a deprecation based on its message.
    /// Hiding by message means all occurrences of the same deprecation are hidden.
    static func identifier(forDeprecationMessage message: String) -> String {
        "deprecation:\(message)"
    }

    /// Creates a unique identifier for an individual deprecation occurrence.
    static func identifier(forIndividualDeprecation documentURL: String, line: UInt64) -> String {
        "deprecation-individual:\(documentURL):\(line)"
    }
}
