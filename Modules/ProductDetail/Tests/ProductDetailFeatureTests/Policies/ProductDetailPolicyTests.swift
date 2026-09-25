import Foundation
import ProductDetailFeature
import ProductDetailTestSupport
import TestSupport
import Testing

struct ProductDetailPolicyTests {

    @Test func detail_salesOfSeveralProducts_keepsOnlyTheRequestedProducts() {
        let requestedProduct = makeProduct(id: UUID(1), name: "Mac mini")
        let otherProduct = makeProduct(id: UUID(2), name: "Apple TV")
        let requestedSale = makeSale(productID: requestedProduct.id, amount: makeMoney(10))
        let otherSale = makeSale(productID: otherProduct.id, amount: makeMoney(20))

        let detail = ProductDetailPolicy.detail(
            of: requestedProduct,
            sales: [otherSale, requestedSale],
            rates: nil
        )

        #expect(detail.product == requestedProduct)
        #expect(detail.sales.map(\.amount) == [requestedSale.amount])
    }

    @Test func detail_salesOutOfOrder_sortsThemNewestFirst() {
        let product = makeProduct(id: UUID(1))
        let newest = Date()
        let middle = newest.addingTimeInterval(-3600)
        let oldest = newest.addingTimeInterval(-7200)
        let sales = [
            makeSale(productID: product.id, date: middle),
            makeSale(productID: product.id, date: oldest),
            makeSale(productID: product.id, date: newest),
        ]

        let detail = ProductDetailPolicy.detail(of: product, sales: sales, rates: nil)

        #expect(detail.sales.map(\.date) == [newest, middle, oldest])
    }
}
