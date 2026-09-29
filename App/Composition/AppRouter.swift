import Observation
import ProductListFeature

@Observable
@MainActor
final class AppRouter {
    enum Screen: Equatable {
        case login
        case productList
    }

    enum Route: Hashable {
        case detail(Product)
    }

    private(set) var screen: Screen = .login
    private(set) var sessionDidExpire = false
    var path: [Route] = []

    func showDetail(of product: Product) {
        path.append(.detail(product))
    }

    func signedIn() {
        sessionDidExpire = false
        screen = .productList
    }

    func sessionExpired() {
        path = []
        screen = .login
        sessionDidExpire = true
    }
}
