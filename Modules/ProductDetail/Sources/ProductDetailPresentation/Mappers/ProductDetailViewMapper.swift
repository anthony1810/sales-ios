import Foundation
import ProductDetailFeature
import SharedPresentation

public struct ProductDetailViewMapper {
    private let dates: SaleDateFormatter
    private let money: MoneyFormatter

    public init(dates: SaleDateFormatter, money: MoneyFormatter) {
        self.dates = dates
        self.money = money
    }

    public func viewData(for detail: ProductDetail) -> ProductDetailViewData {
        ProductDetailViewData(
            title: detail.product.name,
            summaryText: summary(total: detail.total, saleCount: detail.sales.count),
            rows: detail.sales.enumerated().map(row(at:sale:))
        )
    }

    private func row(at index: Int, sale: DetailedSale) -> SaleRow {
        SaleRow(
            id: index,
            amountText: money.string(
                amount: sale.amount.amount, currencyCode: sale.amount.currencyCode),
            dateText: dates.string(from: sale.date),
            convertedText: sale.convertedToUSD.map(usdText(for:)) ?? Self.usdUnavailable
        )
    }

    private func summary(total: Money?, saleCount: Int) -> String {
        let totalText =
            total.map { money.string(amount: $0.amount, currencyCode: $0.currencyCode) }
            ?? Self.usdUnavailable
        return String.localizedStringWithFormat(
            Localized.string("PRODUCT_DETAIL_SUMMARY"), totalText, saleCount)
    }

    private func usdText(for money: Money) -> String {
        self.money.string(
            amount: money.amount, currencyCode: money.currencyCode, symbol: Self.usDollarSymbol)
    }

    private static var usDollarSymbol: String { Localized.string("PRODUCT_DETAIL_USD_SYMBOL") }
    private static var usdUnavailable: String { Localized.string("PRODUCT_DETAIL_USD_UNAVAILABLE") }
}
