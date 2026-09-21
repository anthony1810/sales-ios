import Foundation
import ProductListAPI
import ProductListFeature
import ProductListTestSupport
import TestSupport
import Testing

struct SalesResponseMapperTests {

    @Test func map_200Fixture_deliversOneSalePerEntryCarryingItsProductID() throws {
        let fixtureSales = [
            makeSale(productID: UUID(1)),
            makeSale(productID: UUID(2)),
            makeSale(productID: UUID(1)),
        ]
        let data = try Fixture.sales200.data

        let sales = try SalesResponseMapper.map(
            data,
            from: anyHTTPURLResponse(statusCode: okStatusCode)
        )

        #expect(sales == fixtureSales)
    }

    @Test func map_invalidJSONOnAnOKResponse_throwsInvalidData() {
        #expect(throws: SalesResponseMapper.Error.invalidData) {
            try SalesResponseMapper.map(
                invalidJSON(),
                from: anyHTTPURLResponse(statusCode: okStatusCode)
            )
        }
    }

    @Test func map_unexpectedStatusCode_throwsInvalidData() throws {
        let data = try Fixture.sales200.data

        #expect(throws: SalesResponseMapper.Error.invalidData) {
            try SalesResponseMapper.map(
                data,
                from: anyHTTPURLResponse(statusCode: serverErrorStatusCode)
            )
        }
    }
}
