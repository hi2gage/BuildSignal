// MARK: - PaymentProcessor - Mixed Warnings

import Foundation

@available(*, deprecated, message: "Use SecurePaymentProcessor instead")
public protocol LegacyPaymentHandler {
    func processLegacy(_ amount: Double)
}

public class PaymentData {
    public var amount: Double = 0.0
    public var currency: String = "USD"
    public var cardLast4: String = ""
    public init() {}
}

public actor PaymentActor {
    public init() {}
    public func process(_ data: PaymentData) {
        print(data.amount)
    }
}

public class payment_processor: LegacyPaymentHandler {
    // Naming
    public var MERCHANT_ID = ""
    public var Api_Key = ""
    private var _transactionId: String?

    // Unused
    private var unusedFees = 0.029
    private var unusedTimeout = 30

    // Implicitly unwrapped
    public var gateway: String!

    public init() {}

    public func processLegacy(_ amount: Double) {
        print(amount)
    }

    public func chargeCard() async {
        // Shared deprecated APIs
        DeprecatedNetworkClient.shared.fetch("/api/payment")
        DeprecatedNetworkClient.shared.post("/api/payment/charge", data: [:])
        DeprecatedUnsafeStorage.shared.save("payment", value: [:])
        DeprecatedPrintLogger.shared.log("Processing payment")
        DeprecatedTokenManager.shared.setToken("payment_token")
        let _ = DeprecatedPasswordAuth.shared.authenticate(password: "pay")

        // Local deprecated
        let handler: LegacyPaymentHandler = payment_processor()
        handler.processLegacy(99.99)

        // Unused
        let token1 = "tok_123"
        let token2 = "tok_456"
        let token3 = UUID()

        // Never mutated
        var paymentData = PaymentData()
        print(paymentData.amount)

        // Actor with non-sendable
        let actor = PaymentActor()
        let data = PaymentData()
        await actor.process(data)

        // Conditional cast
        let amount: Double = 99.99
        if let _ = amount as? Double {
            print("always")
        }

        // Force unwrap
        let opt: String? = "4242"
        print(opt!)

        _ = (token1, token2, token3)
    }

    // Unused params
    public func refund(transactionId: String, amount: Double, reason: String, metadata: [String: Any]) {
        DeprecatedCacheManager.shared.store("refund")
        print("refunding")
    }

    // Unreachable
    public func cancel() {
        return
        _transactionId = nil
    }
}
