import Foundation
import HTTPClient
import TestSupport

final class HTTPClientStub: HTTPClient, Sendable {
    enum Outcome: Sendable {
        case success(Data)
        case unauthorized(Data)
        case failure
    }

    struct ConnectivityError: Error {}

    private let outcomes: LockIsolated<[URL: [Outcome]]>
    private let requests = LockIsolated<[URLRequest]>([])

    var receivedRequests: [URLRequest] { requests.value }

    init(_ outcomes: [URL: [Outcome]]) {
        self.outcomes = LockIsolated(outcomes)
    }

    static var offline: HTTPClientStub { HTTPClientStub([:]) }

    func perform(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        requests.withValue { $0.append(request) }
        guard let url = request.url else { throw ConnectivityError() }

        let outcome: Outcome = outcomes.withValue { queues in
            guard var queue = queues[url], queue.isEmpty == false else { return .failure }
            let next = queue.removeFirst()
            queues[url] = queue
            return next
        }

        switch outcome {
        case let .success(data):
            return (data, okHTTPURLResponse(for: url))
        case let .unauthorized(data):
            return (data, anyHTTPURLResponse(statusCode: unauthorizedStatusCode))
        case .failure:
            throw ConnectivityError()
        }
    }
}
