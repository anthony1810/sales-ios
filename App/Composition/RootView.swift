import LoginUI
import ProductDetailUI
import ProductListFeature
import ProductListPresentation
import ProductListUI
import SwiftUI

struct RootView: View {
    @State private var composition = AppComposition()

    var body: some View {
        @Bindable var router = composition.router

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
