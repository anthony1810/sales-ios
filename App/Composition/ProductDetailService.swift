import ProductDetailFeature

struct ProductDetailService {
    private let loadSales: @Sendable () async throws -> [Sale]
    private let loadRates: @Sendable () async throws -> RateTable

    init(
        loadSales: @escaping @Sendable () async throws -> [Sale],
        loadRates: @escaping @Sendable () async throws -> RateTable
    ) {
        self.loadSales = loadSales
        self.loadRates = loadRates
    }

    func loadDetail(of product: Product) async throws -> ProductDetail {
        async let sales = loadSales()
        async let rates = try? await loadRates()
        return ProductDetailPolicy.detail(
            of: product,
            sales: try await sales,
            rates: await rates
        )
    }
}
