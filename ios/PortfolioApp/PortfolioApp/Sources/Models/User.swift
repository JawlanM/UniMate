import Foundation

// Raw values match the backend's JSON strings ("Client", "Freelancer", "Admin").
enum UserRole: String, Codable, CaseIterable, Identifiable {
    case client = "Client"
    case freelancer = "Freelancer"
    case admin = "Admin"

    var id: String { rawValue }
}

// Matches the API's UserDto.
struct AppUser: Identifiable, Hashable, Codable {
    let id: UUID
    var email: String
    var firstName: String
    var lastName: String
    var role: UserRole

    var fullName: String { "\(firstName) \(lastName)" }
}

struct RegistrationRequest: Encodable {
    var firstName: String
    var lastName: String
    var email: String
    var password: String
    var role: UserRole
}
