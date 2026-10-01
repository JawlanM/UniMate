import Foundation

// Raw values match the backend's JSON strings ("Client", "Freelancer", "Admin").
enum UserRole: String, Codable, CaseIterable, Identifiable {
    case client = "Client"
    case freelancer = "Freelancer"
    case admin = "Admin"

    var id: String { rawValue }
}

// Shape of the `user` object in the planned AuthResponse.
struct AppUser: Identifiable, Hashable, Codable {
    let id: UUID
    var email: String
    var firstName: String
    var lastName: String
    var role: UserRole
    var isVerified: Bool

    var fullName: String { "\(firstName) \(lastName)" }
}

struct RegistrationRequest {
    var firstName: String
    var lastName: String
    var email: String
    var password: String
    var role: UserRole
}
