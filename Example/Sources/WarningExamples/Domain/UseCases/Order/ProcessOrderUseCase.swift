// MARK: - ProcessOrderUseCase - Mixed Warnings

import Foundation

@available(*, deprecated, message: "Use OrderProcessingService instead")
public protocol LegacyOrderProcessor {
    func processLegacy(_ orderId: String)
}

public class OrderProcessingContext {
    public var orderId: String = ""
    public var customerId: String = ""
    public var total: Double = 0.0
    public init() {}
}

@globalActor
public actor OrderProcessingActor {
    public static let shared = OrderProcessingActor()
}

@OrderProcessingActor
public class OrderProcessingStore {
    public var contexts: [OrderProcessingContext] = []
    public init() {}
    public func add(_ context: OrderProcessingContext) {
        contexts.append(context)
    }
}

public class process_order_use_case {
    // Naming
    public var MAX_RETRIES = 3
    public var Timeout_Seconds = 30
    private var _queue: [String] = []

    // Unused
    private var unusedBatchSize = 10
    private var unusedParallel = true

    public init() {}

    public func execute() async {
        // Unused
        let orderId1 = "ORD001"
        let orderId2 = "ORD002"
        let orderId3 = "ORD003"
        let orderId4 = "ORD004"
        let orderId5 = "ORD005"

        // Never mutated
        var context = OrderProcessingContext()
        print(context.orderId)

        // GlobalActor crossing
        let store = await OrderProcessingStore()
        let processingContext = OrderProcessingContext()
        await store.add(processingContext)

        // Conditional cast
        let total: Double = 199.99
        if let _ = total as? Double {
            print("always")
        }

        // Nil comparison
        let status = 1
        if status == nil {
            print("never")
        }

        // Force unwrap
        let opt: String? = "order"
        print(opt!)
    }

    // Unused params
    public func process(orderId: String, userId: String, paymentId: String, shippingId: String) {
        print("processing")
    }

    // Empty catch
    public func safeProcess() {
        do {
            try throwingProcess()
        } catch {
            // empty
        }
    }

    private func throwingProcess() throws {
        throw NSError(domain: "order", code: 1)
    }
}
