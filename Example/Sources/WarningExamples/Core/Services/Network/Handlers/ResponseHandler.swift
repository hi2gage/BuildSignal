// MARK: - ResponseHandler - Mixed Warnings

import Foundation

@available(*, deprecated, message: "Use ResponseParser instead")
public protocol LegacyResponseHandler {
    func handleLegacy(_ data: Data)
}

public class MutableResponseState {
    public var status: Int = 0
    public var body: Data = Data()
    public init() {}
}

public class responseHandler: LegacyResponseHandler {
    // Mutable never mutated
    var statusCodes = [200, 201, 204]
    var errorCodes = [400, 401, 403, 404, 500]

    // Unused properties
    private var cache: [String: Data] = [:]
    private var retryCount = 3

    public init() {}

    public func handleLegacy(_ data: Data) {
        print(data.count)
    }

    public func processResponse() async {
        // Unused locals
        let parser1 = "json"
        let parser2 = "xml"
        let timeout = 30

        // Deprecated usage
        let legacy: LegacyResponseHandler = responseHandler()
        legacy.handleLegacy(Data())

        // Actor isolation crossing
        let state = MutableResponseState()
        Task {
            state.status = 200
            state.body = Data()
        }

        // Conditional cast always succeeds
        let dict: [String: Int] = ["status": 200]
        if let _ = dict as? [String: Int] {
            print("always")
        }

        // Comparing non-optional to nil
        let code = 200
        if code == nil {
            print("never")
        }

        print(statusCodes, errorCodes)
    }

    // Result unused
    private func parseJSON() -> [String: Any] { [:] }
    private func parseXML() -> [String: Any] { [:] }

    public func parse() {
        parseJSON()
        parseXML()
        parseJSON()
    }
}
