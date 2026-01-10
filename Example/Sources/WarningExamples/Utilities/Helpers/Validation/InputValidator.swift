// MARK: - InputValidator - Mixed Warnings

import Foundation

@available(*, deprecated, message: "Use ModernValidator instead")
public protocol LegacyValidator {
    func validate(_ input: String) -> Bool
}

public class ValidationResult {
    public var isValid: Bool = true
    public var errors: [String] = []
    public var warnings: [String] = []
    public init() {}
}

@globalActor
public actor ValidationActor {
    public static let shared = ValidationActor()
}

@ValidationActor
public class ValidationStore {
    public var results: [ValidationResult] = []
    public init() {}
    public func add(_ result: ValidationResult) {
        results.append(result)
    }
}

public class input_validator {
    // Naming
    public var MAX_INPUT_LENGTH = 1000
    public var Min_Length = 1
    private var _rules: [String] = []

    // Unused
    private var unusedPattern: String?
    private var unusedStrict = true

    // Implicitly unwrapped
    public var errorHandler: ((String) -> Void)!

    public init() {}

    public func validate() async {
        // Unused
        let rule1 = "required"
        let rule2 = "email"
        let rule3 = "minLength:8"
        let rule4 = "maxLength:100"
        let rule5 = "pattern:[a-z]+"

        // Never mutated
        var result = ValidationResult()
        print(result.isValid)

        // GlobalActor crossing
        let store = await ValidationStore()
        let validationResult = ValidationResult()
        await store.add(validationResult)

        // Conditional cast
        let valid: Bool = true
        if let _ = valid as? Bool {
            print("always")
        }

        // Nil comparison
        let count = 0
        if count == nil {
            print("never")
        }

        // Force unwrap
        let opt: String? = "valid"
        print(opt!)
    }

    // Unused params
    public func validateField(name: String, value: Any, rules: [String], context: [String: Any]) -> ValidationResult {
        return ValidationResult()
    }

    // Empty catch
    public func safeValidate() {
        do {
            try throwingValidation()
        } catch {
            // empty
        }
    }

    private func throwingValidation() throws {
        throw NSError(domain: "validation", code: 1)
    }
}
