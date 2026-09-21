import Foundation
import TestSupport

enum Fixture: String, FixtureNaming {
    case products200 = "ProductsResponseMapperTests_200"
    case sales200 = "SalesResponseMapperTests_200"

    static var bundle: Bundle { .module }
}
