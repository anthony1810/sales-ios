import Auth
import TestSupport

final class TokenStoreSpy: TokenStore, Sendable {
    enum Message: Equatable {
        case load
        case store(Token)
        case clear
    }

    private let _receivedMessages = LockIsolated<[Message]>([])

    var receivedMessages: [Message] { _receivedMessages.value }

    func load() async throws -> Token? {
        _receivedMessages.withValue { $0.append(.load) }
        return nil
    }

    func store(_ token: Token) async throws {
        _receivedMessages.withValue { $0.append(.store(token)) }
    }

    func clear() async throws {
        _receivedMessages.withValue { $0.append(.clear) }
    }
}
