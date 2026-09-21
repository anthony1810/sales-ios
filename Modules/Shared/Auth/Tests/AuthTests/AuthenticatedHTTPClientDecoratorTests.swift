import Foundation
import HTTPClient
import TestSupport
import Testing

@testable import Auth

struct AuthenticatedHTTPClientDecoratorTests {

    @Test func perform_withAStoredToken_signsTheRequest() async throws {
        let (sut, client, tokenStore) = makeSUT()
        let storedToken = Token(value: "a-token")
        try await tokenStore.store(storedToken)
        await client.stub(data: Data("any data".utf8), response: okHTTPURLResponse(for: anyURL()))
        var request = URLRequest(url: anyURL())
        request.httpMethod = "GET"

        let (data, response) = try await sut.perform(request)

        let received = await client.receivedRequests
        #expect(received.count == 1)
        #expect(received.first?.url == request.url)
        #expect(received.first?.value(forHTTPHeaderField: "Authorization") == storedToken.value)
        #expect(data == Data("any data".utf8))
        #expect(response.statusCode == okStatusCode)
    }

    @Test func perform_withNoStoredToken_throwsAndNeverCallsTheClient() async throws {
        let (sut, client, _) = makeSUT()

        await #expect(throws: AuthenticatedHTTPClientDecorator.Error.notAuthenticated) {
            try await sut.perform(URLRequest(url: anyURL()))
        }
        #expect(await client.receivedRequests.isEmpty)
    }

    // MARK: - Helpers

    private func makeSUT() -> (
        sut: AuthenticatedHTTPClientDecorator,
        client: HTTPClientSpy,
        tokenStore: InMemoryTokenStore
    ) {
        let client = HTTPClientSpy()
        let tokenStore = InMemoryTokenStore()
        let sut = AuthenticatedHTTPClientDecorator(decoratee: client, tokenStore: tokenStore)
        return (sut, client, tokenStore)
    }
}
