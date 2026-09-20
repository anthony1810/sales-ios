import Foundation
import TestSupport
import Testing

@testable import HTTPClientLive

@Suite(.serialized) final class URLSessionHTTPClientTests {
    deinit {
        URLProtocolStub.removeStub()
        leakTrackers.value.forEach { $0.verify() }
    }

    @Test func perform_signedPostRequest_sendsTheURLMethodAndHeader() async {
        var request = URLRequest(url: URL(string: "https://a-specific-url.com")!)
        request.httpMethod = "POST"
        request.setValue("a-token", forHTTPHeaderField: "Authorization")
        let observed = LockIsolated<URLRequest?>(nil)
        URLProtocolStub.observeRequests { observed.setValue($0) }
        let sut = makeSUT()

        _ = try? await sut.perform(request)

        #expect(observed.value?.url == request.url)
        #expect(observed.value?.httpMethod == "POST")
        #expect(observed.value?.value(forHTTPHeaderField: "Authorization") == "a-token")
    }

    @Test func perform_okResponseWithData_deliversBoth() async throws {
        let data = Data("any data".utf8)
        let response = anyHTTPURLResponse(statusCode: okStatusCode)
        URLProtocolStub.stub(data: data, response: response, error: nil)
        let sut = makeSUT()

        let (receivedData, receivedResponse) = try await sut.perform(anyRequest())

        #expect(receivedData == data)
        #expect(receivedResponse.statusCode == response.statusCode)
    }

    // MARK: - Helpers

    private let leakTrackers = LockIsolated<[MemoryLeakTracker]>([])

    private func makeSUT(sourceLocation: SourceLocation = #_sourceLocation) -> URLSessionHTTPClient
    {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let sut = URLSessionHTTPClient(session: URLSession(configuration: configuration))
        let tracker = MemoryLeakTracker(instance: sut, sourceLocation: sourceLocation)
        leakTrackers.withValue { $0.append(tracker) }
        return sut
    }

    private func anyRequest() -> URLRequest {
        URLRequest(url: anyURL())
    }
}
