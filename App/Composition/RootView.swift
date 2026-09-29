import LoginUI
import ProductListFeature
import ProductListPresentation
import ProductDetailUI
import ProductListUI
import SwiftUI

struct RootView: View {
    @State private var composition = AppComposition()

    var body: some View {
        @Bindable var router = composition.router

        content(for: router)
            .task { await composition.start() }
    }

    @ViewBuilder private func content(for router: AppRouter) -> some View {
        @Bindable var router = router

        switch router.screen {
        case .login:
            LoginSUView(viewModel: composition.loginViewModel)
        case .productList:
            NavigationStack(path: $router.path) {
                ProductListSUView(
                    viewModel: composition.productListViewModel,
                    onSelect: { row in
                        composition.router.showDetail(
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
}
