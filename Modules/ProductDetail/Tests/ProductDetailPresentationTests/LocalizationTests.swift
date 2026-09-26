import TestSupport
import Testing

@testable import ProductDetailPresentation

struct LocalizationTests {

    @Test func localizable_everySupportedLanguage_hasEveryKeyTranslated() {
        verifyLocalizationCoverage(in: .productDetailPresentation, languages: ["en", "vi"])
    }
}
