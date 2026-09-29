import Auth
import Foundation
import TestSupport
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

    // MARK: - Relock

    @Test func aRejectedRequest_clearsTheTokenAndReturnsToLoginWithANotice() async {
        await withMainSerialExecutor {
            let store = InMemoryTokenStore()
            try? await store.store(Token(value: "an-expired-token"))
            let sut = AppComposition(
                environment: [:],
                tokenStore: store,
                httpClient: HTTPClientStub(
                    data: Data(),
                    response: anyHTTPURLResponse(statusCode: unauthorizedStatusCode)
                )
            )
            sut.router.signedIn()

            await sut.productListViewModel.load()
            await Task.megaYield()

            let remainingToken = try? await store.load()
            #expect(sut.router.screen == .login)
            #expect(sut.router.sessionDidExpire == true)
            #expect(remainingToken == nil)
            #expect(sut.loginViewModel.showsSessionExpired == true)
        }
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
