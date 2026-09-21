import Foundation
import ProductListAPI
import ProductListFeature
import ProductListTestSupport
import TestSupport
import Testing

struct ProductsResponseMapperTests {

    @Test func map_200Fixture_deliversTheProducts() throws {
        let fixtureProducts = [
            makeProduct(id: UUID(1), name: "Mac mini"),
            makeProduct(id: UUID(2), name: "Apple TV"),
        ]
        let data = try Fixture.products200.data

        let products = try ProductsResponseMapper.map(
            data,
            from: anyHTTPURLResponse(statusCode: okStatusCode)
        )

        #expect(products == fixtureProducts)
    }

    @Test func map_invalidJSONOnAnOKResponse_throwsInvalidData() {
        #expect(throws: ProductsResponseMapper.Error.invalidData) {
            try ProductsResponseMapper.map(
                invalidJSON(),
                from: anyHTTPURLResponse(statusCode: okStatusCode)
            )
        }
    }

    @Test func map_unexpectedStatusCode_throwsInvalidData() throws {
        let data = try Fixture.products200.data

        #expect(throws: ProductsResponseMapper.Error.invalidData) {
            try ProductsResponseMapper.map(
                data,
                from: anyHTTPURLResponse(statusCode: serverErrorStatusCode)
            )
        }
    }
}
