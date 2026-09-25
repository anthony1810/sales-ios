import Foundation
import TestSupport

enum Fixture: String, FixtureNaming {
    case rates200 = "RatesResponseMapperTests_200"
    case sales200 = "SalesResponseMapperTests_200"

    static var bundle: Bundle { .module }
}
