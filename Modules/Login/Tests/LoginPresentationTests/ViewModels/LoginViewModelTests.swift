import LoginPresentation
import Testing

@MainActor
struct LoginViewModelTests {

    @Test func canSubmit_bothFieldsFilled_allowsSubmission() {
        let sut = LoginViewModel()

        sut.username = "any-username"
        sut.password = "any-password"

        #expect(sut.canSubmit == true)
    }

    @Test func canSubmit_emptyUsername_blocksSubmission() {
        let sut = LoginViewModel()

        sut.username = ""
        sut.password = "any-password"

        #expect(sut.canSubmit == false)
    }

    @Test func canSubmit_emptyPassword_blocksSubmission() {
        let sut = LoginViewModel()

        sut.username = "any-username"
        sut.password = ""

        #expect(sut.canSubmit == false)
    }
}
