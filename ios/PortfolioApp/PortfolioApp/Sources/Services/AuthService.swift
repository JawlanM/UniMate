import Foundation

enum AuthError: LocalizedError {
    case invalidCredentials
    case emailTaken
    case network

    var errorDescription: String? {
        switch self {
        case .invalidCredentials: "Email or password is incorrect."
        case .emailTaken: "An account with this email already exists."
        case .network: "Can't reach UniMate right now. Check your connection and try again."
        }
    }
}

// The views only know this protocol, so the real and mock services are interchangeable.
protocol AuthServicing {
    func signIn(email: String, password: String) async throws -> AppUser
    func register(_ request: RegistrationRequest) async throws -> AppUser
}

/// Real auth: calls /api/auth on the hosted API.
struct APIAuthService: AuthServicing {
    private let api = APIClient.shared

    private struct LoginBody: Encodable {
        let email: String
        let password: String
    }

    func signIn(email: String, password: String) async throws -> AppUser {
        try await api.send("POST", "/api/auth/login", body: LoginBody(email: email, password: password))
    }

    func register(_ request: RegistrationRequest) async throws -> AppUser {
        try await api.send("POST", "/api/auth/register", body: request)
    }
}

/// Fake auth for SwiftUI previews only (no network).
struct MockAuthService: AuthServicing {
    func signIn(email: String, password: String) async throws -> AppUser {
        guard password.count >= 8 else { throw AuthError.invalidCredentials }
        return AppUser(id: UUID(), email: email, firstName: "Amara", lastName: "Okafor", role: .client)
    }

    func register(_ request: RegistrationRequest) async throws -> AppUser {
        AppUser(id: UUID(), email: request.email, firstName: request.firstName,
                lastName: request.lastName, role: request.role)
    }
}