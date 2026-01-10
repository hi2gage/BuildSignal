// MARK: - ItemRepository - Mixed Warnings

import Foundation

@available(*, deprecated, message: "Use ItemService instead")
public class LegacyItemStore {
    public init() {}
    public func getItems() -> [String] { [] }
}

public class ItemCache {
    public var items: [String] = []
    public var timestamps: [Date] = []
    public init() {}
}

@MainActor
public class ItemViewModel {
    public var displayItems: [String] = []
    public init() {}
    public func refresh() {
        displayItems = ["refreshed"]
    }
}

public class item_repository {
    // Mixed naming issues
    public var TABLE_NAME = "items"
    public var Cache_Size = 50
    private var __privateCache = [String]()

    // Unused properties
    private var unusedConnection: Any? = nil
    private var unusedRetries = 3

    public init() {}

    public func loadItems() async {
        // Deprecated
        let store = LegacyItemStore()
        let _ = store.getItems()

        // Unused
        let temp1 = "temporary"
        let temp2 = [1, 2, 3]
        let temp3 = Date()

        // Never mutated
        var cache = ItemCache()
        print(cache.items)

        // MainActor crossing
        let viewModel = await ItemViewModel()
        await viewModel.refresh()

        // Non-sendable
        let itemCache = ItemCache()
        Task.detached {
            print(itemCache.items)
        }

        // Nil comparison
        let count = 10
        if count == nil {
            print("never")
        }
    }

    // Unused params
    public func queryItems(filter: String, sort: String, limit: Int, offset: Int) -> [String] {
        return []
    }

    // Force unwrap chain
    public func dangerousAccess() {
        let opt1: String? = "a"
        let opt2: Int? = 1
        let opt3: Bool? = true
        print(opt1!, opt2!, opt3!)
    }
}
