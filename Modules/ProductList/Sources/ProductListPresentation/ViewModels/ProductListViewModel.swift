import ProductListFeature
import SharedPresentation

public typealias ProductListViewModel = LoadableViewModel<[ProductSummary], ProductRow>

extension LoadableViewModel where Resource == [ProductSummary], Row == ProductRow {
    public static var screenTitle: String { Localized.string("PRODUCT_LIST_TITLE") }
    public static var emptyMessage: String { Localized.string("PRODUCT_LIST_EMPTY") }
    public static var productListFailureMessage: String {
        Localized.string("PRODUCT_LIST_LOAD_ERROR")
    }

    public static func productList(
        loadSummaries: @escaping @Sendable () async throws -> [ProductSummary]
    ) -> ProductListViewModel {
        ProductListViewModel(
            loader: loadSummaries,
            map: ProductRowMapper.rows(from:),
            failureMessage: productListFailureMessage
        )
    }
}
