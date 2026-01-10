// MARK: - MathUtils - Mixed Warnings

import Foundation

@available(*, deprecated, message: "Use ModernMath instead")
public class LegacyMathOps {
    public init() {}

    @available(*, deprecated, renamed: "add(_:_:)")
    public func sum(_ a: Int, _ b: Int) -> Int {
        return a + b
    }
}

public class MathContext {
    public var precision: Int = 10
    public var roundingMode: String = "halfUp"
    public var result: Double = 0.0
    public init() {}
}

public actor MathActor {
    public init() {}
    public func compute(_ context: MathContext) {
        print(context.precision)
    }
}

public class math_utils {
    // Naming
    public var DEFAULT_PRECISION = 10
    public var Rounding_Mode = "halfUp"
    private var _epsilon = 0.00001

    // Unused
    private var unusedBase = 10
    private var unusedScale = 1.0

    public init() {}

    public func calculate() async {
        // Deprecated
        let ops = LegacyMathOps()
        let _ = ops.sum(1, 2)
        let _ = ops.sum(3, 4)
        let _ = ops.sum(5, 6)

        // Unused
        let num1 = 42
        let num2 = 3.14
        let num3 = [1, 2, 3]

        // Never mutated
        var context = MathContext()
        print(context.result)

        // Actor with non-sendable
        let actor = MathActor()
        let mathContext = MathContext()
        await actor.compute(mathContext)

        // Conditional cast
        let value: Double = 3.14
        if let _ = value as? Double {
            print("always")
        }

        // Force unwrap
        let opt: Int? = 42
        print(opt!)
    }

    // Unused params
    public func calculate(a: Double, b: Double, operation: String, precision: Int) -> Double {
        return 0.0
    }

    // Identical conditions
    public func checkOverflow() {
        let overflow = false
        if overflow {
            print("overflow")
        } else if overflow {
            print("same")
        }
    }
}
