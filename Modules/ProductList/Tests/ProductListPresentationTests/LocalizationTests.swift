import TestSupport
import Testing

@testable import ProductListPresentation

struct LocalizationTests {

    @Test func localizable_everySupportedLanguage_hasEveryKeyTranslated() {
        verifyLocalizationCoverage(in: .productListPresentation, languages: ["en", "vi"])
    }
}
