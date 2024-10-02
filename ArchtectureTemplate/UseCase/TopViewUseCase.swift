import Foundation

public protocol TopViewUseCaseType {
    func fetchPokemonList(offset: Int) async -> TopViewUseCaseModel.FetchResult
}

public final class TopViewUseCase: TopViewUseCaseType {
    // 必要に応じてデータ永続化に利用するRepositoryなども保持する
    private let pokemonApiGateway: PokemonApiGatewayType

    public init(pokemonApiGateway: PokemonApiGatewayType) {
        self.pokemonApiGateway = pokemonApiGateway
    }

    public func fetchPokemonList(offset: Int) async -> TopViewUseCaseModel.FetchResult {
        do {
            let pokemonList = try await pokemonApiGateway.getPokemonList(offset: offset)
            return .success(pokemonList.results.map { .init(name: $0.name, urlText: $0.url) })
        } catch {
            return .showErrorView
        }
    }
}

public enum TopViewUseCaseModel {
    public enum FetchResult {
        case success([Pokemon])
        case showErrorView

        public struct Pokemon: Equatable {
            let name: String
            let urlText: String
        }
    }
}

extension TopViewUseCase {
    public static let shared = TopViewUseCase(pokemonApiGateway: PokemonApiGateway.shared)
}
