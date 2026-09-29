import LoginFeature
import Observation

@Observable
@MainActor
public final class LoginViewModel {
    public var username = ""
    public var password = ""
    public private(set) var isLoading = false
    public private(set) var errorMessage: String?
    public var onSuccess: (@MainActor () -> Void)?
    public var showsSessionExpired = false

    public static var title: String { Localized.string("LOGIN_TITLE") }
    public static var usernamePlaceholder: String { Localized.string("LOGIN_USERNAME_PLACEHOLDER") }
    public static var passwordPlaceholder: String { Localized.string("LOGIN_PASSWORD_PLACEHOLDER") }
    public static var submitButtonTitle: String { Localized.string("LOGIN_SUBMIT_BUTTON") }
    public static var genericErrorMessage: String { Localized.string("LOGIN_GENERIC_ERROR") }
    public static var sessionExpiredMessage: String {
        Localized.string("LOGIN_SESSION_EXPIRED")
    }

    private let login: @Sendable (Credentials) async throws -> Void

    public init(login: @escaping @Sendable (Credentials) async throws -> Void) {
        self.login = login
    }

    public var canSubmit: Bool { !username.isEmpty && !password.isEmpty }

    public func submit() async {
        guard !isLoading else { return }
        showsSessionExpired = false
        isLoading = true
        errorMessage = nil
        do {
            try await login(Credentials(username: username, password: password))
            onSuccess?()
        } catch LoginUseCase.Error.invalidCredentials(let message) {
            errorMessage = message
        } catch {
            errorMessage = Self.genericErrorMessage
        }
        isLoading = false
    }
}
