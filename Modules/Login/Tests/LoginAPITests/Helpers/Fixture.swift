import Foundation
import TestSupport

enum Fixture: String, FixtureNaming {
    case login200 = "LoginResponseMapperTests_200"
    case login401 = "LoginResponseMapperTests_401"

    static var bundle: Bundle { .module }
}
