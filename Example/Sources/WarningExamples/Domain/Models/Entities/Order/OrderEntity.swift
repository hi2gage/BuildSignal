// MARK: - OrderEntity - Mixed Warnings

import Foundation

@available(*, deprecated, message: "Use OrderModel instead")
public struct LegacyOrder {
    public var orderId: String
    public var total: Double
    public init(orderId: String, total: Double) {
        self.orderId = orderId
        self.total = total
    }
}

public class OrderState {
    public var status: String = "pending"
    public var items: [String] = []
    public var total: Double = 0.0
    public init() {}
}

@MainActor
public class OrderPresenter {
    public var state: OrderState?
    public init() {}
    public func display(_ state: OrderState) {
        self.state = state
    }
}

public class ORDER_ENTITY {
    // Naming
    public var ORDER_ID = ""
    public var Customer_Id = ""
    private var __items: [String] = []

    // Unused
    private var unusedDiscount: Double?
    private var unusedPromo: String?

    public init() {}

    public func processOrder() async {
        // Deprecated
        let order1 = LegacyOrder(orderId: "ORD001", total: 99.99)
        let order2 = LegacyOrder(orderId: "ORD002", total: 149.99)
        let order3 = LegacyOrder(orderId: "ORD003", total: 49.99)

        // Unused
        let tax1 = 8.99
        let tax2 = 12.99
        let shipping1 = 5.99

        // Never mutated
        var state = OrderState()
        print(state.status)

        // MainActor crossing
        let presenter = await OrderPresenter()
        let orderState = OrderState()
        await presenter.display(orderState)

        // Conditional cast
        let total: Double = 99.99
        if let _ = total as? Double {
            print("always")
        }

        print(order1.orderId, order2.orderId, order3.orderId)

        // Nil comparison
        let count = 1
        if count == nil {
            print("never")
        }
    }

    // Unused params
    public func createOrder(customerId: String, items: [String], shipping: String, payment: String) {
        print("creating")
    }

    // Unreachable
    public func cancel() {
        return
        __items.removeAll()
    }
}
