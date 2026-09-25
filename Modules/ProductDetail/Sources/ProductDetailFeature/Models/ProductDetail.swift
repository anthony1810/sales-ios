import Foundation

public struct ProductDetail: Equatable, Sendable {
    public let product: Product
    public let sales: [DetailedSale]
    public let total: Money?

    public init(product: Product, sales: [DetailedSale], total: Money?) {
        self.product = product
        self.sales = sales
        self.total = total
    }
}
