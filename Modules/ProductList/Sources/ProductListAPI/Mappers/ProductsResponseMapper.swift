import Foundation
import ProductListFeature

public enum ProductsResponseMapper {
    public enum Error: Swift.Error, Equatable {
        case invalidData
    }

    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [Product] {
        guard response.statusCode == 200,
            let dtos = try? JSONDecoder().decode([ProductDTO].self, from: data)
        else {
            throw Error.invalidData
        }
        return dtos.map { Product(id: $0.id, name: $0.name) }
    }

    private struct ProductDTO: Decodable {
        let id: UUID
        let name: String
    }
}
