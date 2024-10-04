import Foundation

public protocol TopViewStreamType: ViewStreamType
where Output == TopViewStreamModel.Output,
      Input == TopViewStreamModel.Input,
      State == TopViewStreamModel.State
{}

public final class TopViewStream: TopViewStreamType {

    private let useCase: TopViewUseCaseType

    @Published public var output = TopViewStreamModel.Output(
        pokemonList: [],
        isPresentLoadingView: false,
        isPresentErrorView: false
    )

    public var state = TopViewStreamModel.State(fetchedPokemonsCount: 0)

    public init(useCase: TopViewUseCaseType) {
        self.useCase = useCase
    }

    @MainActor
    public func action(
        input: TopViewStreamModel.Input
    ) async {
        switch input {
        case .onAppear:
            output.isPresentLoadingView = true
            defer {
                output.isPresentLoadingView = false
            }

            // 非同期処理のみバックグランドスレッドで実行するように指定
            let fetchResult = await Task.detached(priority: .background) {
                await self.useCase.fetchPokemonList(
                    offset: self.state.fetchedPokemonsCount
                )
            }.value

            switch fetchResult {
            case let .success(pokemonList):
                output.isPresentErrorView = false
                output.pokemonList +=  pokemonList
                    .enumerated()
                    .map { offset, pokemon in
                        .init(
                            id: offset + state.fetchedPokemonsCount,
                            name: pokemon.name,
                            url: pokemon.urlText
                        )
                    }
                state.fetchedPokemonsCount = output.pokemonList.count
            case .showErrorView:
                output.isPresentErrorView = true
            }
        }
    }
}

public enum TopViewStreamModel {
    // viewからの得られるイベントを管理するenum
    public enum Input {
        case onAppear
    }

    // Viewへ描画する値を管理するStruct
    public struct Output {
        public var pokemonList: [Pokemon]
        public var isPresentLoadingView: Bool
        public var isPresentErrorView: Bool

        public init(
            pokemonList: [Pokemon],
            isPresentLoadingView: Bool,
            isPresentErrorView: Bool
        ) {
            self.pokemonList = pokemonList
            self.isPresentLoadingView = isPresentLoadingView
            self.isPresentErrorView = isPresentErrorView
        }
    }

   public struct State {
        public var fetchedPokemonsCount: Int

        public init(fetchedPokemonsCount: Int) {
            self.fetchedPokemonsCount = fetchedPokemonsCount
        }
    }
}

extension TopViewStreamModel {
    public struct Pokemon: Identifiable {
        public let id: Int
        let name: String
        let url: String
    }
}

extension TopViewStream {
    public static let shared = TopViewStream(useCase: TopViewUseCase.shared)
}
