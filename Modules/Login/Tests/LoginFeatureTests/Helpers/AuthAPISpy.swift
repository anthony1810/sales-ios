import Auth
import LoginFeature
import TestSupport

final class AuthAPISpy: AuthAPI, Sendable {
    enum Message: Equatable {
        case login(Credentials)
    }

    private let _receivedMessages = LockIsolated<[Message]>([])
    private let _result = LockIsolated<Result<Token, Error>?>(nil)

    var receivedMessages: [Message] { _receivedMessages.value }

    func complete(with result: Result<Token, Error>) {
        _result.setValue(result)
    }

    func login(_ credentials: Credentials) async throws -> Token {
        _receivedMessages.withValue { $0.append(.login(credentials)) }
        return try _result.value.evaluate()
    }
}
