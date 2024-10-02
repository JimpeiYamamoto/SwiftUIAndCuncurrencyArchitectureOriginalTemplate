import Foundation

public final class TopViewStream: ObservableObject {

    private let useCase: TopViewUseCaseType

    @Published var outerState = TopViewStreamModel.State.Outer(
        pokemonList: [],
        isPresentLoadingView: false,
        isPresentErrorView: false
    )

    var innerState = TopViewStreamModel.State.Inner(fetchedPokemonsCount: 0)

    public init(useCase: TopViewUseCaseType) {
        self.useCase = useCase
    }

    @MainActor
    public func action(
        input: TopViewStreamModel.Input
    ) async {
        switch input {
        case .onAppear:
            outerState.isPresentLoadingView = true
            defer {
                outerState.isPresentLoadingView = false
            }

            // 非同期処理のみバックグランドスレッドで実行するように指定
            let fetchResult = await Task.detached(priority: .background) {
                await self.useCase.fetchPokemonList(
                    offset: self.innerState.fetchedPokemonsCount
                )
            }.value

            switch fetchResult {
            case let .success(pokemonList):
                outerState.isPresentErrorView = false
                outerState.pokemonList +=  pokemonList
                    .enumerated()
                    .map { offset, pokemon in
                        .init(
                            id: offset + innerState.fetchedPokemonsCount,
                            name: pokemon.name,
                            url: pokemon.urlText
                        )
                    }
                innerState.fetchedPokemonsCount = outerState.pokemonList.count
            case .showErrorView:
                outerState.isPresentErrorView = true
            }
        }
    }
}

public enum TopViewStreamModel {
    // viewからの得られるイベントを管理するenum
    public enum Input {
        case onAppear
    }

    // Viewで利用する値はOuterに定義
    // ViewSream内でしか参照しない値はInnerに定義
    public enum State {
        public struct Outer {
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

        public struct Inner {
            var fetchedPokemonsCount: Int

            init(fetchedPokemonsCount: Int) {
                self.fetchedPokemonsCount = fetchedPokemonsCount
            }
        }
    }
}

extension TopViewStreamModel.State {
    public struct Pokemon: Identifiable {
        public let id: Int
        let name: String
        let url: String
    }
}

extension TopViewStream {
    public static let shared = TopViewStream(useCase: TopViewUseCase.shared)
}
