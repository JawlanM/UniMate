import SwiftUI

enum HomeRoute: Hashable {
    case recommendations
}

struct HomeView: View {
    @Environment(AppSession.self) private var session
    var onPostJob: () -> Void

    private var user: AppUser? { session.currentUser }
    private var isFreelancer: Bool { user?.role == .freelancer }

    private var greeting: String {
        switch Calendar.current.component(.hour, from: Date()) {
        case 5..<12: "Good morning"
        case 12..<18: "Good afternoon"
        default: "Good evening"
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.xl) {
                header

                VStack(alignment: .leading, spacing: Space.xs) {
                    Text(isFreelancer ? "Let's find your next job" : "Let's find your perfect match")
                        .font(UniFont.largeTitle)
                        .foregroundStyle(UniColor.ink)
                        .accessibilityAddTraits(.isHeader)

                    Button {} label: {
                        Label("Near Clayton campus", systemImage: "location")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(UniColor.ember)
                            .frame(minHeight: 44)
                    }
                    .accessibilityHint(Text("Change location"))
                }

                if isFreelancer {
                    freelancerContent
                } else {
                    clientContent
                }
            }
            .padding(.horizontal, Space.screen)
            .padding(.top, Space.xs)
            .padding(.bottom, Space.xl)
        }
        .refreshable {
            // Pull-to-refresh, as described in P6. Will re-fetch from the API.
            try? await Task.sleep(for: .milliseconds(600))
        }
        .screenBackground()
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(for: HomeRoute.self) { route in
            switch route {
            case .recommendations: RecommendationsView()
            }
        }
        .navigationDestination(for: MatchPreview.self) { match in
            FreelancerProfileView(match: match)
        }
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: Space.sm) {
            AvatarView(name: user?.fullName ?? "UniMate", size: 44)
            VStack(alignment: .leading, spacing: 0) {
                Text(greeting)
                    .font(.footnote)
                    .foregroundStyle(UniColor.inkSecondary)
                Text(user?.firstName ?? "")
                    .font(.headline)
                    .foregroundStyle(UniColor.ink)
            }
            .accessibilityElement(children: .combine)
            Spacer()
            CircleIconButton(systemImage: "bell", accessibilityText: "Notifications, 1 new", showsBadge: true) {}
            CircleIconButton(systemImage: "magnifyingglass", accessibilityText: "Search") {}
        }
    }

    // MARK: Client

    private var clientContent: some View {
        VStack(alignment: .leading, spacing: Space.xl) {
            MatchPanel(jobTitle: MockData.topMatchesJobTitle, when: MockData.topMatchesJobWhen, matches: MockData.topMatches)

            HStack(spacing: Space.sm) {
                QuickTile(title: "Post a job", detail: "\(MockData.activeJobs) active", systemImage: "plus", action: onPostJob)
                QuickTile(title: "Applicants", detail: "\(MockData.applicationCount) to review", systemImage: "tray.full") {}
            }

            VStack(alignment: .leading, spacing: Space.sm) {
                HStack(alignment: .firstTextBaseline) {
                    SectionHeader(title: "Top matches")
                    NavigationLink(value: HomeRoute.recommendations) {
                        Text("See all")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(UniColor.ember)
                            .frame(minHeight: 44)
                    }
                }

                VStack(spacing: 0) {
                    ForEach(Array(MockData.topMatches.prefix(3).enumerated()), id: \.element.id) { index, match in
                        if index > 0 { Divider().overlay(UniColor.hairline).padding(.leading, 72) }
                        NavigationLink(value: match) {
                            MatchRow(match: match)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .raisedSurface(padding: 0)
            }
        }
    }

    // MARK: Freelancer

    private var freelancerContent: some View {
        VStack(alignment: .leading, spacing: Space.xl) {
            if let best = MockData.jobsForYou.first {
                BestJobPanel(job: best)
            }

            HStack(spacing: Space.sm) {
                QuickTile(title: "Jobs nearby", detail: "\(MockData.jobsForYou.count) new today", systemImage: "briefcase") {}
                QuickTile(title: "Offers waiting", detail: "\(MockData.pendingOffers) pending", systemImage: "tray") {}
            }

            VStack(alignment: .leading, spacing: Space.sm) {
                SectionHeader(title: "More jobs for you", actionTitle: "See all") {}

                VStack(spacing: 0) {
                    ForEach(Array(MockData.jobsForYou.dropFirst().enumerated()), id: \.element.id) { index, job in
                        if index > 0 { Divider().overlay(UniColor.hairline).padding(.leading, Space.md) }
                        JobRow(job: job)
                    }
                }
                .raisedSurface(padding: 0)
            }
        }
    }
}

// MARK: - Pieces

/// The one strong element on the client Home: who matches your current job.
private struct MatchPanel: View {
    let jobTitle: String
    let when: String
    let matches: [MatchPreview]

    var body: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            HStack(alignment: .top, spacing: Space.md) {
                VStack(alignment: .leading, spacing: Space.xxs) {
                    Text("Your job")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(UniColor.ember)
                    Text(jobTitle)
                        .font(UniFont.title)
                        .foregroundStyle(UniColor.ink)
                    Label(when, systemImage: "calendar")
                        .font(.subheadline)
                        .foregroundStyle(UniColor.inkSecondary)
                }
                Spacer(minLength: 0)
                if let best = matches.first {
                    ScoreRing(score: best.score, size: 72, label: "best match")
                }
            }

            HStack(spacing: Space.sm) {
                AvatarStack(names: matches.map(\.name), size: 36)
                Text("\(matches.count) students match, best first")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(UniColor.ink)
            }

            Text("Match % is how well a student fits this job: skills, distance, free time and reviews.")
                .font(.footnote)
                .foregroundStyle(UniColor.inkSecondary)
                .fixedSize(horizontal: false, vertical: true)

            NavigationLink(value: HomeRoute.recommendations) {
                Label("See matches", systemImage: "point.3.connected.trianglepath.dotted")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(Space.lg)
        .background {
            // Apricot glow behind the score: the only gradient on Home.
            RoundedRectangle(cornerRadius: Radius.panel, style: .continuous)
                .fill(UniColor.raised)
                .overlay(alignment: .topTrailing) {
                    RadialGradient(colors: [UniColor.apricot.opacity(0.35), .clear], center: .center, startRadius: 0, endRadius: 140)
                        .frame(width: 280, height: 280)
                        .offset(x: 90, y: -110)
                }
                .clipShape(RoundedRectangle(cornerRadius: Radius.panel, style: .continuous))
        }
        .lift()
        .accessibilityElement(children: .contain)
    }
}

private struct BestJobPanel: View {
    let job: JobPreview

    var body: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            HStack(alignment: .top, spacing: Space.md) {
                VStack(alignment: .leading, spacing: Space.xxs) {
                    Text("Best fit for you")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(UniColor.ember)
                    Text(job.title)
                        .font(UniFont.title2)
                        .foregroundStyle(UniColor.ink)
                    Text("From \(job.clientName), \(job.suburb)")
                        .font(.subheadline)
                        .foregroundStyle(UniColor.inkSecondary)
                }
                Spacer(minLength: 0)
                ScoreRing(score: job.score, size: 64)
            }
            FlowLayout(spacing: 6) {
                ForEach(job.reasons, id: \.self) { MatchReasonChip(reason: $0) }
                Chip(text: job.when, systemImage: "calendar")
                Chip(text: "$\(job.hourlyRate)/hr")
            }
        }
        .padding(Space.lg)
        .background(UniColor.raised, in: RoundedRectangle(cornerRadius: Radius.panel, style: .continuous))
        .lift()
        .accessibilityElement(children: .combine)
    }
}

/// Quiet secondary action. Sunken colour so it never competes with the panel.
private struct QuickTile: View {
    let title: String
    let detail: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Space.sm) {
                Image(systemName: systemImage)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(UniColor.ink)
                    .frame(width: 40, height: 40)
                    .background(UniColor.apricot, in: Circle())
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(UniColor.ink)
                        .multilineTextAlignment(.leading)
                    Text(detail)
                        .font(.footnote)
                        .foregroundStyle(UniColor.inkSecondary)
                }
                Spacer(minLength: 0)
            }
            .sunkenSurface(padding: Space.sm)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }
}

struct MatchRow: View {
    let match: MatchPreview

    var body: some View {
        HStack(alignment: .top, spacing: Space.sm) {
            AvatarView(name: match.name, size: 48)
            VStack(alignment: .leading, spacing: 6) {
                Text(match.name)
                    .font(.headline)
                    .foregroundStyle(UniColor.ink)
                HStack(spacing: Space.xs) {
                    RatingBadge(rating: match.rating, reviewCount: match.completedJobs)
                    Text(match.university)
                        .font(.subheadline)
                        .foregroundStyle(UniColor.inkSecondary)
                        .lineLimit(1)
                }
                FlowLayout(spacing: 6) {
                    ForEach(match.reasons.prefix(2), id: \.self) { MatchReasonChip(reason: $0) }
                }
            }
            Spacer(minLength: Space.xs)
            ScoreRing(score: match.score, size: 48)
        }
        .padding(Space.md)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityHint(Text("Opens profile"))
    }
}

private struct JobRow: View {
    let job: JobPreview

    var body: some View {
        HStack(alignment: .top, spacing: Space.sm) {
            VStack(alignment: .leading, spacing: 6) {
                Text(job.title)
                    .font(.headline)
                    .foregroundStyle(UniColor.ink)
                Text("From \(job.clientName), \(job.suburb)")
                    .font(.subheadline)
                    .foregroundStyle(UniColor.inkSecondary)
                FlowLayout(spacing: 6) {
                    ForEach(job.reasons, id: \.self) { MatchReasonChip(reason: $0) }
                    Chip(text: job.when, systemImage: "calendar")
                    Chip(text: "$\(job.hourlyRate)/hr")
                }
            }
            Spacer(minLength: Space.xs)
            ScoreRing(score: job.score, size: 48)
        }
        .padding(Space.md)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Client") {
    NavigationStack { HomeView(onPostJob: {}) }
        .environment(AppSession.preview)
}
