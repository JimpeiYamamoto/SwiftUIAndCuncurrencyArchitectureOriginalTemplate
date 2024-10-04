import SwiftUI

@main
struct ArchtectureTemplateApp: App {
    var body: some Scene {
        WindowGroup {
            TopListView(viewStream: TopViewStream.shared)
        }
    }
}
