import Observation

@Observable
@MainActor
public final class LoadableViewModel<Resource: Sendable, Row: Equatable> {
    public private(set) var isLoading = false
    public private(set) var rows: [Row] = []
    public private(set) var errorMessage: String?

    public static var loadErrorMessage: String { "Something went wrong. Please try again." }

    private let loader: @Sendable () async throws -> Resource
    private let map: (Resource) -> [Row]

    public init(
        loader: @escaping @Sendable () async throws -> Resource,
        map: @escaping (Resource) -> [Row]
    ) {
        self.loader = loader
        self.map = map
    }

    public func load() async {
        isLoading = true
        errorMessage = nil
        do {
            rows = map(try await loader())
        } catch {
            errorMessage = Self.loadErrorMessage
        }
        isLoading = false
    }
}
