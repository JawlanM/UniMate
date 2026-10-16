import Foundation

// Matches the API's CategoryDto. iconName is an SF Symbol name.
struct Category: Identifiable, Hashable, Codable {
    let id: Int
    let name: String
    let iconName: String
}

enum JobStatus: String, Codable {
    case open = "Open"
    case assigned = "Assigned"
    case completed = "Completed"
    case cancelled = "Cancelled"
}

// Matches the API's JobDto.
struct Job: Identifiable, Hashable, Codable {
    let id: UUID
    let clientId: UUID
    let clientName: String
    let categoryId: Int
    let categoryName: String
    let title: String
    let description: String
    let budget: Decimal
    let suburb: String
    let scheduledAt: Date
    let status: JobStatus
    let assignedFreelancerId: UUID?
    let assignedFreelancerName: String?
    let applicationCount: Int
    let createdAt: Date
    let completedAt: Date?
}

enum ApplicationStatus: String, Codable {
    case pending = "Pending"
    case accepted = "Accepted"
    case rejected = "Rejected"
    case withdrawn = "Withdrawn"
}

// Matches the API's ApplicationDto.
struct JobApplication: Identifiable, Hashable, Codable {
    let id: UUID
    let jobId: UUID
    let jobTitle: String
    let jobStatus: JobStatus
    let freelancerId: UUID
    let freelancerName: String
    let message: String
    let status: ApplicationStatus
    let createdAt: Date
}