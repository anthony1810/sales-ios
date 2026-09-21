import Testing

@testable import Auth

struct InMemoryTokenStoreTests {

    @Test func load_freshStore_deliversNoToken() async throws {
        let sut = InMemoryTokenStore()

        #expect(try await sut.load() == nil)
    }

    @Test func load_storedToken_deliversIt() async throws {
        let sut = InMemoryTokenStore()
        let stored = Token(value: "a-token")

        try await sut.store(stored)

        #expect(try await sut.load() == stored)
    }

    @Test func load_clearedStore_deliversNoToken() async throws {
        let sut = InMemoryTokenStore()
        try await sut.store(Token(value: "a-token"))

        try await sut.clear()

        #expect(try await sut.load() == nil)
    }
}
