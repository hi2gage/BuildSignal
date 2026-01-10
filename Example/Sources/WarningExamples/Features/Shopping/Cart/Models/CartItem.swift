// MARK: - CartItem - Mixed Warnings

import Foundation

@available(*, deprecated, message: "Use ModernCartItem instead")
public struct LegacyCartEntry {
    public var productId: Int
    public var quantity: Int
    public init(productId: Int, quantity: Int) {
        self.productId = productId
        self.quantity = quantity
    }
}

public class CartData {
    public var items: [String] = []
    public var total: Double = 0.0
    public var currency: String = "USD"
    public init() {}
}

public actor CartActor {
    public init() {}
    public func add(_ data: CartData) {
        print(data.items)
    }
}

public class cart_item {
    // Naming
    public var PRODUCT_ID = 0
    public var Item_Name = ""
    private var _quantity = 1

    // Unused
    private var unusedDiscount: Double?
    private var unusedTaxRate = 0.08

    public init() {}

    public func addToCart() async {
        // Deprecated
        let entry1 = LegacyCartEntry(productId: 1, quantity: 2)
        let entry2 = LegacyCartEntry(productId: 2, quantity: 1)
        let entry3 = LegacyCartEntry(productId: 3, quantity: 5)

        // Unused
        let price1 = 19.99
        let price2 = 29.99
        let price3 = 9.99

        // Never mutated
        var cartData = CartData()
        print(cartData.total)

        // Actor with non-sendable
        let actor = CartActor()
        let data = CartData()
        await actor.add(data)

        // Conditional cast
        let qty: Int = 1
        if let _ = qty as? Int {
            print("always")
        }

        print(entry1.quantity, entry2.quantity, entry3.quantity)

        // Force unwrap
        let opt: Double? = 9.99
        print(opt!)
    }

    // Unused params
    public func updateItem(id: Int, quantity: Int, options: [String: Any], metadata: [String: String]) {
        print("updating")
    }

    // Result unused
    private func calculateSubtotal() -> Double { 0.0 }
    private func calculateTax() -> Double { 0.0 }

    public func refresh() {
        calculateSubtotal()
        calculateTax()
        calculateSubtotal()
    }
}
