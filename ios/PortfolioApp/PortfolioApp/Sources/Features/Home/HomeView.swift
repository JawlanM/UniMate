import SwiftUI

/// First tab for clients and freelancers: a greeting, the one job that matters
/// most right now, shortcuts, and a few recent jobs.
struct HomeView: View {
    @Environment(AppSession.self) private var session
    var onPostJob: () -> Void
    var onSelectTab: (MainTab) -> Void

    // TODO: fill these from the API in load().
    @State private var myJobs: [Job] = SampleData.myJobs
    @State private var openJobs: [Job] = SampleData.openJobs
    @State private var myApplications: [JobApplication] = SampleData.myApplications

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

                Text(isFreelancer ? "Let's find your next job" : "What do you need done?")
                    .font(UniFont.largeTitle)
                    .foregroundStyle(UniColor.ink)
                    .accessibilityAddTraits(.isHeader)

                if isFreelancer {
                    freelancerContent
                } else {
                    clientContent
                }
            }
            .padding(.horizontal, Space.screen)
            .padding(.top, Space.xs)
            .padding(.bottom, Space.xl)
            .readableWidth()
        }
        .refreshable { await load() }
        .task { await load() }
        .screenBackground()
        .toolbar(.hidden, for: .navigationBar)
        .jobNavigation()
    }

    private func load() async {
        // TODO: load from the API. Clients need their jobs; freelancers need
        // open jobs and their own applications.
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
        }
    }

    // MARK: Client

    private var clientContent: some View {
        let openCount = myJobs.filter { $0.status == .open }.count

        return VStack(alignment: .leading, spacing: Space.xl) {
            if let job = myJobs.first(where: { $0.status == .open }) {
                // TODO: applicant names come from the job's applications in the API.
                OpenJobPanel(job: job, applicantNames: SampleData.applications(for: job.id).map(\.freelancerName))
            } else {
                NoJobsPanel(onPostJob: onPostJob)
            }

            HStack(spacing: Space.sm) {
                QuickTile(title: "Post a job", detail: "\(openCount) open", systemImage: "plus", action: onPostJob)
                QuickTile(title: "My jobs", detail: "\(myJobs.count) in total", systemImage: "briefcase") {
                    onSelectTab(.myJobs)
                }
            }

            if !myJobs.isEmpty {
                VStack(alignment: .leading, spacing: Space.sm) {
                    SectionHeader(title: "Recent jobs", actionTitle: "See all") { onSelectTab(.myJobs) }
                    JobList(jobs: Array(myJobs.prefix(3)), showsClient: false)
                }
            }
        }
    }

    // MARK: Freelancer

    private var freelancerContent: some View {
        let pendingCount = myApplications.filter { $0.status == .pending }.count
        // Newest first, so the panel shows the job posted most recently.
        let newest = openJobs.sorted { $0.createdAt > $1.createdAt }

        return VStack(alignment: .leading, spacing: Space.xl) {
            if let job = newest.first {
                NewestJobPanel(job: job)
            } else {
                InfoCard(systemImage: "briefcase", title: "No open jobs right now", message: "Pull down to refresh, or check Browse later.")
            }

            HStack(spacing: Space.sm) {
                QuickTile(title: "Browse jobs", detail: "\(openJobs.count) open", systemImage: "magnifyingglass") {
                    onSelectTab(.browse)
                }
                QuickTile(title: "My work", detail: "\(pendingCount) pending", systemImage: "tray") {
                    onSelectTab(.myWork)
                }
            }

            if newest.count > 1 {
                VStack(alignment: .leading, spacing: Space.sm) {
                    SectionHeader(title: "More jobs", actionTitle: "See all") { onSelectTab(.browse) }
                    JobList(jobs: Array(newest.dropFirst().prefix(3)))
                }
            }
        }
    }
}

// MARK: - Pieces

/// Hero card behind both panels: raised surface with the apricot glow top right.
private struct PanelBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: Radius.panel, style: .continuous)
            .fill(UniColor.raised)
            .overlay(alignment: .topTrailing) {
                RadialGradient(colors: [UniColor.apricot.opacity(0.35), .clear], center: .center, startRadius: 0, endRadius: 140)
                    .frame(width: 280, height: 280)
                    .offset(x: 90, y: -110)
            }
            .clipShape(RoundedRectangle(cornerRadius: Radius.panel, style: .continuous))
    }
}

/// Client: their open job, how many applied, and a way to review them.
private struct OpenJobPanel: View {
    let job: Job
    let applicantNames: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            HStack(alignment: .top, spacing: Space.md) {
                VStack(alignment: .leading, spacing: Space.xxs) {
                    Text("Your open job")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(UniColor.ember)
                    Text(job.title)
                        .font(UniFont.title2)
                        .foregroundStyle(UniColor.ink)
                    Label(job.whenText, systemImage: "calendar")
                        .font(.subheadline)
                        .foregroundStyle(UniColor.inkSecondary)
                }
                Spacer(minLength: 0)
                StatCircle(
                    value: "\(job.applicationCount)",
                    label: job.applicationCount == 1 ? "applicant" : "applicants",
                    size: 72
                )
            }

            if !applicantNames.isEmpty {
                HStack(spacing: Space.sm) {
                    AvatarStack(names: applicantNames, size: 36)
                    Text("Waiting for you to pick one")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(UniColor.ink)
                }
            }

            NavigationLink {
                ApplicantsView(job: job)
            } label: {
                Text("Review applicants")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(Space.lg)
        .background { PanelBackground() }
        .lift()
        .accessibilityElement(children: .contain)
    }
}

/// Client with nothing open: invite them to post instead of an empty card.
private struct NoJobsPanel: View {
    let onPostJob: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            Text("No open jobs")
                .font(UniFont.title2)
                .foregroundStyle(UniColor.ink)
            Text("Post a job and students can start applying.")
                .font(.subheadline)
                .foregroundStyle(UniColor.inkSecondary)
            Button("Post a job", action: onPostJob)
                .buttonStyle(PrimaryButtonStyle())
        }
        .padding(Space.lg)
        .background { PanelBackground() }
        .lift()
    }
}

/// Freelancer: the newest open job, with its budget on the right.
private struct NewestJobPanel: View {
    let job: Job

    var body: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            HStack(alignment: .top, spacing: Space.md) {
                VStack(alignment: .leading, spacing: Space.xxs) {
                    Text("Just posted")
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
                StatCircle(value: job.budgetText, label: "budget", size: 72)
            }
            FlowLayout(spacing: 6) {
                Chip(text: job.categoryName)
                Chip(text: job.whenText, systemImage: "calendar")
            }
            NavigationLink(value: job) {
                Text("View job")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(Space.lg)
        .background { PanelBackground() }
        .lift()
        .accessibilityElement(children: .contain)
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

#Preview("Client") {
    NavigationStack { HomeView(onPostJob: {}, onSelectTab: { _ in }) }
        .environment(AppSession.preview)
}

#Preview("Freelancer") {
    NavigationStack { HomeView(onPostJob: {}, onSelectTab: { _ in }) }
        .environment(AppSession.preview(as: .freelancer))
}
