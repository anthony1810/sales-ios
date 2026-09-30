struct TesterAccount {
    let username: String
    let password: String

    static let valid = TesterAccount(username: "tester", password: "password")
    static let unknown = TesterAccount(username: "nobody", password: "wrong-password")
}
