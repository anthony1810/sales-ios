import Foundation
import ProductListFeature
import ProductListPresentation
import TestSupport
import Testing

@testable import SalesInUSD

@MainActor
struct ProductListAcceptanceTests {

    // MARK: - Narrative 4, browsing the products

    @Test func customerOpensTheProductList_seesEveryProductWithItsSalesCount() async {
        let app = await AcceptanceApp.signedIn(client: backendWith(coffeeSoldTwiceAndTeaNeverSold))

        await app.products.load()

        #expect(app.products.rows == expectedRows(coffeeSalesCount: 2, teaSalesCount: 0))
        #expect(app.products.errorMessage == nil)
    }

    @Test func customerOpensTheProductList_seesProductsInHumanNameOrder() async {
        let app = await AcceptanceApp.signedIn(client: backendWith(itemsNumberedOutOfOrder))

        await app.products.load()

        #expect(app.productNames == [itemNine.name, itemTen.name])
    }

    @Test func customerOpensTheProductList_seesNothingForASaleWithNoMatchingProduct() async {
        let app = await AcceptanceApp.signedIn(client: backendWith(oneSaleForAnUnknownProduct))

        await app.products.load()

        #expect(app.productNames == [coffee.name])
        #expect(app.products.rows == expectedRows(coffeeSalesCount: 0, teaSalesCount: nil))
    }

    @Test func customerOpensTheProductListOffline_seesTheLoadError() async {
        let app = await AcceptanceApp.signedIn(client: .offline)

        await app.products.load()

        #expect(app.products.rows == [])
        #expect(app.products.errorMessage == ProductListViewModel.productListFailureMessage)
    }

    @Test func customerRetriesAfterAFailure_seesTheProducts() async {
        let app = await AcceptanceApp.signedIn(client: backendFailingThenSucceeding)
        await app.products.load()

        await app.products.load()

        #expect(app.productNames == [coffee.name, tea.name])
        #expect(app.products.errorMessage == nil)
    }

    // MARK: - Helpers

    private let coffee = RemoteProduct(id: UUID(1), name: "Coffee")
    private let tea = RemoteProduct(id: UUID(2), name: "Tea")
    private let itemNine = RemoteProduct(id: UUID(3), name: "Item 9")
    private let itemTen = RemoteProduct(id: UUID(4), name: "Item 10")

    private func expectedRows(coffeeSalesCount: Int, teaSalesCount: Int?) -> [ProductRow] {
        var summaries = [
            ProductSummary(id: coffee.id, name: coffee.name, salesCount: coffeeSalesCount)
        ]
        if let teaSalesCount {
            summaries.append(
                ProductSummary(id: tea.id, name: tea.name, salesCount: teaSalesCount)
            )
        }
        return ProductRowMapper.rows(from: summaries)
    }

    private var coffeeSoldTwiceAndTeaNeverSold: (products: Data, sales: Data) {
        (
            makeProductsJSON([coffee, tea]),
            makeSalesJSON([saleOf(coffee), saleOf(coffee)])
        )
    }

    private var itemsNumberedOutOfOrder: (products: Data, sales: Data) {
        (makeProductsJSON([itemTen, itemNine]), makeSalesJSON([]))
    }

    private var oneSaleForAnUnknownProduct: (products: Data, sales: Data) {
        (
            makeProductsJSON([coffee]),
            makeSalesJSON([RemoteSale(productID: UUID(9), amount: "1", currencyCode: "AUD", date: now)])
        )
    }

    private var backendFailingThenSucceeding: HTTPClientStub {
        HTTPClientStub([
            AcceptanceApp.productsURL: [.failure, .success(makeProductsJSON([coffee, tea]))],
            AcceptanceApp.salesURL: [.failure, .success(makeSalesJSON([]))],
        ])
    }

    private func backendWith(_ responses: (products: Data, sales: Data)) -> HTTPClientStub {
        HTTPClientStub([
            AcceptanceApp.productsURL: [.success(responses.products)],
            AcceptanceApp.salesURL: [.success(responses.sales)],
        ])
    }

    private func saleOf(_ product: RemoteProduct) -> RemoteSale {
        RemoteSale(productID: product.id, amount: "1", currencyCode: "AUD", date: now)
    }

    private let now = Date()
}
