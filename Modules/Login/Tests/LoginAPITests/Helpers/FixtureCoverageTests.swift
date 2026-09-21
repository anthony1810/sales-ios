import TestSupport
import Testing

struct FixtureCoverageTests {

    @Test func fixtures_enumCasesAndFilesOnDisk_stayInSync() {
        verifyFixtureCoverage(Fixture.self)
    }
}
