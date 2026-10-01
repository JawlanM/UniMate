import Foundation

enum AuthError: LocalizedError {
    case invalidCredentials
    case emailTaken
    case invalidOrExpiredCode
    case network

    var errorDescription: String? {
        switch self {
        case .invalidCredentials: "Email or password is incorrect."
        case .emailTaken: "An account with this email already exists."
        case .invalidOrExpiredCode: "That code is invalid or has expired."
        case .network: "Can't reach UniMate right now. Check your connection and try again."
        }
    }
}

// The views only know this protocol. Later an `APIAuthService` that calls
// /api/auth/* with URLSession replaces MockAuthService without touching any view.
protocol AuthServicing {
    func signIn(email: String, password: String) async throws -> AppUser
    func register(_ request: RegistrationRequest) async throws -> AppUser
    func requestPasswordReset(email: String) async throws
    func resetPassword(email: String, code: String, newPassword: String) async throws
}

/// Fake backend for UI work.
/// - Any valid email + a password of 8+ characters signs in.
/// - Emails starting with "work" sign in as a Freelancer, everything else as a Client.
/// - "taken@student.monash.edu" is treated as already registered.
/// - The password reset code is always 123456.
struct MockAuthService: AuthServicing {
    static let demoResetCode = "123456"

    func signIn(email: String, password: String) async throws -> AppUser {
        try await Task.sleep(for: .milliseconds(700))
        guard password.count >= 8 else { throw AuthError.invalidCredentials }

        let role: UserRole = email.hasPrefix("work") ? .freelancer : .client
        return AppUser(
            id: UUID(),
            email: email,
            firstName: "Amara",
            lastName: "Okafor",
            role: role,
            isVerified: true
        )
    }

    func register(_ request: RegistrationRequest) async throws -> AppUser {
        try await Task.sleep(for: .milliseconds(900))
        guard request.email != "taken@student.monash.edu" else { throw AuthError.emailTaken }

        return AppUser(
            id: UUID(),
            email: request.email,
            firstName: request.firstName,
            lastName: request.lastName,
            role: request.role,
            isVerified: false
        )
    }

    func requestPasswordReset(email: String) async throws {
        // The real API always answers 202, whether or not the email exists.
        try await Task.sleep(for: .milliseconds(600))
    }

    func resetPassword(email: String, code: String, newPassword: String) async throws {
        try await Task.sleep(for: .milliseconds(600))
        guard code == Self.demoResetCode else { throw AuthError.invalidOrExpiredCode }
    }
}
