import SwiftUI

struct TopListView: View {
    // ここのPresenterへの依存を上手く剥がせなかった〜〜
    @StateObject var viewStream = TopViewStream(useCase: TopViewUseCase.shared)

    var body: some View {
        VStack {
            if viewStream.outerState.isPresentLoadingView {
                ProgressView("読み込み中")
            } else {
                if viewStream.outerState.isPresentErrorView {
                    Text("エラーです")
                } else {
                    List {
                        ForEach(viewStream.outerState.pokemonList) { pokemon in
                            Text("\(pokemon.name): \(pokemon.url)")
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewStream.action(input: .onAppear)
            }
        }
    }
}

#Preview {
    TopListView()
}
