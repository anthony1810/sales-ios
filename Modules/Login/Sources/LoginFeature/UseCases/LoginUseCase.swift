import Auth

public final class LoginUseCase: Sendable {
    public enum Error: Swift.Error, Equatable {
        case invalidCredentials(message: String)
        case failed
    }

    private let api: AuthAPI
    private let tokenStore: TokenStore

    public init(api: AuthAPI, tokenStore: TokenStore) {
        self.api = api
        self.tokenStore = tokenStore
    }

    public func login(_ credentials: Credentials) async throws {
        let token: Token
        do {
            token = try await api.login(credentials)
        } catch let error as Error {
            throw error
        } catch {
            throw Error.failed
        }
        try await tokenStore.store(token)
    }
}
