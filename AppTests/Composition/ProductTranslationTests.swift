import Foundation
import ProductDetailFeature
import ProductListFeature
import Testing

@testable import SalesInUSD

struct ProductTranslationTests {

    @Test func init_aListedProduct_carriesItsIdentityAndName() {
        let listed = ProductListFeature.Product(id: UUID(1), name: "Mac mini")

        let detailed = ProductDetailFeature.Product(listed: listed)

        #expect(detailed.id == listed.id)
        #expect(detailed.name == listed.name)
    }
}
