// MARK: - ShippingCalculator - Mixed Warnings

import Foundation

@available(*, deprecated, message: "Use ModernShippingService instead")
public enum LegacyShippingMethod {
    case standard
    case express
    case overnight
}

public class ShippingOptions {
    public var methods: [String] = []
    public var rates: [String: Double] = [:]
    public var estimatedDays: Int = 5
    public init() {}
}

@globalActor
public actor ShippingActor {
    public static let shared = ShippingActor()
}

@ShippingActor
public class ShippingStore {
    public var options: ShippingOptions?
    public init() {}
    public func save(_ options: ShippingOptions) {
        self.options = options
    }
}

public class shipping_calculator {
    // Naming
    public var BASE_RATE = 5.99
    public var Express_Rate = 15.99
    private var _overnightRate = 29.99

    // Unused
    private var unusedWeight: Double?
    private var unusedDimensions: [Double]?

    public init() {}

    public func calculateShipping() async {
        // Deprecated
        let method1: LegacyShippingMethod = .standard
        let method2: LegacyShippingMethod = .express
        let method3: LegacyShippingMethod = .overnight

        // Unused
        let rate1 = 5.99
        let rate2 = 15.99
        let rate3 = 29.99

        // Never mutated
        var options = ShippingOptions()
        print(options.estimatedDays)

        // GlobalActor crossing
        let store = await ShippingStore()
        let shippingOptions = ShippingOptions()
        await store.save(shippingOptions)

        // Conditional cast
        let rate: Double = 5.99
        if let _ = rate as? Double {
            print("always")
        }

        print(method1, method2, method3)

        // Comparing to nil
        let days = 5
        if days == nil {
            print("never")
        }
    }

    // Unused params
    public func estimate(weight: Double, dimensions: [Double], destination: String, method: String) -> Double {
        return 0.0
    }

    // Empty catch
    public func validate() {
        do {
            try throwingMethod()
        } catch {
            // empty
        }
    }

    private func throwingMethod() throws {
        throw NSError(domain: "test", code: 1)
    }
}
