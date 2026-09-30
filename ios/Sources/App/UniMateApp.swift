import SwiftUI

@main
struct UniMateApp: App {
    // Swap MockAuthService for the real API client once the backend auth endpoints exist.
    @State private var session = AppSession(auth: MockAuthService())

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(session)
                .tint(Theme.orange)
        }
    }
}
