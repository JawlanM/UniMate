import SwiftUI

/// The client sees everyone who applied for one job and accepts one of them.
struct ApplicantsView: View {
    let job: Job

    @State private var state: LoadState = .loaded
    @State private var applications: [JobApplication]
    @State private var applicationToAccept: JobApplication?
    @State private var errorMessage: String?

    init(job: Job) {
        self.job = job
        // TODO: start with [] and fill from the API in load().
        _applications = State(initialValue: SampleData.applications(for: job.id))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.md) {
                VStack(alignment: .leading, spacing: Space.xxs) {
                    Text(job.title)
                        .font(UniFont.title2)
                        .foregroundStyle(UniColor.ink)
                    Text("Accepting one applicant assigns the job and closes it to others.")
                        .font(.subheadline)
                        .foregroundStyle(UniColor.inkSecondary)
                }

                if let errorMessage {
                    ErrorBanner(message: errorMessage)
                }

                LoadStateView(
                    state: state,
                    isEmpty: applications.isEmpty,
                    emptyTitle: "No applicants yet",
                    emptySystemImage: "person.2",
                    emptyMessage: "Students who apply will show up here.",
                    retry: { Task { await load() } }
                ) {
                    VStack(spacing: Space.sm) {
                        ForEach(applications) { application in
                            ApplicantCard(
                                application: application,
                                canAccept: job.status == .open && application.status == .pending
                            ) {
                                applicationToAccept = application
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, Space.screen)
            .padding(.vertical, Space.md)
            .readableWidth()
        }
        .refreshable { await load() }
        .task { await load() }
        .screenBackground()
        .navigationTitle("Applicants")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Accept \(applicationToAccept?.freelancerName ?? "")?",
            isPresented: Binding(get: { applicationToAccept != nil }, set: { if !$0 { applicationToAccept = nil } }),
            titleVisibility: .visible,
            presenting: applicationToAccept
        ) { application in
            Button("Accept") { Task { await accept(application) } }
        } message: { _ in
            Text("The other applicants won't be selected.")
        }
    }

    private func load() async {
        // TODO: load this job's applications from the API and set `state`.
    }

    private func accept(_ application: JobApplication) async {
        // TODO: accept the application through the API.
        // On failure set errorMessage; on success reload (the job becomes Assigned).
    }
}

private struct ApplicantCard: View {
    let application: JobApplication
    let canAccept: Bool
    let onAccept: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            HStack(spacing: Space.sm) {
                AvatarView(name: application.freelancerName, size: 44)
                VStack(alignment: .leading, spacing: 2) {
                    Text(application.freelancerName)
                        .font(.headline)
                        .foregroundStyle(UniColor.ink)
                    Text("Applied \(application.createdAt.formatted(.relative(presentation: .named)))")
                        .font(.footnote)
                        .foregroundStyle(UniColor.inkSecondary)
                }
                Spacer(minLength: Space.xs)
                ApplicationStatusChip(status: application.status)
            }
            .accessibilityElement(children: .combine)

            Text(application.message)
                .font(.subheadline)
                .foregroundStyle(UniColor.ink)
                .fixedSize(horizontal: false, vertical: true)

            if canAccept {
                Button("Accept", action: onAccept)
                    .buttonStyle(PrimaryButtonStyle())
                    .accessibilityLabel(Text("Accept \(application.freelancerName)"))
            }
        }
        .raisedSurface()
    }
}

#Preview {
    NavigationStack { ApplicantsView(job: SampleData.myJobs[0]) }
}
