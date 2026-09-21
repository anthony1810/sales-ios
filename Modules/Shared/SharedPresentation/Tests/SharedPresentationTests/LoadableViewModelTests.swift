import TestSupport
import Testing

@testable import SharedPresentation

@MainActor
struct LoadableViewModelTests {

    @Test func load_succeedingLoader_deliversMappedRowsAndClearsTheError() async throws {
        let (sut, resource) = makeSUT()
        resource.complete(with: .failure(anyNSError()))
        await sut.load()
        try #require(sut.errorMessage != nil)

        resource.complete(with: .success(7))
        await sut.load()

        #expect(sut.rows == ["row-7"])
        #expect(sut.errorMessage == nil)
        #expect(sut.isLoading == false)
    }

    @Test func load_failingLoader_setsTheGenericMessageAndStopsLoading() async {
        let (sut, resource) = makeSUT()
        resource.complete(with: .failure(anyNSError()))

        await sut.load()

        #expect(sut.errorMessage == LoadableViewModel<Int, String>.loadErrorMessage)
        #expect(sut.rows == [])
        #expect(sut.isLoading == false)
    }

    @Test func load_runningLoader_reportsLoading() async {
        await withMainSerialExecutor {
            let (sut, resource) = makeSUT()
            resource.complete(with: .success(7))
            let gate = resource.holdNext()

            let inFlight = Task { await sut.load() }
            await Task.megaYield()

            #expect(sut.isLoading == true)
            gate.open()
            await inFlight.value
            #expect(sut.isLoading == false)
        }
    }

    // MARK: - Helpers

    private func makeSUT() -> (sut: LoadableViewModel<Int, String>, resource: Stub<Int>) {
        let resource = Stub<Int>()
        let sut = LoadableViewModel<Int, String>(
            loader: resource.call,
            map: { ["row-\($0)"] }
        )
        return (sut, resource)
    }
}
