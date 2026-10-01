import SwiftUI

struct RootView: View {
    @Environment(AppSession.self) private var session

    var body: some View {
        Group {
            if session.isSignedIn {
                MainTabView()
                    .transition(.opacity)
            } else {
                AuthFlowView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: session.isSignedIn)
    }
}

enum AuthRoute: Hashable {
    case signIn
    case register
    case forgotPassword
}

/// Welcome → Sign in / Create account / Forgot password.
struct AuthFlowView: View {
    var body: some View {
        NavigationStack {
            WelcomeView()
                .navigationDestination(for: AuthRoute.self) { route in
                    switch route {
                    case .signIn: SignInView()
                    case .register: RegisterView()
                    case .forgotPassword: ForgotPasswordView()
                    }
                }
        }
    }
}

#Preview("Signed out") {
    RootView()
        .environment(AppSession(auth: MockAuthService()))
}

#Preview("Signed in") {
    RootView()
        .environment(AppSession.preview)
}
