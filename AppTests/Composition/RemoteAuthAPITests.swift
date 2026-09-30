import Auth
import Foundation
import LoginFeature
import TestSupport
import Testing

@testable import SalesInUSD

struct RemoteAuthAPITests {

    @Test func login_credentials_postsThemToTheLoginEndpoint() async throws {
        let client = HTTPClientStub([loginURL: [.success(accessTokenResponse)]])
        let sut = RemoteAuthAPI(client: client, baseURL: baseURL)

        _ = try await sut.login(anyCredentials)

        #expect(client.receivedRequests.map(\.url) == [loginURL])
        #expect(client.receivedRequests.map(\.httpMethod) == ["POST"])
    }

    @Test func login_anAccessTokenResponse_deliversThatToken() async throws {
        let client = HTTPClientStub([loginURL: [.success(accessTokenResponse)]])
        let sut = RemoteAuthAPI(client: client, baseURL: baseURL)

        let token = try await sut.login(anyCredentials)

        #expect(token == Token(value: fixtureAccessToken))
    }

    @Test func login_rejectedCredentials_throwsTheServersOwnMessage() async {
        let serversMessage = "Invalid credentials."
        let client = HTTPClientStub([loginURL: [.unauthorized(makeServerMessageJSON(serversMessage))]])
        let sut = RemoteAuthAPI(client: client, baseURL: baseURL)

        await #expect(throws: LoginUseCase.Error.invalidCredentials(message: serversMessage)) {
            try await sut.login(anyCredentials)
        }
    }

    // MARK: - Helpers

    private let baseURL = anyURL()
    private var loginURL: URL { baseURL.appending(path: "login") }
    private var fixtureAccessToken: String { "20c3282ce7bbf78edb9bd07574d5a6c7" }
    private var accessTokenResponse: Data { makeAccessTokenJSON(fixtureAccessToken) }
    private var anyCredentials: Credentials {
        Credentials(username: "any-username", password: "any-password")
    }
}
