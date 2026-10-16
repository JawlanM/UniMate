import SwiftUI

@main
struct UniMateApp: App {
    @State private var session = AppSession(auth: APIAuthService())

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(session)
                .tint(UniColor.ember)
        }
    }
}
