import ProductListFeature

struct ProductListService {
    private let loadProducts: @Sendable () async throws -> [Product]
    private let loadSales: @Sendable () async throws -> [Sale]

    init(
        loadProducts: @escaping @Sendable () async throws -> [Product],
        loadSales: @escaping @Sendable () async throws -> [Sale]
    ) {
        self.loadProducts = loadProducts
        self.loadSales = loadSales
    }

    func loadSummaries() async throws -> [ProductSummary] {
        async let products = loadProducts()
        async let sales = loadSales()
        return ProductSummaryPolicy.summaries(
            products: try await products,
            sales: try await sales
        )
    }
}
