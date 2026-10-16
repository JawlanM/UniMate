import Foundation

enum ReportReason: String, Codable, CaseIterable, Identifiable {
    case harassment = "Harassment"
    case scam = "Scam"
    case inappropriate = "Inappropriate"
    case noShow = "NoShow"
    case safety = "Safety"
    case other = "Other"

    var id: String { rawValue }
}

enum ReportStatus: String, Codable {
    case open = "Open"
    case underReview = "UnderReview"
    case resolved = "Resolved"
    case dismissed = "Dismissed"
}

// Matches the API's ReportDto.
struct Report: Identifiable, Hashable, Codable {
    let id: UUID
    let reporterId: UUID
    let reporterName: String
    let jobId: UUID
    let jobTitle: String
    let reason: ReportReason
    let details: String
    let status: ReportStatus
    let createdAt: Date
}