import SwiftUI

/// A freelancer's applications: what's still in play and what's finished.
struct MyWorkView: View {
    enum Filter: String, CaseIterable, Identifiable {
        case active = "Active"
        case past = "Past"

        var id: Self { self }
    }

    // TODO: start with [] and fill from the API in load().
    @State private var applications: [JobApplication] = SampleData.myApplications
    @State private var state: LoadState = .loaded
    @State private var filter: Filter = .active

    /// Active = waiting to hear back, or accepted on a job that isn't finished yet.
    private var visibleApplications: [JobApplication] {
        applications.filter { application in
            let isActive = application.status == .pending
                || (application.status == .accepted && application.jobStatus == .assigned)
            return filter == .active ? isActive : !isActive
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.lg) {
                VStack(alignment: .leading, spacing: Space.xxs) {
                    Text("My work")
                        .font(UniFont.largeTitle)
                        .foregroundStyle(UniColor.ink)
                        .accessibilityAddTraits(.isHeader)
                    Text("Jobs you've applied for.")
                        .font(.subheadline)
                        .foregroundStyle(UniColor.inkSecondary)
                }

                Picker("Show", selection: $filter) {
                    ForEach(Filter.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)

                LoadStateView(
                    state: state,
                    isEmpty: visibleApplications.isEmpty,
                    emptyTitle: filter == .active ? "Nothing active" : "Nothing here yet",
                    emptySystemImage: "tray",
                    emptyMessage: filter == .active
                        ? "Apply for a job in Browse and it will show up here."
                        : "Finished, withdrawn and unsuccessful applications show up here.",
                    retry: { Task { await load() } }
                ) {
                    VStack(spacing: 0) {
                        ForEach(Array(visibleApplications.enumerated()), id: \.element.id) { index, application in
                            if index > 0 { Divider().overlay(UniColor.hairline).padding(.leading, Space.md) }
                            row(for: application)
                        }
                    }
                    .raisedSurface(padding: 0)
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

    @ViewBuilder
    private func row(for application: JobApplication) -> some View {
        // TODO: the API gives the application, not the whole job. Fetch the job
        // by application.jobId when the row is tapped (or load jobs alongside).
        if let job = SampleData.job(id: application.jobId) {
            NavigationLink(value: job) {
                ApplicationRow(application: application)
            }
            .buttonStyle(.plain)
        } else {
            ApplicationRow(application: application)
        }
    }

    private func load() async {
        // TODO: load the signed-in freelancer's applications from the API and set `state`.
    }
}

private struct ApplicationRow: View {
    let application: JobApplication

    var body: some View {
        HStack(alignment: .top, spacing: Space.sm) {
            VStack(alignment: .leading, spacing: 6) {
                Text(application.jobTitle)
                    .font(.headline)
                    .foregroundStyle(UniColor.ink)
                    .multilineTextAlignment(.leading)
                Text("Applied \(application.createdAt.formatted(.relative(presentation: .named)))")
                    .font(.subheadline)
                    .foregroundStyle(UniColor.inkSecondary)
                ApplicationStatusChip(status: application.status)
            }
            Spacer(minLength: Space.xs)
            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(UniColor.inkTertiary)
                .accessibilityHidden(true)
        }
        .padding(Space.md)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack { MyWorkView() }
        .environment(AppSession.preview(as: .freelancer))
}
