public actor InMemoryTokenStore: TokenStore {
    private var token: Token?

    public init() {}

    public func load() async throws -> Token? {
        token
    }

    public func store(_ token: Token) async throws {
        self.token = token
    }

    public func clear() async throws {
        token = nil
    }
}
