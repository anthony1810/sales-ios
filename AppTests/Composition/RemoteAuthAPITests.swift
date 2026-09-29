import Auth
import Foundation
import LoginFeature
import TestSupport
import Testing

@testable import SalesInUSD

struct RemoteAuthAPITests {

    @Test func login_credentials_postsThemToTheLoginEndpoint() async throws {
        let baseURL = anyURL()
        let credentials = Credentials(username: "tester", password: "password")
        let client = HTTPClientStub(data: accessTokenResponse, response: okHTTPURLResponse(for: baseURL))
        let sut = RemoteAuthAPI(client: client, baseURL: baseURL)

        _ = try await sut.login(credentials)

        #expect(client.receivedRequests.map(\.url) == [baseURL.appending(path: "login")])
        #expect(client.receivedRequests.map(\.httpMethod) == ["POST"])
    }

    @Test func login_anAccessTokenResponse_deliversThatToken() async throws {
        let client = HTTPClientStub(
            data: accessTokenResponse, response: okHTTPURLResponse(for: anyURL()))
        let sut = RemoteAuthAPI(client: client, baseURL: anyURL())

        let token = try await sut.login(anyCredentials)

        #expect(token == Token(value: fixtureAccessToken))
    }

    @Test func login_rejectedCredentials_throwsTheServersOwnMessage() async {
        let serverMessage = "Invalid credentials."
        let client = HTTPClientStub(
            data: Data(#"{"message": "\#(serverMessage)"}"#.utf8),
            response: anyHTTPURLResponse(statusCode: unauthorizedStatusCode))
        let sut = RemoteAuthAPI(client: client, baseURL: anyURL())

        await #expect(throws: LoginUseCase.Error.invalidCredentials(message: serverMessage)) {
            try await sut.login(anyCredentials)
        }
    }

    // MARK: - Helpers

    private var fixtureAccessToken: String { "20c3282ce7bbf78edb9bd07574d5a6c7" }
    private var accessTokenResponse: Data {
        Data(#"{"access_token": "\#(fixtureAccessToken)"}"#.utf8)
    }
    private var anyCredentials: Credentials {
        Credentials(username: "any-username", password: "any-password")
    }
}
