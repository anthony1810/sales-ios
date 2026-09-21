import Foundation
import LoginAPI
import LoginFeature
import TestSupport
import Testing

struct LoginEndpointTests {

    @Test func request_login_postsTheCredentialsAsJSONToTheLoginPath() throws {
        let baseURL = anyURL()
        let credentials = Credentials(username: "any-username", password: "any-password")

        let request = LoginEndpoint.login(credentials).request(baseURL: baseURL)

        #expect(request.url == baseURL.appending(path: "login"))
        #expect(request.httpMethod == "POST")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        let bodyData = try #require(request.httpBody)
        let body = try JSONDecoder().decode([String: String].self, from: bodyData)
        #expect(body == ["username": "any-username", "password": "any-password"])
    }
}
