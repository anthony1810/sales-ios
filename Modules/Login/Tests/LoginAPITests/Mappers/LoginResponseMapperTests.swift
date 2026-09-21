import Auth
import Foundation
import LoginAPI
import LoginFeature
import TestSupport
import Testing

struct LoginResponseMapperTests {

    @Test func map_200Fixture_deliversTheAccessToken() throws {
        let fixtureAccessToken = "20c3282ce7bbf78edb9bd07574d5a6c7"
        let data = try Fixture.login200.data

        let token = try LoginResponseMapper.map(
            data,
            from: anyHTTPURLResponse(statusCode: okStatusCode)
        )

        #expect(token == Token(value: fixtureAccessToken))
    }

    @Test func map_401Fixture_throwsTheServersOwnMessage() throws {
        let fixtureServerMessage = "Invalid credentials."
        let data = try Fixture.login401.data

        #expect(throws: LoginUseCase.Error.invalidCredentials(message: fixtureServerMessage)) {
            try LoginResponseMapper.map(
                data,
                from: anyHTTPURLResponse(statusCode: unauthorizedStatusCode)
            )
        }
    }

    @Test func map_invalidJSONOnAnOKResponse_throwsInvalidData() {
        #expect(throws: LoginResponseMapper.Error.invalidData) {
            try LoginResponseMapper.map(
                invalidJSON(),
                from: anyHTTPURLResponse(statusCode: okStatusCode)
            )
        }
    }

    @Test func map_unexpectedStatusCode_throwsInvalidData() throws {
        let data = try Fixture.login200.data

        #expect(throws: LoginResponseMapper.Error.invalidData) {
            try LoginResponseMapper.map(
                data,
                from: anyHTTPURLResponse(statusCode: serverErrorStatusCode)
            )
        }
    }
}
