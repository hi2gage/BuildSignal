import Combine
import Foundation
import SwiftUI

/// Manages custom warning categories with persistence.
@MainActor
final class CategoryManager: ObservableObject {
    static let shared = CategoryManager()

    /// All custom categories created by the user
    @Published private(set) var customCategories: [WarningCategory] = []

    /// All categories (built-in + custom), sorted by sortOrder
    var allCategories: [WarningCategory] {
        (WarningCategory.builtInCategories + customCategories).sorted { $0.sortOrder < $1.sortOrder }
    }

    private let userDefaultsKey = "CustomWarningCategories"
    private let fileManager = FileManager.default

    private init() {
        loadCategories()
    }

    #if DEBUG
    /// Creates a CategoryManager with preset data for previews (skips UserDefaults)
    static func forPreview(with categories: [WarningCategory] = []) -> CategoryManager {
        let manager = CategoryManager(forPreview: true)
        manager.customCategories = categories
        return manager
    }

    private init(forPreview: Bool) {
        // Skip loadCategories() for previews
    }
    #endif

    // MARK: - CRUD Operations

    /// Add a new custom category
    func addCategory(_ category: WarningCategory) {
        var newCategory = category
        // Ensure it has a proper custom ID
        if !newCategory.id.hasPrefix("custom_") {
            newCategory = WarningCategory(
                id: "custom_\(UUID().uuidString.prefix(8))",
                name: category.name,
                icon: category.icon,
                colorName: category.colorName,
                patterns: category.patterns,
                sortOrder: category.sortOrder,
                isBuiltIn: false
            )
        }
        customCategories.append(newCategory)
        saveCategories()
    }

    /// Update an existing custom category
    func updateCategory(_ category: WarningCategory) {
        guard let index = customCategories.firstIndex(where: { $0.id == category.id }) else { return }
        customCategories[index] = category
        saveCategories()
    }

    /// Delete a custom category
    func deleteCategory(_ category: WarningCategory) {
        customCategories.removeAll { $0.id == category.id }
        saveCategories()
    }

    /// Delete categories at offsets (for SwiftUI List)
    func deleteCategories(at offsets: IndexSet) {
        customCategories.remove(atOffsets: offsets)
        saveCategories()
    }

    /// Move categories (for reordering)
    func moveCategories(from source: IndexSet, to destination: Int) {
        customCategories.move(fromOffsets: source, toOffset: destination)
        // Update sort orders after move
        // Custom categories use negative sort orders so they're checked before built-in ones
        for (index, _) in customCategories.enumerated() {
            customCategories[index].sortOrder = -1000 + index
        }
        saveCategories()
    }

    /// Create a new empty category with defaults
    func createNewCategory() -> WarningCategory {
        // Custom categories use negative sort orders so they're checked before built-in ones
        // New categories go at the end of custom categories but still before built-in
        let nextSortOrder = (customCategories.map(\.sortOrder).max() ?? -1001) + 1
        return WarningCategory(
            id: "custom_\(UUID().uuidString.prefix(8))",
            name: "New Category",
            icon: "tag",
            colorName: "blue",
            patterns: [],
            sortOrder: nextSortOrder,
            isBuiltIn: false
        )
    }

    // MARK: - Persistence

    private func loadCategories() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return }
        do {
            let decoder = JSONDecoder()
            var loaded = try decoder.decode([WarningCategory].self, from: data)

            // Migrate old categories with positive sort orders to negative
            // so custom categories are checked before built-in ones
            let needsMigration = loaded.contains { $0.sortOrder >= 0 }
            if needsMigration {
                for index in loaded.indices {
                    loaded[index].sortOrder = -1000 + index
                }
                customCategories = loaded
                saveCategories()
            } else {
                customCategories = loaded
            }
        } catch {
            print("Failed to load custom categories: \(error)")
        }
    }

    private func saveCategories() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(customCategories)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Failed to save custom categories: \(error)")
        }
    }

    // MARK: - Export/Import

    /// Export all custom categories to a JSON file
    func exportCategories() -> URL? {
        guard !customCategories.isEmpty else { return nil }

        do {
            let data = try WarningCategory.exportToJSON(customCategories)
            let tempURL = fileManager.temporaryDirectory.appendingPathComponent("BuildSignal-Categories.json")
            try data.write(to: tempURL)
            return tempURL
        } catch {
            print("Failed to export categories: \(error)")
            return nil
        }
    }

    /// Export specific categories to JSON data
    func exportCategoriesToData(_ categories: [WarningCategory]) throws -> Data {
        try WarningCategory.exportToJSON(categories)
    }

    /// Import categories from a JSON file URL
    func importCategories(from url: URL) throws -> [WarningCategory] {
        let data = try Data(contentsOf: url)
        let imported = try WarningCategory.importFromJSON(data)
        return imported
    }

    /// Add imported categories to custom categories
    func addImportedCategories(_ categories: [WarningCategory]) {
        for category in categories {
            // Check for duplicate names
            var name = category.name
            var counter = 1
            while customCategories.contains(where: { $0.name == name }) {
                counter += 1
                name = "\(category.name) (\(counter))"
            }

            let adjustedCategory = WarningCategory(
                id: category.id,
                name: name,
                icon: category.icon,
                colorName: category.colorName,
                patterns: category.patterns,
                sortOrder: (customCategories.map(\.sortOrder).max() ?? -1001) + 1,
                isBuiltIn: false
            )
            customCategories.append(adjustedCategory)
        }
        saveCategories()
    }

    /// Duplicate an existing category
    func duplicateCategory(_ category: WarningCategory) -> WarningCategory {
        let newCategory = WarningCategory(
            id: "custom_\(UUID().uuidString.prefix(8))",
            name: "\(category.name) (Copy)",
            icon: category.icon,
            colorName: category.colorName,
            patterns: category.patterns,
            sortOrder: (customCategories.map(\.sortOrder).max() ?? -1001) + 1,
            isBuiltIn: false
        )
        addCategory(newCategory)
        return newCategory
    }
}
