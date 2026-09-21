import Foundation
import LoginFeature

public enum LoginEndpoint {
    case login(Credentials)

    public func request(baseURL: URL) -> URLRequest {
        switch self {
        case let .login(credentials):
            var request = URLRequest(url: baseURL.appending(path: "login"))
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONEncoder().encode([
                "username": credentials.username,
                "password": credentials.password,
            ])
            return request
        }
    }
}
