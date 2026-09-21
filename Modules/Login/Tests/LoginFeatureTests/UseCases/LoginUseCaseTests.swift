import Auth
import LoginFeature
import TestSupport
import Testing

struct LoginUseCaseTests {

    @Test func init_doesNotMessageTheAPIOrTheStore() {
        let (_, api, store) = makeSUT()

        #expect(api.receivedMessages == [])
        #expect(store.receivedMessages == [])
    }

    @Test func login_succeedingAPI_sendsTheCredentialsAndStoresTheToken() async throws {
        let (sut, api, store) = makeSUT()
        let credentials = Credentials(username: "any-username", password: "any-password")
        let token = Token(value: "a-token")
        api.complete(with: .success(token))

        try await sut.login(credentials)

        #expect(api.receivedMessages == [.login(credentials)])
        #expect(store.receivedMessages == [.store(token)])
    }

    @Test func login_invalidCredentialsFailure_rethrowsTheServerMessageAndStoresNothing() async {
        let (sut, api, store) = makeSUT()
        let serverMessage = "Invalid credentials."
        api.complete(with: .failure(LoginUseCase.Error.invalidCredentials(message: serverMessage)))

        await #expect(throws: LoginUseCase.Error.invalidCredentials(message: serverMessage)) {
            try await sut.login(anyCredentials())
        }

        #expect(store.receivedMessages == [])
    }

    @Test func login_anyOtherFailure_throwsAGenericFailureAndStoresNothing() async {
        let (sut, api, store) = makeSUT()
        api.complete(with: .failure(anyNSError()))

        await #expect(throws: LoginUseCase.Error.failed) {
            try await sut.login(anyCredentials())
        }

        #expect(store.receivedMessages == [])
    }

    // MARK: - Helpers

    private func anyCredentials() -> Credentials {
        Credentials(username: "any-username", password: "any-password")
    }

    private func makeSUT() -> (sut: LoginUseCase, api: AuthAPISpy, store: TokenStoreSpy) {
        let api = AuthAPISpy()
        let store = TokenStoreSpy()
        let sut = LoginUseCase(api: api, tokenStore: store)
        return (sut, api, store)
    }
}
