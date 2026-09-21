import Foundation
import Testing

@testable import Auth

struct KeychainTokenStoreTests {

    @Test func load_freshService_deliversNoToken() async throws {
        let (sut, _) = makeSUT()

        #expect(try await sut.load() == nil)

        try await sut.clear()
    }

    @Test func load_storedToken_deliversItAcrossInstances() async throws {
        let (sut, service) = makeSUT()
        let stored = Token(value: "a-token")

        try await sut.store(stored)
        let secondInstance = KeychainTokenStore(service: service)

        #expect(try await secondInstance.load() == stored)

        try await sut.clear()
    }

    @Test func load_clearedService_deliversNoToken() async throws {
        let (sut, _) = makeSUT()
        try await sut.store(Token(value: "a-token"))

        try await sut.clear()

        #expect(try await sut.load() == nil)
    }

    @Test func store_replacingAnExistingToken_deliversTheNewOne() async throws {
        let (sut, _) = makeSUT()
        try await sut.store(Token(value: "old-token"))
        let replacement = Token(value: "new-token")

        try await sut.store(replacement)

        #expect(try await sut.load() == replacement)

        try await sut.clear()
    }

    // MARK: - Helpers

    private func makeSUT() -> (sut: KeychainTokenStore, service: String) {
        let service = "sales-ios.tests.\(UUID().uuidString)"
        return (KeychainTokenStore(service: service), service)
    }
}
