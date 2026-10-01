import Foundation
import Observation

/// Holds who is signed in. RootView switches between the auth flow and the
/// main tabs by watching `currentUser`.
@MainActor
@Observable
final class AppSession {
    private(set) var currentUser: AppUser?
    private let auth: any AuthServicing

    init(auth: any AuthServicing) {
        self.auth = auth
    }

    var isSignedIn: Bool { currentUser != nil }

    func signIn(email: String, password: String) async throws {
        currentUser = try await auth.signIn(email: email.trimmed.lowercased(), password: password)
    }

    func register(_ request: RegistrationRequest) async throws {
        var cleaned = request
        cleaned.email = request.email.trimmed.lowercased()
        cleaned.firstName = request.firstName.trimmed
        cleaned.lastName = request.lastName.trimmed
        currentUser = try await auth.register(cleaned)
    }

    func requestPasswordReset(email: String) async throws {
        try await auth.requestPasswordReset(email: email.trimmed.lowercased())
    }

    func resetPassword(email: String, code: String, newPassword: String) async throws {
        try await auth.resetPassword(email: email.trimmed.lowercased(), code: code, newPassword: newPassword)
    }

    func signOut() {
        currentUser = nil
    }
}

extension AppSession {
    /// Signed-in session for SwiftUI previews.
    static var preview: AppSession {
        let session = AppSession(auth: MockAuthService())
        session.currentUser = AppUser(
            id: UUID(),
            email: "amara.o@student.monash.edu",
            firstName: "Amara",
            lastName: "Okafor",
            role: .client,
            isVerified: true
        )
        return session
    }
}
