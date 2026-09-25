import Foundation
import ProductDetailFeature
import TestSupport

public func makeProduct(id: UUID = UUID(0), name: String = "any-product") -> Product {
    Product(id: id, name: name)
}

public func makeMoney(_ amount: Decimal = 1, currencyCode: String = "AUD") -> Money {
    Money(amount: amount, currencyCode: currencyCode)
}

public func makeSale(
    productID: UUID = UUID(0),
    amount: Money = makeMoney(),
    date: Date = Date(timeIntervalSince1970: 0)
) -> Sale {
    Sale(productID: productID, amount: amount, date: date)
}
