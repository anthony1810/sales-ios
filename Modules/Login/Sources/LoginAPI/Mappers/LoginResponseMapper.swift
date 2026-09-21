import Auth
import Foundation
import LoginFeature

public enum LoginResponseMapper {
    public enum Error: Swift.Error, Equatable {
        case invalidData
    }

    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> Token {
        switch response.statusCode {
        case 200:
            guard let dto = try? JSONDecoder().decode(AccessTokenDTO.self, from: data) else {
                throw Error.invalidData
            }
            return Token(value: dto.access_token)
        case 401:
            guard let dto = try? JSONDecoder().decode(ErrorMessageDTO.self, from: data) else {
                throw Error.invalidData
            }
            throw LoginUseCase.Error.invalidCredentials(message: dto.message)
        default:
            throw Error.invalidData
        }
    }

    private struct AccessTokenDTO: Decodable {
        let access_token: String
    }

    private struct ErrorMessageDTO: Decodable {
        let message: String
    }
}
