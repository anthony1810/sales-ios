import LoginUI
import ProductDetailUI
import ProductListFeature
import ProductListPresentation
import ProductListUI
import SwiftUI

struct RootView: View {
    private let composition: AppComposition
    @Bindable private var router: AppRouter

    init(composition: AppComposition) {
        self.composition = composition
        _router = Bindable(composition.router)
    }

    var body: some View {
        Group {
            switch router.screen {
            case .login:
                LoginSUView(viewModel: composition.loginViewModel)
            case .productList:
                NavigationStack(path: $router.path) {
                    ProductListSUView(
                        viewModel: composition.productListViewModel,
                        onSelect: { row in
                            router.showDetail(
                                of: ProductListFeature.Product(id: row.id, name: row.name)
                            )
                        }
                    )
                    .navigationDestination(for: AppRouter.Route.self) { route in
                        switch route {
                        case let .detail(product):
                            ProductDetailSUView(
                                viewModel: composition.detailViewModel(for: product)
                            )
                        }
                    }
                }
            }
        }
        .task { await composition.start() }
    }
}
