import Foundation

public protocol PokemonApiGatewayType {
    func getPokemonList(offset: Int) async throws -> PokemonApiGatewayModel.PokemonList
}

public final class PokemonApiGateway: PokemonApiGatewayType {

    private let api: PokemonApiType

    public init(api: PokemonApiType) {
        self.api = api
    }

    public func getPokemonList(offset: Int) async throws -> PokemonApiGatewayModel.PokemonList {
        let pokemonList = try await api.getPokemonList(offset: offset)
        // 必須パラメータが無いなど、アプリ特有のエラーを返す
        if pokemonList.results.isEmpty {
            throw PokemonApiGatewayModel.PokemonApiGatewayError.requiredPropertyNotFound
        }
        // ここで、アプリ側で欲しいレスポンス方へフォールバック(useCaseへは綺麗なデータかerrorのthrowかどちらかになるように)
        return .init(
            count:  pokemonList.count ?? 0,
            next: pokemonList.next ?? "",
            previous: pokemonList.previous ?? "",
            results: pokemonList.results.map { result in
                .init(name: result.name ?? "", url: result.url ?? "")
            }
        )
    }
}

public enum PokemonApiGatewayModel {
    public struct PokemonList: Decodable {
        let count: Int
        let next: String
        let previous: String
        let results: [PokemonListResult]

        struct PokemonListResult: Decodable {
            let name: String
            let url: String
        }
    }

    public enum PokemonApiGatewayError: Error {
        case requiredPropertyNotFound
    }
}

extension PokemonApiGateway {
    public static let shared = PokemonApiGateway(api: PokemonApi.shared)
}
