import Testing

@testable import TestSupport

struct TestSupportTests {

    @Test func evaluate_unsetResult_throwsResultNotSet() {
        let unset: Result<Int, any Error>? = nil

        #expect(throws: SpyError.self) {
            let _: Int = try unset.evaluate()
        }
    }

    @Test func evaluate_completedResult_deliversTheValue() throws {
        let completed: Result<Int, any Error>? = .success(7)

        #expect(try completed.evaluate() == 7)
    }

    @Test func call_heldStub_deliversOnceTheGateOpens() async throws {
        let stub = Stub<Int>(.success(7))
        let gate = stub.holdNext()

        async let value = stub.call()
        gate.open()

        #expect(try await value == 7)
    }
}
