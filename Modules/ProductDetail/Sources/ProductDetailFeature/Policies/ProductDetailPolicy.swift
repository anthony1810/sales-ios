import Foundation

public enum ProductDetailPolicy {
    public static let usdCurrencyCode = "USD"

    public static func convertedToUSD(_ money: Money, using rates: RateTable) -> Money? {
        guard let rate = rates.rateToUSD(for: money.currencyCode) else { return nil }
        return Money(amount: money.amount * rate, currencyCode: usdCurrencyCode)
    }

    public static func detail(of product: Product, sales: [Sale], rates: RateTable?)
        -> ProductDetail
    {
        let detailed =
            sales
            .filter { $0.productID == product.id }
            .sorted { $0.date > $1.date }
            .map { sale in
                DetailedSale(
                    amount: sale.amount,
                    date: sale.date,
                    convertedToUSD: rates.flatMap { convertedToUSD(sale.amount, using: $0) }
                )
            }
        return ProductDetail(product: product, sales: detailed, total: total(of: detailed))
    }

    private static func total(of sales: [DetailedSale]) -> Money? {
        guard sales.isEmpty == false else { return nil }
        var sum = Decimal.zero
        for sale in sales {
            guard let converted = sale.convertedToUSD else { return nil }
            sum += converted.amount
        }
        return Money(amount: sum, currencyCode: usdCurrencyCode)
    }
}
