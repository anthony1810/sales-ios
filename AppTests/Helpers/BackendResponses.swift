import Foundation

struct RemoteProduct {
    let id: UUID
    let name: String

    var json: [String: Any] { ["id": id.uuidString, "name": name] }
}

struct RemoteSale {
    let productID: UUID
    let amount: String
    let currencyCode: String
    let date: Date

    var json: [String: Any] {
        [
            "product_id": productID.uuidString,
            "amount": amount,
            "currency_code": currencyCode,
            "date": date.formatted(Date.ISO8601FormatStyle(includingFractionalSeconds: true)),
        ]
    }
}

func makeProductsJSON(_ products: [RemoteProduct]) -> Data {
    jsonData(from: products.map(\.json))
}

func makeSalesJSON(_ sales: [RemoteSale]) -> Data {
    jsonData(from: sales.map(\.json))
}

func makeRatesJSON(_ ratesToUSD: [String: String]) -> Data {
    jsonData(from: ["rates": ratesToUSD])
}

func makeAccessTokenJSON(_ token: String) -> Data {
    jsonData(from: ["access_token": token])
}

func makeServerMessageJSON(_ message: String) -> Data {
    jsonData(from: ["message": message])
}

private func jsonData(from object: Any) -> Data {
    try! JSONSerialization.data(withJSONObject: object)
}
