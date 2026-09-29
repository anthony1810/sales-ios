import Foundation
import HTTPClient
import TestSupport

final class HTTPClientStub: HTTPClient, Sendable {
    private let outcome: LockIsolated<Result<(Data, HTTPURLResponse), Error>>
    private let requests = LockIsolated<[URLRequest]>([])

    var receivedRequests: [URLRequest] { requests.value }

    init(data: Data, response: HTTPURLResponse) {
        outcome = LockIsolated(.success((data, response)))
    }

    init(failure: Error) {
        outcome = LockIsolated(.failure(failure))
    }

    func perform(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        requests.withValue { $0.append(request) }
        return try outcome.value.get()
    }
}
