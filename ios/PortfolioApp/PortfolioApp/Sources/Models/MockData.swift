import Foundation

// Temporary data until the jobs/matches endpoints exist. Shapes follow the
// planned GET /api/jobs/{id}/matches response (score, breakdown, reasons).

/// A short, human reason someone matches ("1.4 km away").
struct MatchReason: Hashable {
    let text: String
    let systemImage: String
    /// Strong reasons get the brand tint so they stand out from plain facts.
    var isStrong = false
}

/// One line of the score breakdown. Points add up to the total score.
struct MatchFactor: Hashable, Identifiable {
    var id: String { name }
    let name: String
    let detail: String
    let systemImage: String
    let points: Int
    let maxPoints: Int
}

/// A tag from the Rate Job screen and how many clients picked it.
struct Praise: Hashable, Identifiable {
    var id: String { label }
    let label: String
    let count: Int
}

struct MatchPreview: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let university: String
    let course: String
    let distanceKm: Double
    let rating: Double?
    let completedJobs: Int
    let hourlyRate: Int
    let score: Int
    let reasons: [MatchReason]
    let breakdown: [MatchFactor]
    let skills: [String]
    let languages: [String]
    let bio: String
    var praise: [Praise] = []
}

struct JobPreview: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let clientName: String
    let suburb: String
    let when: String
    let hourlyRate: Int
    let score: Int
    let reasons: [MatchReason]
}

enum MockData {
    static let topMatchesJobTitle = "Moving boxes"
    static let topMatchesJobWhen = "Sat 10 Oct, 9am"

    static let topMatches: [MatchPreview] = [
        MatchPreview(
            name: "Liam Chen", university: "Monash Clayton", course: "Engineering",
            distanceKm: 1.4, rating: 4.8, completedJobs: 18, hourlyRate: 32, score: 97,
            reasons: [
                MatchReason(text: "Moved 7 flats", systemImage: "shippingbox", isStrong: true),
                MatchReason(text: "1.4 km away", systemImage: "location", isStrong: true),
                MatchReason(text: "Free Saturdays", systemImage: "calendar")
            ],
            breakdown: [
                MatchFactor(name: "Category", detail: "Moving", systemImage: "shippingbox", points: 30, maxPoints: 30),
                MatchFactor(name: "Distance", detail: "1.4 km", systemImage: "location", points: 23, maxPoints: 25),
                MatchFactor(name: "Availability", detail: "Free Saturdays", systemImage: "calendar", points: 15, maxPoints: 15),
                MatchFactor(name: "Rating", detail: "4.8 from 18 jobs", systemImage: "star", points: 11, maxPoints: 12),
                MatchFactor(name: "Language", detail: "Not required", systemImage: "character.bubble", points: 10, maxPoints: 10),
                MatchFactor(name: "Experience", detail: "7 moves done", systemImage: "checkmark.seal", points: 8, maxPoints: 8)
            ],
            skills: ["Lifting", "Packing", "Has a car"],
            languages: ["English", "Mandarin"],
            bio: "Second-year engineering student. I have a hatchback and a trolley, and I've helped seven people move flats around Clayton and Caulfield.",
            praise: [Praise(label: "On time", count: 16), Praise(label: "Careful with items", count: 12), Praise(label: "Friendly", count: 9)]
        ),
        MatchPreview(
            name: "Priya Sharma", university: "Monash Clayton", course: "Pharmacy",
            distanceKm: 2.8, rating: 4.9, completedJobs: 11, hourlyRate: 28, score: 88,
            reasons: [
                MatchReason(text: "Packs fragile items", systemImage: "shippingbox", isStrong: true),
                MatchReason(text: "2.8 km away", systemImage: "location"),
                MatchReason(text: "Free Saturdays", systemImage: "calendar")
            ],
            breakdown: [
                MatchFactor(name: "Category", detail: "Moving", systemImage: "shippingbox", points: 30, maxPoints: 30),
                MatchFactor(name: "Distance", detail: "2.8 km", systemImage: "location", points: 17, maxPoints: 25),
                MatchFactor(name: "Availability", detail: "Free Saturdays", systemImage: "calendar", points: 15, maxPoints: 15),
                MatchFactor(name: "Rating", detail: "4.9 from 11 jobs", systemImage: "star", points: 11, maxPoints: 12),
                MatchFactor(name: "Language", detail: "Not required", systemImage: "character.bubble", points: 10, maxPoints: 10),
                MatchFactor(name: "Experience", detail: "3 moves done", systemImage: "checkmark.seal", points: 5, maxPoints: 8)
            ],
            skills: ["Packing", "Furniture assembly"],
            languages: ["English", "Hindi"],
            bio: "Pharmacy student, careful with fragile things. Happy to help with packing and assembling flat-pack furniture.",
            praise: [Praise(label: "Careful with items", count: 10), Praise(label: "Good communication", count: 7)]
        ),
        MatchPreview(
            name: "Daniel Park", university: "Monash Caulfield", course: "Business",
            distanceKm: 0.9, rating: 4.5, completedJobs: 6, hourlyRate: 26, score: 81,
            reasons: [
                MatchReason(text: "0.9 km away", systemImage: "location", isStrong: true),
                MatchReason(text: "Free Sundays only", systemImage: "calendar")
            ],
            breakdown: [
                MatchFactor(name: "Category", detail: "Moving", systemImage: "shippingbox", points: 30, maxPoints: 30),
                MatchFactor(name: "Distance", detail: "0.9 km", systemImage: "location", points: 24, maxPoints: 25),
                MatchFactor(name: "Availability", detail: "Free Sundays only", systemImage: "calendar", points: 4, maxPoints: 15),
                MatchFactor(name: "Rating", detail: "4.5 from 6 jobs", systemImage: "star", points: 10, maxPoints: 12),
                MatchFactor(name: "Language", detail: "Not required", systemImage: "character.bubble", points: 10, maxPoints: 10),
                MatchFactor(name: "Experience", detail: "2 moves done", systemImage: "checkmark.seal", points: 3, maxPoints: 8)
            ],
            skills: ["Lifting", "Has a ute"],
            languages: ["English", "Korean"],
            bio: "I live next to Caulfield campus and have a ute on weekends.",
            praise: [Praise(label: "On time", count: 4)]
        ),
        MatchPreview(
            name: "Sofia Nguyen", university: "RMIT City", course: "Design",
            distanceKm: 5.6, rating: nil, completedJobs: 0, hourlyRate: 24, score: 80,
            reasons: [
                MatchReason(text: "Free Saturdays", systemImage: "calendar", isStrong: true),
                MatchReason(text: "New to UniMate", systemImage: "sparkle")
            ],
            breakdown: [
                MatchFactor(name: "Category", detail: "Moving", systemImage: "shippingbox", points: 30, maxPoints: 30),
                MatchFactor(name: "Distance", detail: "5.6 km", systemImage: "location", points: 18, maxPoints: 25),
                MatchFactor(name: "Availability", detail: "Free Saturdays", systemImage: "calendar", points: 15, maxPoints: 15),
                MatchFactor(name: "Rating", detail: "No reviews yet", systemImage: "star", points: 7, maxPoints: 12),
                MatchFactor(name: "Language", detail: "Not required", systemImage: "character.bubble", points: 10, maxPoints: 10),
                MatchFactor(name: "Experience", detail: "First job", systemImage: "checkmark.seal", points: 0, maxPoints: 8)
            ],
            skills: ["Packing"],
            languages: ["English", "Vietnamese"],
            bio: "Design student, new to UniMate. Free most Saturday mornings.",
            praise: []
        )
    ]

    static let jobsForYou: [JobPreview] = [
        JobPreview(title: "Moving boxes, Caulfield to Clayton", clientName: "Amara Okafor", suburb: "Caulfield", when: "Sat 10 Oct, 9am", hourlyRate: 30, score: 88,
                   reasons: [MatchReason(text: "You've done 7 moves", systemImage: "shippingbox", isStrong: true), MatchReason(text: "2.1 km away", systemImage: "location")]),
        JobPreview(title: "Year 11 maths tutoring", clientName: "Jess Kim", suburb: "Clayton", when: "Tue 5pm", hourlyRate: 35, score: 81,
                   reasons: [MatchReason(text: "Maths skill", systemImage: "function", isStrong: true), MatchReason(text: "Free Tue evening", systemImage: "calendar")]),
        JobPreview(title: "Grocery run", clientName: "Tom Reid", suburb: "Oakleigh", when: "Thu 4pm", hourlyRate: 25, score: 64,
                   reasons: [MatchReason(text: "3.9 km away", systemImage: "location")])
    ]

    static let helpersOnline = 38
    static let activeJobs = 2
    static let applicationCount = 7
    static let pendingOffers = 3
}
