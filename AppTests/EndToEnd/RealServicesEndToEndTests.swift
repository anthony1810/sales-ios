import Auth
import Foundation
import HTTPClient
import HTTPClientLive
import LoginFeature
import ProductDetailAPI
import ProductDetailFeature
import ProductListAPI
import ProductListFeature
import TestSupport
import Testing

@testable import SalesInUSD

struct RealServicesEndToEndTests {

    @Test(.enabled(if: endToEndIsEnabled))
    func login_theTesterAccount_deliversAToken() async throws {
        let token = try await signIn()

        #expect(token.value.isEmpty == false)
    }

    @Test(.enabled(if: endToEndIsEnabled))
    func products_withAValidToken_deliverNamedProducts() async throws {
        let (data, response) = try await signedInResponse(
            for: ProductListEndpoint.products.request(baseURL: ServiceURLs.backend)
        )
        let products = try ProductsResponseMapper.map(data, from: response)

        #expect(products.isEmpty == false)
        #expect(products.allSatisfy { $0.name.isEmpty == false })
    }

    @Test(.enabled(if: endToEndIsEnabled))
    func sales_withAValidToken_deliverAmountsInKnownCurrencies() async throws {
        let (data, response) = try await signedInResponse(
            for: ProductDetailAPI.SalesEndpoint.sales.request(baseURL: ServiceURLs.backend)
        )
        let sales = try ProductDetailAPI.SalesResponseMapper.map(data, from: response)

        #expect(sales.isEmpty == false)
        #expect(sales.allSatisfy { $0.amount.currencyCode.count == 3 })
    }

    @Test(.enabled(if: middlewareIsRunning))
    func rates_theLocalMiddleware_quotesUSDAgainstItself() async throws {
        let (data, response) = try await client.perform(
            RatesEndpoint.rates.request(baseURL: ratesURL)
        )
        let table = try RatesResponseMapper.map(data, from: response)

        #expect(table.rateToUSD(for: "USD") == 1)
    }

    // MARK: - Helpers

    private var client: any HTTPClient {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }

    private var ratesURL: URL {
        ServiceURLs.rates(environment: ProcessInfo.processInfo.environment)
    }

    private func signIn() async throws -> Token {
        let api = RemoteAuthAPI(client: client, baseURL: ServiceURLs.backend)
        return try await api.login(Credentials(username: "tester", password: "password"))
    }

    private func signedInResponse(
        for request: URLRequest
    ) async throws -> (Data, HTTPURLResponse) {
        let store = InMemoryTokenStore()
        try await store.store(try await signIn())
        let signedIn = AuthenticatedHTTPClientDecorator(
            decoratee: client,
            tokenStore: store,
            onUnauthorized: {}
        )
        return try await signedIn.perform(request)
    }
}

private let endToEndIsEnabled = ProcessInfo.processInfo.environment["END_TO_END"] == "1"

private let middlewareIsRunning =
    ProcessInfo.processInfo.environment["END_TO_END"] == "1"
    && ProcessInfo.processInfo.environment["RATES_BASE_URL"] != nil
