import Auth
import Foundation
import LoginFeature
import LoginPresentation
import ProductListPresentation
import TestSupport
import Testing

@testable import SalesInUSD

@MainActor
struct SignInAcceptanceTests {

    // MARK: - Narrative 1, signing in

    @Test func customerSignsIn_reachesTheProductList() async {
        let app = AcceptanceApp(client: backendIssuingAToken)

        await app.signIn(as: theTesterAccount)

        #expect(app.router.screen == .productList)
        #expect(app.login.errorMessage == nil)
    }

    @Test func customerSignsIn_keepsTheTokenForTheNextLaunch() async {
        let app = AcceptanceApp(client: backendIssuingAToken)

        await app.signIn(as: theTesterAccount)

        let keptToken = await app.storedToken
        #expect(keptToken == Token(value: issuedToken))
    }

    @Test func customerSignsInWithRejectedCredentials_staysAtLoginWithTheServersMessage() async {
        let serversMessage = "Invalid credentials."
        let app = AcceptanceApp(client: backendRejecting(with: serversMessage))

        await app.signIn(as: theTesterAccount)

        #expect(app.router.screen == .login)
        #expect(app.login.errorMessage == serversMessage)
    }

    @Test func customerSignsInWhileOffline_staysAtLoginWithTheGenericError() async {
        let app = AcceptanceApp(client: .offline)

        await app.signIn(as: theTesterAccount)

        #expect(app.router.screen == .login)
        #expect(app.login.errorMessage == LoginViewModel.genericErrorMessage)
    }

    // MARK: - Narrative 2, returning to the app

    @Test func customerReturnsAfterSigningInEarlier_reachesTheProductListWithoutSigningIn() async {
        let app = await AcceptanceApp.signedIn(client: .offline)

        #expect(app.router.screen == .productList)
    }

    @Test func customerReturnsWithNoStoredSession_staysAtLogin() async {
        let emptyStore = InMemoryTokenStore()
        let app = AcceptanceApp(client: .offline, tokenStore: emptyStore)

        await app.composition.start()

        #expect(app.router.screen == .login)
    }

    @Test func customerReturnsWithAnUnreadableStore_staysAtLogin() async {
        let unreadableStore = FailingTokenStore()
        let app = AcceptanceApp(client: .offline, tokenStore: unreadableStore)

        await app.composition.start()

        #expect(app.router.screen == .login)
    }

    // MARK: - Narrative 3, the session expiring

    @Test func signedInCustomerIsRejected_returnsToLoginWithTheExpiryNotice() async {
        await withMainSerialExecutor {
            let app = await AcceptanceApp.signedIn(client: backendRejectingTheSession)

            await app.products.load()
            await Task.megaYield()

            #expect(app.router.screen == .login)
            #expect(app.router.sessionDidExpire == true)
            #expect(app.login.showsSessionExpired == true)
        }
    }

    @Test func signedInCustomerIsRejected_clearsTheStoredToken() async {
        await withMainSerialExecutor {
            let app = await AcceptanceApp.signedIn(client: backendRejectingTheSession)

            await app.products.load()
            await Task.megaYield()

            let remainingToken = await app.storedToken
            #expect(remainingToken == nil)
        }
    }

    // MARK: - Helpers

    private let theTesterAccount = Credentials(username: "tester", password: "password")
    private let issuedToken = "an-issued-token"

    private var backendIssuingAToken: HTTPClientStub {
        HTTPClientStub([AcceptanceApp.loginURL: [.success(makeAccessTokenJSON(issuedToken))]])
    }

    private func backendRejecting(with message: String) -> HTTPClientStub {
        HTTPClientStub([AcceptanceApp.loginURL: [.unauthorized(makeServerMessageJSON(message))]])
    }

    private var backendRejectingTheSession: HTTPClientStub {
        HTTPClientStub([
            AcceptanceApp.productsURL: [.unauthorized(Data())],
            AcceptanceApp.salesURL: [.unauthorized(Data())],
        ])
    }
}
