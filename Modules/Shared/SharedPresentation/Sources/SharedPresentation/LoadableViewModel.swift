import Observation

@Observable
@MainActor
public final class LoadableViewModel<Resource: Sendable, Row: Equatable> {
    public private(set) var isLoading = false
    public private(set) var rows: [Row] = []
    public private(set) var errorMessage: String?

    public static var loadErrorMessage: String { Localized.string("GENERIC_LOAD_ERROR") }

    private let loader: @Sendable () async throws -> Resource
    private let map: (Resource) -> [Row]
    private let failureMessage: String
    private var loadGeneration = 0

    public init(
        loader: @escaping @Sendable () async throws -> Resource,
        map: @escaping (Resource) -> [Row],
        failureMessage: String = LoadableViewModel.loadErrorMessage
    ) {
        self.loader = loader
        self.map = map
        self.failureMessage = failureMessage
    }

    public func load() async {
        loadGeneration += 1
        let generation = loadGeneration
        isLoading = true
        errorMessage = nil
        do {
            let resource = try await loader()
            guard generation == loadGeneration else { return }
            rows = map(resource)
        } catch {
            guard generation == loadGeneration else { return }
            errorMessage = failureMessage
        }
        isLoading = false
    }
}
