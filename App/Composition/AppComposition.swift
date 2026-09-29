import Auth
import Foundation
import HTTPClient
import HTTPClientLive
import LoginAPI
import LoginFeature
import LoginPresentation
import ProductDetailAPI
import ProductDetailFeature
import ProductDetailPresentation
import ProductListAPI
import ProductListFeature
import ProductListPresentation
import SharedPresentation

@MainActor
final class AppComposition {
    let router = AppRouter()

    private let backendURL: URL
    private let ratesURL: URL
    private let locale: Locale
    private let timeZone: TimeZone
    private let tokenStore: any TokenStore
    private let httpClient: any HTTPClient
    private var signedInClient: (any HTTPClient)!

    init(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        tokenStore: any TokenStore = KeychainTokenStore(service: "com.anthony.salesinusd"),
        httpClient: any HTTPClient = URLSessionHTTPClient(
            session: URLSession(configuration: .ephemeral)
        ),
        locale: Locale = .current,
        timeZone: TimeZone = .current
    ) {
        self.backendURL = ServiceURLs.backend
        self.ratesURL = ServiceURLs.rates(environment: environment)
        self.tokenStore = tokenStore
        self.httpClient = httpClient
        self.locale = locale
        self.timeZone = timeZone
        self.signedInClient = AuthenticatedHTTPClientDecorator(
            decoratee: httpClient,
            tokenStore: tokenStore,
            onUnauthorized: { [weak self] in
                Task { @MainActor in self?.router.sessionExpired() }
            }
        )
    }

    func makeLoginViewModel() -> LoginViewModel {
        let useCase = LoginUseCase(
            api: RemoteAuthAPI(client: httpClient, baseURL: backendURL),
            tokenStore: tokenStore
        )
        let viewModel = LoginViewModel(login: useCase.login)
        viewModel.onSuccess = { [weak router] in router?.signedIn() }
        return viewModel
    }

    func makeProductListViewModel() -> ProductListViewModel {
        let service = ProductListService(
            loadProducts: loadProducts,
            loadSales: loadListSales
        )
        return ProductListViewModel.productList(loadSummaries: service.loadSummaries)
    }

    func makeProductDetailViewModel(
        for product: ProductListFeature.Product
    ) -> ProductDetailViewModel {
        let service = ProductDetailService(
            loadSales: loadDetailSales,
            loadRates: loadRates
        )
        let detailed = ProductDetailFeature.Product(listed: product)
        return ProductDetailViewModel(
            loadDetail: { try await service.loadDetail(of: detailed) },
            mapper: ProductDetailViewMapper(
                dates: SaleDateFormatter(locale: locale, timeZone: timeZone),
                money: MoneyFormatter(locale: locale)
            )
        )
    }

    // MARK: - Loaders

    private var loadProducts: @Sendable () async throws -> [ProductListFeature.Product] {
        let client = signedInClient!
        let baseURL = backendURL
        return {
            let (data, response) = try await client.perform(
                ProductListEndpoint.products.request(baseURL: baseURL)
            )
            return try ProductsResponseMapper.map(data, from: response)
        }
    }

    private var loadListSales: @Sendable () async throws -> [ProductListFeature.Sale] {
        let client = signedInClient!
        let baseURL = backendURL
        return {
            let (data, response) = try await client.perform(
                ProductListEndpoint.sales.request(baseURL: baseURL)
            )
            return try ProductListAPI.SalesResponseMapper.map(data, from: response)
        }
    }

    private var loadDetailSales: @Sendable () async throws -> [ProductDetailFeature.Sale] {
        let client = signedInClient!
        let baseURL = backendURL
        return {
            let (data, response) = try await client.perform(
                ProductDetailAPI.SalesEndpoint.sales.request(baseURL: baseURL)
            )
            return try ProductDetailAPI.SalesResponseMapper.map(data, from: response)
        }
    }

    private var loadRates: @Sendable () async throws -> RateTable {
        let client = httpClient
        let baseURL = ratesURL
        return {
            let (data, response) = try await client.perform(
                RatesEndpoint.rates.request(baseURL: baseURL)
            )
            return try RatesResponseMapper.map(data, from: response)
        }
    }
}
