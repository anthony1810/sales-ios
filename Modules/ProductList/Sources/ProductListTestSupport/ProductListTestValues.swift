import Foundation
import ProductListFeature
import TestSupport

public func makeProduct(id: UUID = UUID(0), name: String = "any-product") -> Product {
    Product(id: id, name: name)
}

public func makeSale(productID: UUID = UUID(0)) -> Sale {
    Sale(productID: productID)
}

public func makeSummary(
    id: UUID = UUID(0),
    name: String = "any-product",
    salesCount: Int = 0
)
    -> ProductSummary
{
    ProductSummary(id: id, name: name, salesCount: salesCount)
}

public func makeSummary(of product: Product, salesCount: Int) -> ProductSummary {
    ProductSummary(id: product.id, name: product.name, salesCount: salesCount)
}
