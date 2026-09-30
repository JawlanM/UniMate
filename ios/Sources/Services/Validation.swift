import Foundation

// Same rules as the backend plan, so users see errors before a network call.
enum Validation {
    static func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[^@\s]+@[^@\s]+\.[^@\s]+$"#
        return email.trimmed.range(of: pattern, options: .regularExpression) != nil
    }

    /// Returns a user-facing problem, or nil when the password is acceptable.
    static func passwordProblem(_ password: String) -> String? {
        if password.count < 8 {
            return "Use at least 8 characters."
        }
        if !password.contains(where: \.isLetter) || !password.contains(where: \.isNumber) {
            return "Use at least one letter and one number."
        }
        return nil
    }

    static func isValidResetCode(_ code: String) -> Bool {
        code.count == 6 && code.allSatisfy(\.isNumber)
    }
}

extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
