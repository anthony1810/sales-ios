import TestSupport
import Testing

@testable import SharedPresentation

struct LocalizationTests {

    @Test func localizable_everySupportedLanguage_hasEveryKeyTranslated() {
        verifyLocalizationCoverage(in: .sharedPresentation, languages: ["en", "vi"])
    }
}
