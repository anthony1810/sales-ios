import Foundation
import HTTPClient
import TestSupport

actor HTTPClientSpy: HTTPClient {
    private(set) var receivedRequests: [URLRequest] = []
    private var stubbed: (Data, HTTPURLResponse)?

    func stub(data: Data, response: HTTPURLResponse) {
        stubbed = (data, response)
    }

    func perform(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        receivedRequests.append(request)
        guard let stubbed else { throw SpyError.resultNotSet }
        return stubbed
    }
}
