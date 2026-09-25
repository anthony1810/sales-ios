import Foundation

public final class MoneyFormatter {
    private let withTheCurrencysOwnSymbol: NumberFormatter
    private let withAnExplicitSymbol: NumberFormatter

    public init(locale: Locale) {
        withTheCurrencysOwnSymbol = MoneyFormatter.wholeAmountFormatter(locale: locale)
        withAnExplicitSymbol = MoneyFormatter.wholeAmountFormatter(locale: locale)
    }

    public func string(amount: Decimal, currencyCode: String) -> String {
        withTheCurrencysOwnSymbol.currencyCode = currencyCode
        return withTheCurrencysOwnSymbol.string(from: amount as NSDecimalNumber) ?? ""
    }

    public func string(amount: Decimal, currencyCode: String, symbol: String) -> String {
        withAnExplicitSymbol.currencyCode = currencyCode
        withAnExplicitSymbol.currencySymbol = symbol
        return withAnExplicitSymbol.string(from: amount as NSDecimalNumber) ?? ""
    }

    private static func wholeAmountFormatter(locale: Locale) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        return formatter
    }
}
