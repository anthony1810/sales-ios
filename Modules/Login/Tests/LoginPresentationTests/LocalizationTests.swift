import TestSupport
import Testing

@testable import LoginPresentation

struct LocalizationTests {

    @Test func localizable_everySupportedLanguage_hasEveryKeyTranslated() {
        verifyLocalizationCoverage(in: .loginPresentation, languages: ["en", "vi"])
    }
}
