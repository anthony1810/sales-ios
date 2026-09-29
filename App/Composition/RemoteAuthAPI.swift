import Auth
import Foundation
import HTTPClient
import LoginAPI
import LoginFeature

struct RemoteAuthAPI: AuthAPI {
    private let client: any HTTPClient
    private let baseURL: URL

    init(client: any HTTPClient, baseURL: URL) {
        self.client = client
        self.baseURL = baseURL
    }

    func login(_ credentials: Credentials) async throws -> Token {
        let (data, response) = try await client.perform(
            LoginEndpoint.login(credentials).request(baseURL: baseURL)
        )
        
        return try LoginResponseMapper.map(data, from: response)
    }
}
