import Foundation
import HTTPClient

public final class AuthenticatedHTTPClientDecorator: HTTPClient {
    public enum Error: Swift.Error {
        case notAuthenticated
        case unauthorized
    }

    private let decoratee: any HTTPClient
    private let tokenStore: any TokenStore
    private let onUnauthorized: @Sendable () -> Void

    public init(
        decoratee: any HTTPClient,
        tokenStore: any TokenStore,
        onUnauthorized: @escaping @Sendable () -> Void
    ) {
        self.decoratee = decoratee
        self.tokenStore = tokenStore
        self.onUnauthorized = onUnauthorized
    }

    public func perform(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        guard let token = try await tokenStore.load() else {
            throw Error.notAuthenticated
        }
        var signed = request
        signed.setValue(token.value, forHTTPHeaderField: "Authorization")
        let (data, response) = try await decoratee.perform(signed)
        guard response.statusCode != unauthorizedStatusCode else {
            onUnauthorized()
            throw Error.unauthorized
        }
        return (data, response)
    }

    private let unauthorizedStatusCode = 401
}
