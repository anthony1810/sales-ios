import Foundation
import ProductDetailFeature
import ProductDetailPresentation
import ProductListPresentation
import SharedPresentation
import TestSupport
import Testing

@testable import SalesInUSD

@MainActor
struct ProductDetailAcceptanceTests {

    // MARK: - Narrative 5, one product's sales in US dollars

    @Test func customerOpensAProduct_seesOnlyThatProductsSalesNewestFirst() async throws {
        let app = await AcceptanceApp.signedIn(client: backendWithRates(audOnly))
        let detail = try await openCoffee(in: app)

        let rows = try #require(detail.viewData?.rows)

        #expect(rows.map(\.amountText) == [aud(newerAmount), aud(olderAmount)])
    }

    @Test func customerOpensAProduct_seesEverySaleConvertedToUSD() async throws {
        let rate = try #require(Decimal(string: audRateToUSD))
        let app = await AcceptanceApp.signedIn(client: backendWithRates(audOnly))
        let detail = try await openCoffee(in: app)

        let rows = try #require(detail.viewData?.rows)

        #expect(
            rows.map(\.convertedText) == [usdInARow(newerAmount * rate), usdInARow(olderAmount * rate)]
        )
    }

    @Test func customerOpensAProduct_seesTheTotalOfEveryConvertedSale() async throws {
        let rate = try #require(Decimal(string: audRateToUSD))
        let app = await AcceptanceApp.signedIn(client: backendWithRates(audOnly))
        let detail = try await openCoffee(in: app)

        let summary = try #require(detail.viewData?.summaryText)

        #expect(summary.contains(usdInTheSummary((newerAmount + olderAmount) * rate)))
    }

    // MARK: - Narrative 6, the middleware is not running

    @Test func customerOpensAProductWithNoRatesService_seesTheSalesWithoutAnyConversion() async throws {
        let app = await AcceptanceApp.signedIn(client: backendWithoutRates)
        let detail = try await openCoffee(in: app)

        let rows = try #require(detail.viewData?.rows)

        #expect(rows.map(\.amountText) == [aud(newerAmount), aud(olderAmount)])
        #expect(rows.map(\.convertedText) == [usdUnavailable, usdUnavailable])
    }

    @Test func customerOpensAProductWithNoRatesService_seesNoTotal() async throws {
        let app = await AcceptanceApp.signedIn(client: backendWithoutRates)
        let detail = try await openCoffee(in: app)

        let summary = try #require(detail.viewData?.summaryText)

        #expect(summary.contains(usdUnavailable))
    }

    @Test func customerOpensAProductPricedInAnUnquotedCurrency_seesNoTotal() async throws {
        let app = await AcceptanceApp.signedIn(client: backendWithRates(usdOnly))
        let detail = try await openCoffee(in: app)

        let summary = try #require(detail.viewData?.summaryText)

        #expect(summary.contains(usdUnavailable))
    }

    @Test func customerOpensAProductAndTheSalesFail_seesTheLoadError() async throws {
        let app = await AcceptanceApp.signedIn(client: backendWithoutSales)
        let detail = try await openCoffee(in: app)

        #expect(detail.viewData == nil)
        #expect(detail.errorMessage == ProductDetailViewModel.loadErrorMessage)
    }

    // MARK: - Helpers

    private let coffee = RemoteProduct(id: UUID(1), name: "Coffee")
    private let audCurrencyCode = "AUD"
    private let audRateToUSD = "0.65"
    private let newerAmount = Decimal(10)
    private let olderAmount = Decimal(5)
    private let now = Date()

    private func openCoffee(in app: AcceptanceApp) async throws -> ProductDetailViewModel {
        await app.products.load()
        let coffeeRow = try #require(app.products.rows.first)
        let detail = app.detail(of: coffeeRow)
        await detail.load()
        return detail
    }

    private var coffeeSalesJSON: Data {
        makeSalesJSON([
            RemoteSale(
                productID: coffee.id,
                amount: "\(olderAmount)",
                currencyCode: audCurrencyCode,
                date: now.addingTimeInterval(-oneDay)
            ),
            RemoteSale(
                productID: coffee.id,
                amount: "\(newerAmount)",
                currencyCode: audCurrencyCode,
                date: now
            ),
        ])
    }

    private var audOnly: Data {
        makeRatesJSON([audCurrencyCode: audRateToUSD, ProductDetailPolicy.usdCurrencyCode: "1"])
    }

    private var usdOnly: Data {
        makeRatesJSON([ProductDetailPolicy.usdCurrencyCode: "1"])
    }

    private func backendWithRates(_ rates: Data) -> HTTPClientStub {
        HTTPClientStub([
            AcceptanceApp.productsURL: [.success(makeProductsJSON([coffee]))],
            AcceptanceApp.salesURL: [.success(coffeeSalesJSON), .success(coffeeSalesJSON)],
            AcceptanceApp.ratesURL: [.success(rates)],
        ])
    }

    private var backendWithoutRates: HTTPClientStub {
        HTTPClientStub([
            AcceptanceApp.productsURL: [.success(makeProductsJSON([coffee]))],
            AcceptanceApp.salesURL: [.success(coffeeSalesJSON), .success(coffeeSalesJSON)],
        ])
    }

    private var backendWithoutSales: HTTPClientStub {
        HTTPClientStub([
            AcceptanceApp.productsURL: [.success(makeProductsJSON([coffee]))],
            AcceptanceApp.salesURL: [.success(coffeeSalesJSON)],
        ])
    }

    private var money: MoneyFormatter { MoneyFormatter(locale: AcceptanceApp.englishLocale) }

    private func aud(_ amount: Decimal) -> String {
        money.string(amount: amount, currencyCode: audCurrencyCode)
    }

    private func usdInARow(_ amount: Decimal) -> String {
        money.string(
            amount: amount,
            currencyCode: ProductDetailPolicy.usdCurrencyCode,
            symbol: usDollarSymbol
        )
    }

    private func usdInTheSummary(_ amount: Decimal) -> String {
        money.string(amount: amount, currencyCode: ProductDetailPolicy.usdCurrencyCode)
    }

    private var usDollarSymbol: String {
        NSLocalizedString(
            "PRODUCT_DETAIL_USD_SYMBOL", bundle: .productDetailPresentation, comment: "")
    }

    private var usdUnavailable: String {
        NSLocalizedString(
            "PRODUCT_DETAIL_USD_UNAVAILABLE", bundle: .productDetailPresentation, comment: "")
    }

    private let oneDay: TimeInterval = 60 * 60 * 24
}
