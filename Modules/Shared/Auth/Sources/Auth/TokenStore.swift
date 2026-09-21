public protocol TokenStore: Sendable {
    func load() async throws -> Token?
    func store(_ token: Token) async throws
    func clear() async throws
}
