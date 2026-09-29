import Auth
import Testing

@testable import SalesInUSD

@MainActor
struct AppCompositionTests {

    @Test func start_withAStoredToken_opensTheProductList() async throws {
        let signedInStore = InMemoryTokenStore()
        try await signedInStore.store(Token(value: "a-stored-token"))
        let sut = makeSUT(tokenStore: signedInStore)

        await sut.start()

        #expect(sut.router.screen == .productList)
    }

    @Test func start_withNoStoredToken_staysAtLogin() async {
        let sut = makeSUT(tokenStore: InMemoryTokenStore())

        await sut.start()

        #expect(sut.router.screen == .login)
    }

    @Test func start_aStoreThatCannotBeRead_staysAtLogin() async {
        let sut = makeSUT(tokenStore: FailingTokenStore())

        await sut.start()

        #expect(sut.router.screen == .login)
    }

    // MARK: - Helpers

    private func makeSUT(tokenStore: any TokenStore) -> AppComposition {
        AppComposition(
            environment: [:],
            tokenStore: tokenStore,
            httpClient: HTTPClientStub(failure: FailingTokenStore.Failure())
        )
    }
}
