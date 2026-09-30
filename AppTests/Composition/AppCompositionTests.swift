import Auth
import Foundation
import ProductListFeature
import TestSupport
import Testing

@testable import SalesInUSD

@MainActor
struct AppCompositionTests {

    @Test func loginViewModel_isOneInstanceAcrossAccesses() {
        let sut = makeSUT()

        #expect(sut.loginViewModel === sut.loginViewModel)
    }

    @Test func productListViewModel_isOneInstanceAcrossAccesses() {
        let sut = makeSUT()

        #expect(sut.productListViewModel === sut.productListViewModel)
    }

    @Test func detailViewModel_theSameProduct_isOneInstanceAcrossAccesses() {
        let sut = makeSUT()

        #expect(sut.detailViewModel(for: coffee) === sut.detailViewModel(for: coffee))
    }

    @Test func detailViewModel_twoProducts_isADifferentInstanceForEach() {
        let sut = makeSUT()

        #expect(sut.detailViewModel(for: coffee) !== sut.detailViewModel(for: tea))
    }

    // MARK: - Helpers

    private let coffee = ProductListFeature.Product(id: UUID(1), name: "Coffee")
    private let tea = ProductListFeature.Product(id: UUID(2), name: "Tea")

    private func makeSUT() -> AppComposition {
        AppComposition(
            environment: [:],
            tokenStore: InMemoryTokenStore(),
            httpClient: HTTPClientStub.offline
        )
    }
}
