import Auth
import Foundation
import LoginAPI
import LoginFeature
import LoginPresentation
import ProductDetailAPI
import ProductDetailPresentation
import ProductListAPI
import ProductListFeature
import ProductListPresentation
import TestSupport

@testable import SalesInUSD

@MainActor
struct AcceptanceApp {
    let composition: AppComposition
    let tokenStore: any TokenStore

    init(
        client: HTTPClientStub,
        tokenStore: any TokenStore = InMemoryTokenStore(),
        locale: Locale = AcceptanceApp.englishLocale
    ) {
        self.tokenStore = tokenStore
        composition = AppComposition(
            environment: [:],
            tokenStore: tokenStore,
            httpClient: client,
            locale: locale,
            timeZone: AcceptanceApp.utc
        )
    }

    static func signedIn(
        client: HTTPClientStub,
        locale: Locale = AcceptanceApp.englishLocale
    ) async -> AcceptanceApp {
        let store = InMemoryTokenStore()
        try? await store.store(Token(value: "a-stored-token"))
        let app = AcceptanceApp(client: client, tokenStore: store, locale: locale)
        await app.composition.start()
        return app
    }

    var router: AppRouter { composition.router }
    var login: LoginViewModel { composition.loginViewModel }
    var products: ProductListViewModel { composition.productListViewModel }

    var productNames: [String] { products.rows.map(\.name) }
    var salesCounts: [String] { products.rows.map(\.salesCountText) }
    var storedToken: Token? { get async { try? await tokenStore.load() } }

    func signIn(as credentials: Credentials) async {
        login.username = credentials.username
        login.password = credentials.password
        await login.submit()
    }

    func detail(of row: ProductRow) -> ProductDetailViewModel {
        composition.detailViewModel(
            for: ProductListFeature.Product(id: row.id, name: row.name)
        )
    }

    // MARK: - Fixed environment

    static let englishLocale = Locale(identifier: "en_US")
    static let utc = TimeZone(secondsFromGMT: 0) ?? .gmt

    static let loginURL = url(of: LoginEndpoint.login(anyCredentials).request(baseURL: backend))
    static let productsURL = url(of: ProductListEndpoint.products.request(baseURL: backend))
    static let salesURL = url(of: ProductListEndpoint.sales.request(baseURL: backend))
    static let ratesURL = url(of: RatesEndpoint.rates.request(baseURL: ServiceURLs.defaultRates))

    private static let backend = ServiceURLs.backend
    private static let anyCredentials = Credentials(username: "any", password: "any")

    private static func url(of request: URLRequest) -> URL {
        guard let url = request.url else { preconditionFailure("an endpoint produced no URL") }
        return url
    }
}
