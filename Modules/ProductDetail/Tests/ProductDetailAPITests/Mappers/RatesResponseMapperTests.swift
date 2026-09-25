import Foundation
import ProductDetailAPI
import ProductDetailFeature
import TestSupport
import Testing

struct RatesResponseMapperTests {

    @Test func map_200Fixture_deliversEveryRateExactly() throws {
        let fixtureEuroRate = dec("1.18")
        let fixturePoundRate = dec("1.3216")
        let data = try Fixture.rates200.data

        let table = try RatesResponseMapper.map(
            data, from: anyHTTPURLResponse(statusCode: okStatusCode))

        #expect(table.rateToUSD(for: "EUR") == fixtureEuroRate)
        #expect(table.rateToUSD(for: "GBP") == fixturePoundRate)
    }

    @Test func map_200Fixture_leavesOutCurrenciesItNeverListed() throws {
        let unlistedCurrency = "JPY"
        let data = try Fixture.rates200.data

        let table = try RatesResponseMapper.map(
            data, from: anyHTTPURLResponse(statusCode: okStatusCode))

        #expect(table.rateToUSD(for: unlistedCurrency) == nil)
    }

    @Test func map_aRateThatIsNotANumber_throwsInvalidData() {
        let ratesWithABrokenValue = Data(#"{"rates": {"EUR": "not-a-number"}}"#.utf8)

        #expect(throws: RatesResponseMapper.Error.invalidData) {
            try RatesResponseMapper.map(
                ratesWithABrokenValue, from: anyHTTPURLResponse(statusCode: okStatusCode))
        }
    }

    @Test func map_invalidJSONOnAnOKResponse_throwsInvalidData() {
        #expect(throws: RatesResponseMapper.Error.invalidData) {
            try RatesResponseMapper.map(
                invalidJSON(), from: anyHTTPURLResponse(statusCode: okStatusCode))
        }
    }

    @Test func map_unexpectedStatusCode_throwsInvalidData() throws {
        let data = try Fixture.rates200.data

        #expect(throws: RatesResponseMapper.Error.invalidData) {
            try RatesResponseMapper.map(
                data, from: anyHTTPURLResponse(statusCode: serverErrorStatusCode))
        }
    }
}
