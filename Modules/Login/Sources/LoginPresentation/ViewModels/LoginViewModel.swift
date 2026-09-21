import Observation

@Observable
@MainActor
public final class LoginViewModel {
    public var username = ""
    public var password = ""

    public init() {}

    public var canSubmit: Bool { !username.isEmpty && !password.isEmpty }
}
