import Foundation
import Testing

@testable import SalesInUSD

struct ServiceURLsTests {

    @Test func rates_noOverride_pointsAtTheLocalMiddleware() {
        let realEnvironment: [String: String] = [:]

        #expect(ServiceURLs.rates(environment: realEnvironment) == ServiceURLs.defaultRates)
    }

    @Test func rates_anOverride_pointsAtThatHostInstead() throws {
        let hostedMiddleware = "https://rates.example.com"
        let environment = [ServiceURLs.ratesOverrideKey: hostedMiddleware]

        let url = ServiceURLs.rates(environment: environment)

        #expect(url == URL(string: hostedMiddleware))
    }

    @Test func rates_anUnusableOverride_fallsBackToTheLocalMiddleware() {
        let environment = [ServiceURLs.ratesOverrideKey: ""]

        #expect(ServiceURLs.rates(environment: environment) == ServiceURLs.defaultRates)
    }
}
