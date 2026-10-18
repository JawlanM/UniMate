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

    func signOut() {
        currentUser = nil
    }
}

extension AppSession {
    /// Signed-in client session for SwiftUI previews.
    static var preview: AppSession { preview(as: .client) }

    /// Signed-in session for SwiftUI previews, as any role.
    static func preview(as role: UserRole) -> AppSession {
        let session = AppSession(auth: MockAuthService())
        session.currentUser = switch role {
        case .client:
            AppUser(id: SampleData.clientId, email: "amara.o@student.monash.edu", firstName: "Amara", lastName: "Okafor", role: .client)
        case .freelancer:
            AppUser(id: SampleData.freelancerId, email: "liam.c@student.monash.edu", firstName: "Liam", lastName: "Chen", role: .freelancer)
        case .admin:
            AppUser(id: UUID(), email: "admin@unimate.app", firstName: "UniMate", lastName: "Admin", role: .admin)
        }
        return session
    }
}
