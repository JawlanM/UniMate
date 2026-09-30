import Foundation

// Temporary data for the home screen until the jobs/matches endpoints exist.

struct MatchPreview: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let university: String
    let distanceKm: Double
    let category: String
    let availability: String
    let rating: Double?
    let score: Int
}

struct JobPreview: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let clientName: String
    let suburb: String
    let when: String
    let hourlyRate: Int
    let score: Int
}

enum MockData {
    static let topMatchesJobTitle = "Moving boxes"

    static let topMatches: [MatchPreview] = [
        MatchPreview(name: "Liam Chen", university: "Monash", distanceKm: 1.4, category: "Moving", availability: "Sat 9am", rating: 4.8, score: 92),
        MatchPreview(name: "Priya Sharma", university: "Monash", distanceKm: 2.8, category: "Moving", availability: "Sat 9am", rating: nil, score: 86)
    ]

    static let jobsForYou: [JobPreview] = [
        JobPreview(title: "Moving boxes, Caulfield → Clayton", clientName: "Amara Okafor", suburb: "Caulfield", when: "Sat 4 Oct, 9am", hourlyRate: 30, score: 88),
        JobPreview(title: "Year 11 maths tutoring", clientName: "Jess Kim", suburb: "Clayton", when: "Tue 5pm", hourlyRate: 35, score: 81),
        JobPreview(title: "Grocery run", clientName: "Tom Reid", suburb: "Oakleigh", when: "Thu 4pm", hourlyRate: 25, score: 64)
    ]

    static let helpersOnline = 38
    static let activeJobs = 2
    static let applicationCount = 7
    static let pendingOffers = 3
}
