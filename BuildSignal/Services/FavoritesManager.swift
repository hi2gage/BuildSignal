import Combine
import Foundation

/// Generic manager for tracking favorited items with persistence.
/// Items are identified by a string key that you define.
@MainActor
final class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()

    /// Set of favorited item identifiers
    @Published private(set) var favorites: Set<String> = []

    private let userDefaultsKey = "FavoritedDeprecations"

    private init() {
        loadFavorites()
    }

    // MARK: - Public API

    /// Check if an item is favorited
    func isFavorite(_ identifier: String) -> Bool {
        favorites.contains(identifier)
    }

    /// Toggle favorite status for an item
    func toggleFavorite(_ identifier: String) {
        if favorites.contains(identifier) {
            favorites.remove(identifier)
        } else {
            favorites.insert(identifier)
        }
        saveFavorites()
    }

    /// Add an item to favorites
    func addFavorite(_ identifier: String) {
        favorites.insert(identifier)
        saveFavorites()
    }

    /// Remove an item from favorites
    func removeFavorite(_ identifier: String) {
        favorites.remove(identifier)
        saveFavorites()
    }

    /// Add multiple items to favorites
    func addFavorites(_ identifiers: [String]) {
        for id in identifiers {
            favorites.insert(id)
        }
        saveFavorites()
    }

    /// Remove multiple items from favorites
    func removeFavorites(_ identifiers: [String]) {
        for id in identifiers {
            favorites.remove(id)
        }
        saveFavorites()
    }

    /// Clear all favorites
    func clearAll() {
        favorites.removeAll()
        saveFavorites()
    }

    // MARK: - Persistence

    private func loadFavorites() {
        if let array = UserDefaults.standard.stringArray(forKey: userDefaultsKey) {
            favorites = Set(array)
        }
    }

    private func saveFavorites() {
        UserDefaults.standard.set(Array(favorites), forKey: userDefaultsKey)
    }
}

// MARK: - Favorite Identifier Helpers

extension FavoritesManager {
    /// Creates a unique identifier for a deprecation based on its message.
    /// Using just the message means all occurrences of the same deprecation share favorite status.
    static func identifier(forDeprecationMessage message: String) -> String {
        "deprecation:\(message)"
    }

    /// Creates a unique identifier for an individual deprecation occurrence.
    /// Uses documentURL and line number for uniqueness.
    static func identifier(forIndividualDeprecation documentURL: String, line: UInt64) -> String {
        "deprecation-individual:\(documentURL):\(line)"
    }
}
