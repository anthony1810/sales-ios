import Observation
import ProductDetailFeature

@Observable
@MainActor
public final class ProductDetailViewModel {
    public private(set) var isLoading = false
    public private(set) var errorMessage: String?
    public private(set) var viewData: ProductDetailViewData?

    public static var loadErrorMessage: String { Localized.string("PRODUCT_DETAIL_LOAD_ERROR") }
    public static var emptyMessage: String { Localized.string("PRODUCT_DETAIL_EMPTY") }

    private let loadDetail: @Sendable () async throws -> ProductDetail
    private let mapper: ProductDetailViewMapper

    public init(
        loadDetail: @escaping @Sendable () async throws -> ProductDetail,
        mapper: ProductDetailViewMapper
    ) {
        self.loadDetail = loadDetail
        self.mapper = mapper
    }

    public func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            viewData = mapper.viewData(for: try await loadDetail())
        } catch {
            errorMessage = Self.loadErrorMessage
        }
        isLoading = false
    }
}
