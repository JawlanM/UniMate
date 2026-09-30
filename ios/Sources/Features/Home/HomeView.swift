import SwiftUI

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
            VStack(alignment: .leading, spacing: 20) {
                header

                HStack(alignment: .top) {
                    Text(isFreelancer ? "Let's find your\nnext job" : "Let's find your\nperfect match")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .foregroundStyle(Theme.ink)
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                    CircleIconButton(systemImage: "mappin.and.ellipse", accessibilityText: "Change location") {}
                }

                if isFreelancer {
                    freelancerContent
                } else {
                    clientContent
                }
            }
            .padding(.horizontal, Theme.screenPadding)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .refreshable {
            // Pull-to-refresh, as described in P6. Will re-fetch from the API.
            try? await Task.sleep(for: .milliseconds(600))
        }
        .screenBackground()
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: 14) {
            AvatarView(name: user?.fullName ?? "UniMate", size: 56)
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting)
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
                Text(user?.fullName ?? "")
                    .font(.headline)
                    .foregroundStyle(Theme.ink)
            }
            .accessibilityElement(children: .combine)
            Spacer()
            CircleIconButton(systemImage: "bell", accessibilityText: "Notifications", showsBadge: true) {}
            CircleIconButton(systemImage: "magnifyingglass", accessibilityText: "Search") {}
        }
    }

    // MARK: Client

    private var clientContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 14) {
                ActionTile(
                    tag: "Find",
                    title: "Helpers nearby",
                    subtitle: "\(MockData.helpersOnline) online now",
                    systemImage: "person.2",
                    background: Theme.orangeGradient
                ) {}

                ActionTile(
                    tag: "Post",
                    title: "A new job",
                    subtitle: "\(MockData.activeJobs) active",
                    systemImage: "plus",
                    background: Theme.softOrangeGradient,
                    action: onPostJob
                )
            }

            ManageCard(
                title: "Jobs & applicants",
                subtitle: "\(MockData.activeJobs) jobs · \(MockData.applicationCount) applications"
            ) {}

            SectionHeader(title: "Top matches · \(MockData.topMatchesJobTitle)")

            ForEach(MockData.topMatches) { match in
                MatchRow(match: match)
            }
        }
    }

    // MARK: Freelancer

    private var freelancerContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 14) {
                ActionTile(
                    tag: "Browse",
                    title: "Jobs nearby",
                    subtitle: "\(MockData.jobsForYou.count) new today",
                    systemImage: "briefcase",
                    background: Theme.orangeGradient
                ) {}

                ActionTile(
                    tag: "Offers",
                    title: "Waiting for you",
                    subtitle: "\(MockData.pendingOffers) pending",
                    systemImage: "tray",
                    background: Theme.softOrangeGradient
                ) {}
            }

            SectionHeader(title: "Best jobs for you")

            ForEach(MockData.jobsForYou) { job in
                JobRow(job: job)
            }
        }
    }
}

// MARK: - Pieces

private struct SectionHeader: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(Theme.ink)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            Button("See all") {}
                .font(.subheadline)
                .foregroundStyle(Theme.muted)
                .frame(minHeight: 44)
        }
        .padding(.top, 8)
    }
}

private struct ActionTile<Background: ShapeStyle>: View {
    let tag: String
    let title: String
    let subtitle: String
    let systemImage: String
    let background: Background
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    Text(tag)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Theme.ink, in: Capsule())
                    Spacer()
                    Image(systemName: systemImage)
                        .font(.headline)
                        .foregroundStyle(Theme.ink)
                        .frame(width: 40, height: 40)
                        .background(.white.opacity(0.35), in: Circle())
                }
                Spacer(minLength: 24)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.leading)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Theme.ink.opacity(0.7))
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 150, alignment: .leading)
            .background(background, in: RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))
            .shadow(color: Theme.orange.opacity(0.2), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }
}

private struct ManageCard: View {
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Manage")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Theme.ink, in: Capsule())
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Theme.ink)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Theme.muted)
                }
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(Theme.orange, in: Circle())
                    .accessibilityHidden(true)
            }
            .card()
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }
}

private struct MatchRow: View {
    let match: MatchPreview

    var body: some View {
        HStack(spacing: 14) {
            AvatarView(name: match.name, size: 56)
            VStack(alignment: .leading, spacing: 6) {
                Text(match.name)
                    .font(.headline)
                    .foregroundStyle(Theme.ink)
                Text("\(match.university) · \(match.distanceKm, specifier: "%.1f") km away")
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
                FlowLayout(spacing: 6) {
                    Chip(text: match.category, style: .orange)
                    Chip(text: match.availability, style: .green)
                    if let rating = match.rating {
                        Chip(text: String(format: "%.1f★", rating), style: .blue)
                    }
                }
            }
            Spacer(minLength: 8)
            ScoreRing(score: match.score)
        }
        .card(padding: 16)
        .accessibilityElement(children: .combine)
    }
}

private struct JobRow: View {
    let job: JobPreview

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text(job.title)
                    .font(.headline)
                    .foregroundStyle(Theme.ink)
                Text("from \(job.clientName) · \(job.suburb)")
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
                FlowLayout(spacing: 6) {
                    Chip(text: job.when, systemImage: "calendar", style: .blue)
                    Chip(text: "$\(job.hourlyRate)/hr", style: .green)
                }
            }
            Spacer(minLength: 8)
            ScoreRing(score: job.score)
        }
        .card(padding: 16)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Client") {
    NavigationStack { HomeView(onPostJob: {}) }
        .environment(AppSession.preview)
}
