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

    @Test func load_failingLoaderWithAnInjectedMessage_showsThatMessage() async {
        let screenMessage = "This screen could not load."
        let (_, resource) = makeSUT()
        resource.complete(with: .failure(anyNSError()))
        let sut = LoadableViewModel<Int, String>(
            loader: resource.call,
            map: { ["row-\($0)"] },
            failureMessage: screenMessage
        )

        await sut.load()

        #expect(sut.errorMessage == screenMessage)
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

    @Test func load_overlappingLoads_keepOnlyTheLatestResult() async {
        await withMainSerialExecutor {
            let firstCallGate = Gate()
            let calls = LockIsolated(0)
            let sut = LoadableViewModel<Int, String>(
                loader: {
                    let call = calls.withValue { count in
                        count += 1
                        return count
                    }
                    if call == 1 {
                        await firstCallGate.wait()
                        return 1
                    }
                    return 2
                },
                map: { ["row-\($0)"] }
            )

            let staleLoad = Task { await sut.load() }
            await Task.megaYield()
            let freshLoad = Task { await sut.load() }
            await freshLoad.value
            firstCallGate.open()
            await staleLoad.value

            #expect(sut.rows == ["row-2"])
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
