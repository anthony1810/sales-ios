import Observation
import ProductListFeature

@Observable
@MainActor
final class AppRouter {
    enum Route: Hashable {
        case detail(Product)
    }

    var path: [Route] = []

    func showDetail(of product: Product) {
        path.append(.detail(product))
    }
}
