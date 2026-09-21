import Foundation
import ProductListFeature
import ProductListTestSupport
import TestSupport
import Testing

struct ProductSummaryPolicyTests {

    @Test func summaries_severalSalesPerProduct_countsThemPerProduct() {
        let firstProduct = makeProduct(id: UUID(1), name: "Apple TV")
        let secondProduct = makeProduct(id: UUID(2), name: "Mac mini")
        let sales = [
            makeSale(productID: firstProduct.id),
            makeSale(productID: secondProduct.id),
            makeSale(productID: firstProduct.id),
        ]

        let summaries = ProductSummaryPolicy.summaries(
            products: [firstProduct, secondProduct],
            sales: sales
        )

        #expect(
            summaries == [
                makeSummary(of: firstProduct, salesCount: 2),
                makeSummary(of: secondProduct, salesCount: 1),
            ]
        )
    }

    @Test func summaries_productWithoutSales_countsZero() {
        let soldProduct = makeProduct(id: UUID(1), name: "Apple TV")
        let unsoldProduct = makeProduct(id: UUID(2), name: "Mac mini")

        let summaries = ProductSummaryPolicy.summaries(
            products: [soldProduct, unsoldProduct],
            sales: [makeSale(productID: soldProduct.id)]
        )

        #expect(
            summaries == [
                makeSummary(of: soldProduct, salesCount: 1),
                makeSummary(of: unsoldProduct, salesCount: 0),
            ]
        )
    }

    @Test func summaries_saleForAnUnknownProduct_isIgnored() {
        let knownProduct = makeProduct(id: UUID(1), name: "Apple TV")
        let unknownProductID = UUID(99)

        let summaries = ProductSummaryPolicy.summaries(
            products: [knownProduct],
            sales: [makeSale(productID: unknownProductID), makeSale(productID: knownProduct.id)]
        )

        #expect(summaries == [makeSummary(of: knownProduct, salesCount: 1)])
    }

    @Test func summaries_namesOutOfOrder_sortsThemAlphabetically() {
        let lastByName = makeProduct(id: UUID(1), name: "Studio Display")
        let firstByName = makeProduct(id: UUID(2), name: "Apple TV")

        let summaries = ProductSummaryPolicy.summaries(
            products: [lastByName, firstByName],
            sales: []
        )

        #expect(summaries.map(\.name) == [firstByName.name, lastByName.name])
    }

    @Test func summaries_namesInMixedCase_sortsIgnoringCase() throws {
        let lowercaseName = makeProduct(id: UUID(1), name: "iPhone")
        let uppercaseName = makeProduct(id: UUID(2), name: "Mac mini")
        try #require((lowercaseName.name < uppercaseName.name) == false)

        let summaries = ProductSummaryPolicy.summaries(
            products: [uppercaseName, lowercaseName],
            sales: []
        )

        #expect(summaries.map(\.name) == [lowercaseName.name, uppercaseName.name])
    }
}
