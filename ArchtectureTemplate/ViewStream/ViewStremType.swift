import Foundation

public protocol ViewStreamType: ObservableObject {
    associatedtype Output
    associatedtype Input
    associatedtype State

    var output: Output { get set }
    var state: State { get set }
    func action(input: Input) async
}
