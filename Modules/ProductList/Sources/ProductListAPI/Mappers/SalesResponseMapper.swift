import Foundation
import ProductListFeature

public enum SalesResponseMapper {
    public enum Error: Swift.Error, Equatable {
        case invalidData
    }

    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [Sale] {
        guard response.statusCode == 200,
            let dtos = try? JSONDecoder().decode([SaleDTO].self, from: data)
        else {
            throw Error.invalidData
        }
        return dtos.map { Sale(productID: $0.product_id) }
    }

    private struct SaleDTO: Decodable {
        let product_id: UUID
    }
}
