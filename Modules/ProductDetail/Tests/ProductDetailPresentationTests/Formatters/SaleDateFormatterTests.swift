import Foundation
import ProductDetailPresentation
import TestSupport
import Testing

struct SaleDateFormatterTests {

    @Test func string_aMorningSale_readsExactlyAsTheBriefWritesIt() {
        let briefMorningExample = "Jan 2, 2030 at 11 am"
        let sut = makeSUT()

        let formatted = sut.string(from: Date.fixture("2030-01-02T11:00:00.000Z"))

        #expect(formatted == briefMorningExample)
    }

    @Test func string_anAfternoonSale_readsExactlyAsTheBriefWritesIt() {
        let briefAfternoonExample = "Jan 1, 2030 at 3 pm"
        let sut = makeSUT()

        let formatted = sut.string(from: Date.fixture("2030-01-01T15:00:00.000Z"))

        #expect(formatted == briefAfternoonExample)
    }

    @Test func string_aSaleWithMinutesPastTheHour_dropsTheMinutes() {
        let onTheHourWording = "Jan 2, 2030 at 11 am"
        let sut = makeSUT()

        let formatted = sut.string(from: Date.fixture("2030-01-02T11:47:33.912Z"))

        #expect(formatted == onTheHourWording)
    }

    @Test func string_aDateInAnotherTimeZone_usesTheInjectedZone() {
        let sydney = TimeZone(identifier: "Australia/Sydney")!
        let sut = makeSUT(timeZone: sydney)

        let formatted = sut.string(from: Date.fixture("2030-01-01T23:00:00.000Z"))

        #expect(formatted == "Jan 2, 2030 at 10 am")
    }

    @Test func string_aVietnameseReader_seesTheVietnamesePattern() {
        let vietnameseMorning = "2 thg 1, 2030 lúc 11 SA"
        let sut = SaleDateFormatter(
            locale: Locale(identifier: "vi_VN"), timeZone: TimeZone(identifier: "UTC")!)

        let formatted = sut.string(from: Date.fixture("2030-01-02T11:00:00.000Z"))

        #expect(formatted == vietnameseMorning)
    }

    // MARK: - Helpers

    private func makeSUT(timeZone: TimeZone = TimeZone(identifier: "UTC")!) -> SaleDateFormatter {
        SaleDateFormatter(locale: Locale(identifier: "en_US"), timeZone: timeZone)
    }
}
