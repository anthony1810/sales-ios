import Foundation
import TestSupport
import Testing

@testable import SharedPresentation

struct MoneyFormatterTests {

    // MARK: - With the currency's own symbol

    @Test func string_brazilianReais_useTheirSymbolAndGroupThousands() {
        let sut = makeSUT()

        let formatted = sut.string(amount: dec("2299"), currencyCode: "BRL")

        #expect(formatted == "R$2,299")
    }

    @Test func string_britishPounds_useTheirSymbol() {
        let sut = makeSUT()

        let formatted = sut.string(amount: dec("304"), currencyCode: "GBP")

        #expect(formatted == "£304")
    }

    @Test func string_usDollars_useThePlainDollarSign() {
        let sut = makeSUT()

        let formatted = sut.string(amount: dec("107587"), currencyCode: "USD")

        #expect(formatted == "$107,587")
    }

    @Test func string_anAmountWithCents_roundsToWholeUnitsForDisplay() {
        let exactAmount = dec("436.81")
        let sut = makeSUT()

        let formatted = sut.string(amount: exactAmount, currencyCode: "USD")

        #expect(formatted == "$437")
    }

    // MARK: - With an explicit symbol

    @Test func string_anExplicitSymbol_replacesTheCurrencysOwn() {
        let sut = makeSUT()

        let formatted = sut.string(amount: dec("407"), currencyCode: "USD", symbol: "US$")

        #expect(formatted == "US$407")
    }

    @Test func string_anExplicitSymbol_doesNotLeakIntoLaterCalls() {
        let sut = makeSUT()

        _ = sut.string(amount: dec("407"), currencyCode: "USD", symbol: "US$")
        let formatted = sut.string(amount: dec("407"), currencyCode: "USD")

        #expect(formatted == "$407")
    }

    // MARK: - Helpers

    private func makeSUT() -> MoneyFormatter {
        MoneyFormatter(locale: Locale(identifier: "en_US"))
    }
}
