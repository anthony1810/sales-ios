#if DEBUG
import Auth
import Foundation
import HTTPClient
import HTTPClientLive

enum LaunchArguments {
    static let reset = "-reset"
    static let connectivity = "-connectivity"
    static let offline = "offline"
}

extension AppComposition {
    static func launch(arguments: [String] = ProcessInfo.processInfo.arguments) -> AppComposition {
        if arguments.contains(LaunchArguments.reset) {
            try? KeychainTokenStore(service: keychainService).removeToken()
        }
        if isOffline(arguments) {
            return AppComposition(httpClient: AlwaysFailingHTTPClient())
        }
        return AppComposition()
    }

    private static func isOffline(_ arguments: [String]) -> Bool {
        guard let index = arguments.firstIndex(of: LaunchArguments.connectivity),
            arguments.indices.contains(index + 1)
        else {
            return false
        }
        return arguments[index + 1] == LaunchArguments.offline
    }
}

private struct AlwaysFailingHTTPClient: HTTPClient {
    struct Offline: Error {}

    func perform(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        throw Offline()
    }
}
#else
extension AppComposition {
    static func launch() -> AppComposition {
        AppComposition()
    }
}
#endif
