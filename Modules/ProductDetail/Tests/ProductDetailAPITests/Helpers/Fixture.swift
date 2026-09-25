import Foundation
import TestSupport

enum Fixture: String, FixtureNaming {
    case rates200 = "RatesResponseMapperTests_200"

    static var bundle: Bundle { .module }
}
