import Foundation

enum Localized {
    static func string(_ key: String) -> String {
        NSLocalizedString(key, tableName: nil, bundle: .module, comment: "")
    }
}

extension Bundle {
    public static var productListPresentation: Bundle { .module }
}
