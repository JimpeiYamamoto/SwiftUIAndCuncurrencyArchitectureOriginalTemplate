import Foundation

public protocol ApiClientType {
    func request<T: Decodable>(url: URL) async throws -> T
}

public final class ApiClient: ApiClientType {
    public func request<T>(url: URL) async throws -> T where T : Decodable {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")

        let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = urlResponse as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(T.self, from: data)
        return decoded
    }
}

extension ApiClient {
    public static let shared = ApiClient()
}
