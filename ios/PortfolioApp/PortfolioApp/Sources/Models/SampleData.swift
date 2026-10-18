import Foundation

// Hard-coded data so every screen has something to show before it's wired to
// the API. It uses the real models, so a screen only has to swap
// `SampleData.x` for the API result.
// TODO: delete this file once every screen loads from APIClient.
enum SampleData {
    /// "Me" in the samples: Amara is the client, Liam is the freelancer.
    static let clientId = UUID()
    static let freelancerId = UUID()

    private static let otherClientId = UUID()
    private static let priyaId = UUID()
    private static let sofiaId = UUID()
    private static let jessId = UUID()

    private static let couchJobId = UUID()
    private static let tutoringJobId = UUID()
    private static let printerJobId = UUID()
    private static let dogJobId = UUID()
    private static let cleanJobId = UUID()
    private static let groceriesJobId = UUID()

    private static func daysFromNow(_ days: Double) -> Date {
        Date.now.addingTimeInterval(days * 24 * 60 * 60)
    }

    // Same ids, names and icons as the categories the API seeds.
    static let categories: [Category] = [
        Category(id: 1, name: "Moving & lifting", iconName: "shippingbox"),
        Category(id: 2, name: "Tutoring", iconName: "book"),
        Category(id: 3, name: "Cleaning", iconName: "sparkles"),
        Category(id: 4, name: "Tech help", iconName: "laptopcomputer"),
        Category(id: 5, name: "Pet care", iconName: "pawprint"),
        Category(id: 6, name: "Errands & delivery", iconName: "bicycle")
    ]

    static let jobs: [Job] = [
        Job(id: couchJobId, clientId: clientId, clientName: "Amara Okafor", categoryId: 1, categoryName: "Moving & lifting",
            title: "Help moving a couch to my new flat",
            description: "Two-seater couch from a ground-floor unit to a first-floor flat, about 2 km apart. I have a ute, I just need a second pair of hands. Should take about an hour.",
            budget: 60, suburb: "Clayton", scheduledAt: daysFromNow(2), status: .open,
            assignedFreelancerId: nil, assignedFreelancerName: nil, applicationCount: 3,
            createdAt: daysFromNow(-1), completedAt: nil),
        Job(id: tutoringJobId, clientId: clientId, clientName: "Amara Okafor", categoryId: 2, categoryName: "Tutoring",
            title: "VCE Methods tutoring, two sessions",
            description: "My younger brother needs help with calculus before his SAC. Two one-hour sessions at our place or the Oakleigh library.",
            budget: 90, suburb: "Oakleigh", scheduledAt: daysFromNow(4), status: .open,
            assignedFreelancerId: nil, assignedFreelancerName: nil, applicationCount: 1,
            createdAt: daysFromNow(-2), completedAt: nil),
        Job(id: printerJobId, clientId: clientId, clientName: "Amara Okafor", categoryId: 4, categoryName: "Tech help",
            title: "Set up a new printer and Wi-Fi",
            description: "New wireless printer needs connecting to two laptops and the home Wi-Fi.",
            budget: 40, suburb: "Mount Waverley", scheduledAt: daysFromNow(1), status: .assigned,
            assignedFreelancerId: freelancerId, assignedFreelancerName: "Liam Chen", applicationCount: 2,
            createdAt: daysFromNow(-3), completedAt: nil),
        Job(id: cleanJobId, clientId: clientId, clientName: "Amara Okafor", categoryId: 3, categoryName: "Cleaning",
            title: "End-of-lease clean, one bedroom",
            description: "Kitchen, bathroom, floors and windows before the final inspection.",
            budget: 150, suburb: "Caulfield", scheduledAt: daysFromNow(-10), status: .completed,
            assignedFreelancerId: priyaId, assignedFreelancerName: "Priya Sharma", applicationCount: 2,
            createdAt: daysFromNow(-14), completedAt: daysFromNow(-10)),
        Job(id: dogJobId, clientId: otherClientId, clientName: "Daniel Park", categoryId: 5, categoryName: "Pet care",
            title: "Walk my dog on Saturday morning",
            description: "Friendly border collie, about 45 minutes around Jells Park. Lead and bags provided.",
            budget: 30, suburb: "Glen Waverley", scheduledAt: daysFromNow(5), status: .open,
            assignedFreelancerId: nil, assignedFreelancerName: nil, applicationCount: 0,
            createdAt: daysFromNow(-0.2), completedAt: nil),
        Job(id: groceriesJobId, clientId: otherClientId, clientName: "Daniel Park", categoryId: 6, categoryName: "Errands & delivery",
            title: "Pick up groceries from Chadstone",
            description: "A click-and-collect order, about 6 bags, dropped at my door.",
            budget: 25, suburb: "Carnegie", scheduledAt: daysFromNow(3), status: .open,
            assignedFreelancerId: nil, assignedFreelancerName: nil, applicationCount: 1,
            createdAt: daysFromNow(-0.5), completedAt: nil)
    ]

    static let applications: [JobApplication] = [
        JobApplication(id: UUID(), jobId: couchJobId, jobTitle: "Help moving a couch to my new flat", jobStatus: .open,
                       freelancerId: freelancerId, freelancerName: "Liam Chen",
                       message: "Hi Amara, I'm free that afternoon and I've helped friends move a few times. Happy to help carry.",
                       status: .pending, createdAt: daysFromNow(-0.8)),
        JobApplication(id: UUID(), jobId: couchJobId, jobTitle: "Help moving a couch to my new flat", jobStatus: .open,
                       freelancerId: priyaId, freelancerName: "Priya Sharma",
                       message: "I live in Clayton so I can be there quickly. I can also bring straps.",
                       status: .pending, createdAt: daysFromNow(-0.6)),
        JobApplication(id: UUID(), jobId: couchJobId, jobTitle: "Help moving a couch to my new flat", jobStatus: .open,
                       freelancerId: sofiaId, freelancerName: "Sofia Nguyen",
                       message: "Available after 2 pm. I go to the gym a lot, so lifting is fine!",
                       status: .pending, createdAt: daysFromNow(-0.3)),
        JobApplication(id: UUID(), jobId: tutoringJobId, jobTitle: "VCE Methods tutoring, two sessions", jobStatus: .open,
                       freelancerId: freelancerId, freelancerName: "Liam Chen",
                       message: "I got 45 in Methods and tutor two Year 12s already. Happy to go to the library.",
                       status: .pending, createdAt: daysFromNow(-1)),
        JobApplication(id: UUID(), jobId: printerJobId, jobTitle: "Set up a new printer and Wi-Fi", jobStatus: .assigned,
                       freelancerId: freelancerId, freelancerName: "Liam Chen",
                       message: "IT student here, I set up printers at my part-time job all the time.",
                       status: .accepted, createdAt: daysFromNow(-2.5)),
        JobApplication(id: UUID(), jobId: printerJobId, jobTitle: "Set up a new printer and Wi-Fi", jobStatus: .assigned,
                       freelancerId: jessId, freelancerName: "Jess Kim",
                       message: "I can do this on the weekend.",
                       status: .rejected, createdAt: daysFromNow(-2.4)),
        JobApplication(id: UUID(), jobId: groceriesJobId, jobTitle: "Pick up groceries from Chadstone", jobStatus: .open,
                       freelancerId: freelancerId, freelancerName: "Liam Chen",
                       message: "I'm at Chadstone most Thursdays.",
                       status: .withdrawn, createdAt: daysFromNow(-0.4))
    ]

    static let reports: [Report] = [
        Report(id: UUID(), reporterId: freelancerId, reporterName: "Liam Chen", jobId: groceriesJobId,
               jobTitle: "Pick up groceries from Chadstone", reason: .scam,
               details: "The client asked me to pay for the groceries upfront by bank transfer and said they'd pay me back later.",
               status: .open, createdAt: daysFromNow(-0.1)),
        Report(id: UUID(), reporterId: clientId, reporterName: "Amara Okafor", jobId: printerJobId,
               jobTitle: "Set up a new printer and Wi-Fi", reason: .noShow,
               details: "Nobody came at the agreed time and I couldn't reach them for an hour.",
               status: .underReview, createdAt: daysFromNow(-1)),
        Report(id: UUID(), reporterId: priyaId, reporterName: "Priya Sharma", jobId: dogJobId,
               jobTitle: "Walk my dog on Saturday morning", reason: .other,
               details: "Duplicate post, the same job was listed twice.",
               status: .resolved, createdAt: daysFromNow(-6))
    ]

    // MARK: Lookups the screens use

    /// Jobs the sample client posted (My Jobs).
    static var myJobs: [Job] { jobs.filter { $0.clientId == clientId } }

    /// Open jobs a freelancer can apply for (Browse).
    static var openJobs: [Job] { jobs.filter { $0.status == .open } }

    /// Applications the sample freelancer sent (My Work).
    static var myApplications: [JobApplication] { applications.filter { $0.freelancerId == freelancerId } }

    static func job(id: UUID) -> Job? {
        jobs.first { $0.id == id }
    }

    static func applications(for jobId: UUID) -> [JobApplication] {
        applications.filter { $0.jobId == jobId }
    }
}
