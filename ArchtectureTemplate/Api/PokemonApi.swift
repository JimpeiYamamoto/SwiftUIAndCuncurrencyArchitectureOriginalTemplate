import Foundation

public protocol PokemonApiType {
    func getPokemonList(
        offset: Int
    ) async throws -> PokemonApiModel.PokemonList
}

public final class PokemonApi: PokemonApiType {
    private let apiClient: ApiClientType

    public init(apiClient: ApiClientType) {
        self.apiClient = apiClient
    }

    // apiClientで発生したエラーを基本的にそのままthrowさせて、decodeも基本全てOptionalで実施
    public func getPokemonList(offset: Int) async throws -> PokemonApiModel.PokemonList {
        // ProgressViewの挙動確認用で1s間Sleepさせる
        sleep(1)
        return try await apiClient.request(url: URL(string: "https://pokeapi.co/api/v2/pokemon?offset=\(offset)")!)
    }
}

public enum PokemonApiModel {
    public struct PokemonList: Decodable {
        let count: Int?
        let next: String?
        let previous: String?
        let results: [PokemonListResult]

        struct PokemonListResult: Decodable {
            let name: String?
            let url: String?
        }
    }
}

extension PokemonApi {
    public static let shared = PokemonApi(apiClient: ApiClient.shared)
}
