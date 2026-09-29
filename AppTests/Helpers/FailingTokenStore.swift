import Auth
import Foundation

struct FailingTokenStore: TokenStore {
    struct Failure: Error {}

    func load() async throws -> Token? {
        throw Failure()
    }

    func store(_ token: Token) async throws {
        throw Failure()
    }

    func clear() async throws {
        throw Failure()
    }
}
