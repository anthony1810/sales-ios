import Foundation
import HTTPClient

public final class AuthenticatedHTTPClientDecorator: HTTPClient {
    public enum Error: Swift.Error {
        case notAuthenticated
    }

    private let decoratee: any HTTPClient
    private let tokenStore: any TokenStore

    public init(decoratee: any HTTPClient, tokenStore: any TokenStore) {
        self.decoratee = decoratee
        self.tokenStore = tokenStore
    }

    public func perform(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        guard let token = try await tokenStore.load() else {
            throw Error.notAuthenticated
        }
        var signed = request
        signed.setValue(token.value, forHTTPHeaderField: "Authorization")
        return try await decoratee.perform(signed)
    }
}
