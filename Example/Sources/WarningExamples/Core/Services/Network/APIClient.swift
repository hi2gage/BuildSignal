// MARK: - APIClient - Mixed Warnings

import Foundation

@available(*, deprecated, message: "Use ModernAPIClient instead")
public class LegacyHTTPClient {
    public init() {}
    public func fetch() -> Data { Data() }
}

public class NonSendableResponse {
    public var data: Data = Data()
    public var headers: [String: String] = [:]
    public init() {}
}

public class APIClient {
    // Unused variables
    private var unusedCache = [String: Any]()
    private var unusedTimeout = 30.0

    // Implicitly unwrapped optional
    public var baseURL: URL!

    // Non-standard naming
    public var API_KEY = ""
    public var Request_Timeout = 60

    public init() {}

    public func makeRequest() async {
        // Deprecated API usage
        let legacy = LegacyHTTPClient()
        let _ = legacy.fetch()

        // Unused local variables
        let config1 = "default"
        let config2 = ["retry": true]
        let config3 = 3

        // Variable never mutated
        var endpoint = "/api/v1"
        print(endpoint)

        // Non-sendable type across isolation boundary
        let response = NonSendableResponse()
        Task.detached {
            print(response.data)
        }

        // Unnecessary conditional cast
        let stringVal: String = "test"
        if let _ = stringVal as? String {
            print("always true")
        }

        // No async in await
        let _ = await syncFunction()
    }

    private func syncFunction() -> Int { 42 }
}
