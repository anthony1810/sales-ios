import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public final class Stub<Output: Sendable>: Sendable {
    private let result = LockIsolated<Result<Output, Error>?>(nil)
    private let gate = LockIsolated<Gate?>(nil)

    public init(_ initial: Result<Output, Error>? = nil) {
        result.setValue(initial)
    }

    public func complete(with newResult: Result<Output, Error>) {
        result.setValue(newResult)
    }

    public func holdNext() -> Gate {
        let next = Gate()
        gate.setValue(next)
        return next
    }

    public func call() async throws -> Output {
        let held = gate.withValue { current in
            let taken = current
            current = nil
            return taken
        }
        await held?.wait()
        return try result.value.evaluate()
    }
}

public enum SpyError: Error { case resultNotSet }

extension Optional {
    public func evaluate<Success, Failure: Error>() throws -> Success
    where Wrapped == Result<Success, Failure> {
        switch self {
        case .none: throw SpyError.resultNotSet
        case .some(let result): return try result.get()
        }
    }
}

public func anyURL() -> URL { URL(string: "https://any-url.com")! }
public func anyNSError() -> NSError { NSError(domain: "any", code: 0) }
public func invalidJSON() -> Data { Data("invalid json".utf8) }
public let okStatusCode = 200
public let unauthorizedStatusCode = 401
public let serverErrorStatusCode = 500

public func anyHTTPURLResponse(statusCode: Int = okStatusCode) -> HTTPURLResponse {
    HTTPURLResponse(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
}

public func okHTTPURLResponse(for url: URL) -> HTTPURLResponse {
    HTTPURLResponse(url: url, statusCode: okStatusCode, httpVersion: nil, headerFields: nil)!
}
