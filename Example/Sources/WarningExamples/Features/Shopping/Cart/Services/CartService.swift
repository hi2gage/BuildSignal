// MARK: - CartService - Mixed Warnings

import Foundation

@available(*, deprecated, message: "Use CartManager instead")
public class LegacyCartService {
    public var items: [Int] = []
    public init() {}

    @available(*, deprecated)
    public func clearCart() {
        items.removeAll()
    }
}

public class CartState {
    public var itemCount: Int = 0
    public var isEmpty: Bool = true
    public var lastUpdated: Date = Date()
    public init() {}
}

@MainActor
public class CartPresenter {
    public var state: CartState?
    public init() {}
    public func update(_ state: CartState) {
        self.state = state
    }
}

public class CART_SERVICE {
    // Naming
    public var MAX_ITEMS = 100
    public var Cart_Total = 0.0
    private var __internalItems: [Int] = []

    // Unused
    private var unusedPromoCode: String?
    private var unusedShipping = 5.99

    // Implicitly unwrapped
    public var userId: Int!

    public init() {}

    public func processCart() async {
        // Shared deprecated APIs
        DeprecatedNetworkClient.shared.fetch("/api/cart")
        DeprecatedNetworkClient.shared.post("/api/cart/update", data: [:])
        DeprecatedUnsafeStorage.shared.save("cart", value: [:])
        DeprecatedPrintLogger.shared.log("Processing cart")
        let _ = deprecatedFormatDate(Date())

        // Local deprecated
        let service = LegacyCartService()
        service.clearCart()
        print(service.items)

        // Unused
        let temp1 = ["item1", "item2"]
        let temp2 = 99.99
        let temp3 = true

        // Never mutated
        var state = CartState()
        print(state.isEmpty)

        // MainActor crossing
        let presenter = await CartPresenter()
        let cartState = CartState()
        await presenter.update(cartState)

        // No async in await
        let _ = await syncCalculation()

        // Nil comparison
        let count = 0
        if count == nil {
            print("never")
        }

        _ = (temp1, temp2, temp3)
    }

    private func syncCalculation() -> Double { 0.0 }

    // Unused params
    public func checkout(items: [Int], shipping: String, payment: String, notes: String?) {
        DeprecatedTokenManager.shared.setToken("checkout")
        let _ = DeprecatedPasswordAuth.shared.authenticate(password: "pay")
        print("checkout")
    }

    // Identical conditions
    public func validateCart() {
        let valid = true
        if valid {
            print("valid")
        } else if valid {
            print("same")
        }
    }
}
