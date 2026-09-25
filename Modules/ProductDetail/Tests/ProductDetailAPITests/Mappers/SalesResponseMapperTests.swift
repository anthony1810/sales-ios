import Foundation
import ProductDetailAPI
import ProductDetailFeature
import ProductDetailTestSupport
import TestSupport
import Testing

struct SalesResponseMapperTests {

    @Test func map_200Fixture_deliversEverySaleWithItsExactAmountAndDate() throws {
        let fixtureSales = [
            makeSale(
                productID: UUID(1),
                amount: makeMoney(dec("1480.79"), currencyCode: "AUD"),
                date: Date.fixture("2024-07-20T15:45:27.366Z")
            ),
            makeSale(
                productID: UUID(2),
                amount: makeMoney(dec("2299.00"), currencyCode: "BRL"),
                date: Date.fixture("2024-07-21T09:12:03.101Z")
            ),
        ]
        let data = try Fixture.sales200.data

        let sales = try SalesResponseMapper.map(
            data, from: anyHTTPURLResponse(statusCode: okStatusCode))

        #expect(sales == fixtureSales)
    }

    @Test func map_anAmountThatIsNotANumber_throwsInvalidData() {
        let brokenAmount = Data(
            #"[{"currency_code":"AUD","amount":"not-a-number","product_id":"00000000-0000-0000-0000-000000000001","date":"2024-07-20T15:45:27.366Z"}]"#
                .utf8)

        #expect(throws: SalesResponseMapper.Error.invalidData) {
            try SalesResponseMapper.map(
                brokenAmount, from: anyHTTPURLResponse(statusCode: okStatusCode))
        }
    }

    @Test func map_aDateWithoutFractionalSeconds_isStillAccepted() throws {
        let secondsOnly = "2024-07-20T15:45:27Z"
        let secondsOnlyDate = Data(
            #"[{"currency_code":"AUD","amount":"10.00","product_id":"00000000-0000-0000-0000-000000000001","date":"\#(secondsOnly)"}]"#
                .utf8)

        let sales = try SalesResponseMapper.map(
            secondsOnlyDate, from: anyHTTPURLResponse(statusCode: okStatusCode))

        #expect(sales.map(\.date) == [Date.fixture("2024-07-20T15:45:27.000Z")])
    }

    @Test func map_aMalformedDate_throwsInvalidData() {
        let malformedDate = Data(
            #"[{"currency_code":"AUD","amount":"10.00","product_id":"00000000-0000-0000-0000-000000000001","date":"not-a-date"}]"#
                .utf8)

        #expect(throws: SalesResponseMapper.Error.invalidData) {
            try SalesResponseMapper.map(
                malformedDate, from: anyHTTPURLResponse(statusCode: okStatusCode))
        }
    }

    @Test func map_invalidJSONOnAnOKResponse_throwsInvalidData() {
        #expect(throws: SalesResponseMapper.Error.invalidData) {
            try SalesResponseMapper.map(
                invalidJSON(), from: anyHTTPURLResponse(statusCode: okStatusCode))
        }
    }

    @Test func map_unexpectedStatusCode_throwsInvalidData() throws {
        let data = try Fixture.sales200.data

        #expect(throws: SalesResponseMapper.Error.invalidData) {
            try SalesResponseMapper.map(
                data, from: anyHTTPURLResponse(statusCode: serverErrorStatusCode))
        }
    }
}
