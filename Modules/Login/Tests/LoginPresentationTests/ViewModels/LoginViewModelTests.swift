import LoginFeature
import LoginPresentation
import TestSupport
import Testing

@MainActor
struct LoginViewModelTests {

    // MARK: - canSubmit

    @Test func canSubmit_bothFieldsFilled_allowsSubmission() {
        let sut = makeSUT()

        sut.username = "any-username"
        sut.password = "any-password"

        #expect(sut.canSubmit == true)
    }

    @Test func canSubmit_emptyUsername_blocksSubmission() {
        let sut = makeSUT()

        sut.username = ""
        sut.password = "any-password"

        #expect(sut.canSubmit == false)
    }

    @Test func canSubmit_emptyPassword_blocksSubmission() {
        let sut = makeSUT()

        sut.username = "any-username"
        sut.password = ""

        #expect(sut.canSubmit == false)
    }

    // MARK: - Submit

    @Test func submit_succeedingLogin_sendsTheCredentialsSignalsSuccessAndStopsLoading() async {
        let receivedCredentials = LockIsolated<[Credentials]>([])
        let sut = makeSUT(login: { credentials in
            receivedCredentials.withValue { $0.append(credentials) }
        })
        sut.username = "any-username"
        sut.password = "any-password"
        let succeeded = LockIsolated(false)
        sut.onSuccess = { succeeded.setValue(true) }

        await sut.submit()

        #expect(
            receivedCredentials.value == [
                Credentials(username: "any-username", password: "any-password")
            ]
        )
        #expect(succeeded.value == true)
        #expect(sut.errorMessage == nil)
        #expect(sut.isLoading == false)
    }

    @Test func submit_invalidCredentialsFailure_displaysTheServersOwnMessage() async {
        let serverMessage = "Invalid credentials."
        let sut = makeSUT(login: { _ in
            throw LoginUseCase.Error.invalidCredentials(message: serverMessage)
        })
        sut.username = "any-username"
        sut.password = "any-password"

        await sut.submit()

        #expect(sut.errorMessage == serverMessage)
        #expect(sut.isLoading == false)
    }

    @Test func submit_anyOtherFailure_displaysTheGenericMessage() async {
        let sut = makeSUT(login: { _ in throw anyNSError() })
        sut.username = "any-username"
        sut.password = "any-password"

        await sut.submit()

        #expect(sut.errorMessage == LoginViewModel.genericErrorMessage)
        #expect(sut.isLoading == false)
    }

    @Test func submit_withAPriorFailure_clearsTheErrorMessageOnSuccess() async throws {
        let calls = LockIsolated(0)
        let sut = makeSUT(login: { _ in
            let call = calls.withValue { count in
                count += 1
                return count
            }
            if call == 1 { throw anyNSError() }
        })
        sut.username = "any-username"
        sut.password = "any-password"

        await sut.submit()
        try #require(sut.errorMessage != nil)

        await sut.submit()

        #expect(sut.errorMessage == nil)
    }

    @Test func submit_runningLogin_reportsLoading() async {
        await withMainSerialExecutor {
            let gate = Gate()
            let sut = makeSUT(login: { _ in await gate.wait() })
            sut.username = "any-username"
            sut.password = "any-password"

            let inFlight = Task { await sut.submit() }
            await Task.megaYield()

            #expect(sut.isLoading == true)
            gate.open()
            await inFlight.value
            #expect(sut.isLoading == false)
        }
    }

    // MARK: - Helpers

    private func makeSUT(
        login: @escaping @Sendable (Credentials) async throws -> Void = { _ in }
    ) -> LoginViewModel {
        LoginViewModel(login: login)
    }
}
