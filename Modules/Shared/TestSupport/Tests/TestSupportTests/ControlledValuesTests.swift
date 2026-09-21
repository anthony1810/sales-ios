import Foundation
import TestSupport
import Testing

struct ControlledValuesTests {

    @Test func uuid_sameIndex_isStable() {
        #expect(UUID(0) == UUID(0))
        #expect(UUID(7) == UUID(7))
    }

    @Test func uuid_distinctIndexes_deliverDistinctValues() {
        #expect(UUID(1) != UUID(2))
    }

    @Test func uuid_indexZero_isTheAllZeroUUID() {
        #expect(UUID(0).uuidString == "00000000-0000-0000-0000-000000000000")
    }

    @Test func dateFixture_epochString_deliversTheEpoch() {
        #expect(Date.fixture("1970-01-01T00:00:00.000Z").timeIntervalSince1970 == 0)
    }

    @Test func dateFixture_fractionalSeconds_shiftTheInstant() {
        let base = Date.fixture("1970-01-01T00:00:00.000Z")
        let halfSecondLater = Date.fixture("1970-01-01T00:00:00.500Z")

        #expect(halfSecondLater.timeIntervalSince(base) == 0.5)
    }
}
