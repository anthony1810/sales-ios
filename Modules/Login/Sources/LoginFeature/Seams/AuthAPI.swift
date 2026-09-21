import Auth

public protocol AuthAPI: Sendable {
    func login(_ credentials: Credentials) async throws -> Token
}
