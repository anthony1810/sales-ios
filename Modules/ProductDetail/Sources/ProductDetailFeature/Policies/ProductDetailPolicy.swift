import Foundation

public enum ProductDetailPolicy {
    public static func detail(of product: Product, sales: [Sale], rates: RateTable?)
        -> ProductDetail
    {
        let detailed =
            sales
            .filter { $0.productID == product.id }
            .sorted { $0.date > $1.date }
            .map { DetailedSale(amount: $0.amount, date: $0.date, convertedToUSD: nil) }
        return ProductDetail(product: product, sales: detailed, total: nil)
    }
}
