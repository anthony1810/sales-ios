import Foundation
import ProductDetailFeature
import ProductDetailPresentation
import ProductDetailTestSupport
import SharedPresentation
import TestSupport
import Testing

struct ProductDetailViewMapperTests {

    @Test func viewData_aProductWithConvertibleSales_readsLikeTheBriefsHeader() {
        let briefSummaryShape = "($107,587 from 271 sales)"
        let product = makeProduct(id: UUID(1), name: "Mac mini")
        let detail = ProductDetail(
            product: product,
            sales: manyConvertedSales(count: 271),
            total: makeMoney(dec("107587"), currencyCode: usd)
        )

        let viewData = makeSUT().viewData(for: detail)

        #expect(viewData.title == product.name)
        #expect(viewData.summaryText == briefSummaryShape)
    }

    @Test func viewData_aSingleSale_readsAsOneSale() {
        let product = makeProduct(id: UUID(1), name: "Mac mini")
        let detail = ProductDetail(
            product: product,
            sales: manyConvertedSales(count: 1),
            total: makeMoney(dec("407"), currencyCode: usd)
        )

        let viewData = makeSUT().viewData(for: detail)

        #expect(viewData.summaryText == "($407 from 1 sale)")
    }

    @Test func viewData_aSaleInItsOwnCurrency_showsTheAmountDateAndConversion() {
        let detail = ProductDetail(
            product: makeProduct(id: UUID(1), name: "Mac mini"),
            sales: [
                DetailedSale(
                    amount: makeMoney(dec("2299"), currencyCode: "BRL"),
                    date: Date.fixture("2030-01-02T11:00:00.000Z"),
                    convertedToUSD: makeMoney(dec("436.81"), currencyCode: usd)
                )
            ],
            total: makeMoney(dec("436.81"), currencyCode: usd)
        )

        let viewData = makeSUT().viewData(for: detail)

        #expect(viewData.rows.map(\.amountText) == ["R$2,299"])
        #expect(viewData.rows.map(\.dateText) == ["Jan 2, 2030 at 11 am"])
        #expect(viewData.rows.map(\.convertedText) == ["US$437"])
    }

    @Test func viewData_withoutATotal_saysUSDIsUnavailableInTheHeaderAndTheRow() {
        let detail = ProductDetail(
            product: makeProduct(id: UUID(1), name: "Mac mini"),
            sales: [
                DetailedSale(
                    amount: makeMoney(dec("2299"), currencyCode: "BRL"),
                    date: Date.fixture("2030-01-02T11:00:00.000Z"),
                    convertedToUSD: nil
                )
            ],
            total: nil
        )

        let viewData = makeSUT().viewData(for: detail)

        #expect(viewData.summaryText == "(USD unavailable from 1 sale)")
        #expect(viewData.rows.map(\.convertedText) == ["USD unavailable"])
    }

    // MARK: - Helpers

    private var usd: String { ProductDetailPolicy.usdCurrencyCode }

    private func manyConvertedSales(count: Int) -> [DetailedSale] {
        (0..<count).map { index in
            DetailedSale(
                amount: makeMoney(dec("1"), currencyCode: "BRL"),
                date: Date.fixture("2030-01-02T11:00:00.000Z").addingTimeInterval(
                    TimeInterval(-index)),
                convertedToUSD: makeMoney(dec("1"), currencyCode: usd)
            )
        }
    }

    private func makeSUT() -> ProductDetailViewMapper {
        ProductDetailViewMapper(
            dates: SaleDateFormatter(
                locale: Locale(identifier: "en_US"), timeZone: TimeZone(identifier: "UTC")!),
            money: MoneyFormatter(locale: Locale(identifier: "en_US"))
        )
    }
}
