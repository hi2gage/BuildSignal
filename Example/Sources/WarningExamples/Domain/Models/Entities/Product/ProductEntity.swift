// MARK: - ProductEntity - Mixed Warnings

import Foundation

@available(*, deprecated, message: "Use ProductModel instead")
public class LegacyProduct {
    public var sku: String = ""
    public var price: Double = 0.0
    public init() {}
}

public class ProductState {
    public var inventory: Int = 0
    public var available: Bool = true
    public var lastUpdated: Date = Date()
    public init() {}
}

public actor ProductActor {
    public init() {}
    public func update(_ state: ProductState) {
        print(state.inventory)
    }
}

public class product_entity {
    // Naming
    public var SKU_CODE = ""
    public var Unit_Price = 0.0
    private var _internalId = 0

    // Unused
    private var unusedCategory: String?
    private var unusedTags: [String] = []

    // Implicitly unwrapped
    public var imageURL: URL!

    public init() {}

    public func loadProduct() async {
        // Deprecated
        let product1 = LegacyProduct()
        let product2 = LegacyProduct()
        let product3 = LegacyProduct()
        product1.sku = "SKU001"
        product2.sku = "SKU002"
        product3.sku = "SKU003"

        // Unused
        let attr1 = "color:red"
        let attr2 = "size:large"
        let attr3 = ["brand": "acme"]

        // Never mutated
        var state = ProductState()
        print(state.available)

        // Actor with non-sendable
        let actor = ProductActor()
        let productState = ProductState()
        await actor.update(productState)

        // Conditional cast
        let price: Double = 9.99
        if let _ = price as? Double {
            print("always")
        }

        print(product1.sku, product2.sku, product3.sku)
    }

    // Unused params
    public func update(sku: String, name: String, price: Double, inventory: Int) {
        print("updating")
    }

    // Result unused
    private func validate() -> Bool { true }
    public func save() {
        validate()
        validate()
    }
}
