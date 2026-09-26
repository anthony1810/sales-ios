import Foundation
import ProductDetailFeature
import ProductListFeature

extension ProductDetailFeature.Product {
    init(listed: ProductListFeature.Product) {
        self.init(id: listed.id, name: listed.name)
    }
}
