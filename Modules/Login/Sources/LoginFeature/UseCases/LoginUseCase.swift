import Auth

public final class LoginUseCase: Sendable {
    private let api: AuthAPI
    private let tokenStore: TokenStore

    public init(api: AuthAPI, tokenStore: TokenStore) {
        self.api = api
        self.tokenStore = tokenStore
    }

    public func login(_ credentials: Credentials) async throws {
        let token = try await api.login(credentials)
        try await tokenStore.store(token)
    }
}
