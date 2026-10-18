import SwiftUI

// Small pieces shared by the job screens: formatting, status chips, rows.

extension Job {
    /// "$60", or "$62.50" when there are cents.
    var budgetText: String {
        "$" + budget.formatted(.number.precision(.fractionLength(0...2)))
    }

    /// "Tue 20 Oct, 2:00 pm" in the user's locale.
    var whenText: String {
        scheduledAt.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated).hour().minute())
    }
}

struct JobStatusChip: View {
    let status: JobStatus

    var body: some View {
        switch status {
        case .open: Chip(text: "Open", systemImage: "circle.dotted", style: .brand)
        case .assigned: Chip(text: "Assigned", systemImage: "person.fill.checkmark")
        case .completed: Chip(text: "Completed", systemImage: "checkmark", style: .success)
        case .cancelled: Chip(text: "Cancelled", systemImage: "xmark", style: .danger)
        }
    }
}

struct ApplicationStatusChip: View {
    let status: ApplicationStatus

    var body: some View {
        switch status {
        case .pending: Chip(text: "Pending", systemImage: "clock", style: .brand)
        case .accepted: Chip(text: "Accepted", systemImage: "checkmark", style: .success)
        case .rejected: Chip(text: "Not selected", systemImage: "xmark", style: .danger)
        case .withdrawn: Chip(text: "Withdrawn", systemImage: "arrow.uturn.backward")
        }
    }
}

/// One job in a list: title and facts on the left, budget on the right.
struct JobRow: View {
    let job: Job
    /// Browse shows who posted it; My Jobs shows the status instead.
    var showsClient = true

    var body: some View {
        HStack(alignment: .top, spacing: Space.sm) {
            VStack(alignment: .leading, spacing: 6) {
                Text(job.title)
                    .font(.headline)
                    .foregroundStyle(UniColor.ink)
                    .multilineTextAlignment(.leading)
                Text(showsClient ? "\(job.clientName), \(job.suburb)" : job.suburb)
                    .font(.subheadline)
                    .foregroundStyle(UniColor.inkSecondary)
                FlowLayout(spacing: 6) {
                    if !showsClient { JobStatusChip(status: job.status) }
                    Chip(text: job.categoryName)
                    Chip(text: job.whenText, systemImage: "calendar")
                }
            }
            Spacer(minLength: Space.xs)
            StatCircle(value: job.budgetText, label: "budget")
        }
        .padding(Space.md)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityHint(Text("Opens job details"))
    }
}

/// Jobs in one grouped card. Each row pushes JobDetailView, so the screen
/// that shows this needs `.jobNavigation()`.
struct JobList: View {
    let jobs: [Job]
    var showsClient = true

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(jobs.enumerated()), id: \.element.id) { index, job in
                if index > 0 { Divider().overlay(UniColor.hairline).padding(.leading, Space.md) }
                NavigationLink(value: job) {
                    JobRow(job: job, showsClient: showsClient)
                }
                .buttonStyle(.plain)
            }
        }
        .raisedSurface(padding: 0)
    }
}

extension View {
    /// Lets `NavigationLink(value: job)` open the job's detail screen.
    /// Add it once to the root view of each tab's NavigationStack.
    func jobNavigation() -> some View {
        navigationDestination(for: Job.self) { job in
            JobDetailView(job: job)
        }
    }
}
