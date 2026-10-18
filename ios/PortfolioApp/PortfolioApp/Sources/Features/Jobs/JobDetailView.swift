import SwiftUI

/// Full job details. The buttons at the bottom depend on who is looking:
/// freelancers apply or withdraw, the client reviews applicants, cancels or completes.
struct JobDetailView: View {
    @Environment(AppSession.self) private var session
    let job: Job

    /// The signed-in freelancer's application for this job, if they applied.
    @State private var myApplication: JobApplication?
    @State private var isApplying = false
    @State private var isReporting = false
    @State private var pendingAction: ConfirmAction?
    @State private var isWorking = false
    @State private var errorMessage: String?

    /// Actions that ask "are you sure?" first.
    enum ConfirmAction {
        case withdraw, cancel, complete

        var title: String {
            switch self {
            case .withdraw: "Withdraw your application?"
            case .cancel: "Cancel this job?"
            case .complete: "Mark this job as completed?"
            }
        }

        var buttonTitle: String {
            switch self {
            case .withdraw: "Withdraw application"
            case .cancel: "Cancel job"
            case .complete: "Mark as completed"
            }
        }
    }

    init(job: Job) {
        self.job = job
        // TODO: load this from the API instead (the freelancer's applications, filtered to this job).
        _myApplication = State(initialValue: SampleData.myApplications.first { $0.jobId == job.id })
    }

    private var role: UserRole? { session.currentUser?.role }
    // TODO: compare job.clientId with session.currentUser?.id once the data is real.
    private var isMyJob: Bool { role == .client }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.lg) {
                header
                facts
                section(title: "About the job") {
                    Text(job.description)
                        .font(.body)
                        .foregroundStyle(UniColor.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let name = job.assignedFreelancerName {
                    section(title: job.status == .completed ? "Done by" : "Assigned to") {
                        personRow(name: name, detail: "Freelancer")
                    }
                }

                if role == .freelancer, let myApplication {
                    section(title: "Your application") {
                        VStack(alignment: .leading, spacing: Space.xs) {
                            ApplicationStatusChip(status: myApplication.status)
                            Text(myApplication.message)
                                .font(.subheadline)
                                .foregroundStyle(UniColor.inkSecondary)
                        }
                    }
                }

                if let errorMessage {
                    ErrorBanner(message: errorMessage)
                }
            }
            .padding(.horizontal, Space.screen)
            .padding(.vertical, Space.md)
            .readableWidth()
        }
        .safeAreaInset(edge: .bottom) {
            if hasActions { actions }
        }
        .screenBackground()
        .navigationTitle("Job")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if role != .admin {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isReporting = true
                    } label: {
                        Label("Report", systemImage: "flag")
                    }
                }
            }
        }
        .sheet(isPresented: $isApplying) {
            ApplySheet(job: job)
        }
        .sheet(isPresented: $isReporting) {
            ReportSheet(job: job)
        }
        .confirmationDialog(
            pendingAction?.title ?? "",
            isPresented: Binding(get: { pendingAction != nil }, set: { if !$0 { pendingAction = nil } }),
            titleVisibility: .visible,
            presenting: pendingAction
        ) { action in
            Button(action.buttonTitle, role: action == .complete ? nil : .destructive) {
                Task { await perform(action) }
            }
        }
    }

    // MARK: Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            FlowLayout(spacing: 6) {
                JobStatusChip(status: job.status)
                Chip(text: job.categoryName)
            }
            Text(job.title)
                .font(UniFont.title)
                .foregroundStyle(UniColor.ink)
                .accessibilityAddTraits(.isHeader)
            personRow(name: job.clientName, detail: "Posted \(job.createdAt.formatted(.relative(presentation: .named)))")
        }
    }

    private var facts: some View {
        VStack(spacing: 0) {
            factRow(systemImage: "dollarsign.circle", title: "Budget", value: job.budgetText)
            Divider().overlay(UniColor.hairline)
            factRow(systemImage: "calendar", title: "When", value: job.whenText)
            Divider().overlay(UniColor.hairline)
            factRow(systemImage: "mappin.and.ellipse", title: "Suburb", value: job.suburb)
            Divider().overlay(UniColor.hairline)
            factRow(systemImage: "person.2", title: "Applicants", value: "\(job.applicationCount)")
        }
        .padding(.horizontal, Space.md)
        .raisedSurface(padding: 0)
    }

    private func factRow(systemImage: String, title: String, value: String) -> some View {
        HStack(spacing: Space.sm) {
            Image(systemName: systemImage)
                .foregroundStyle(UniColor.ember)
                .frame(width: 24)
                .accessibilityHidden(true)
            Text(title)
                .foregroundStyle(UniColor.inkSecondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(UniColor.ink)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
        .frame(minHeight: 48)
        .accessibilityElement(children: .combine)
    }

    private func personRow(name: String, detail: String) -> some View {
        HStack(spacing: Space.sm) {
            AvatarView(name: name, size: 40)
            VStack(alignment: .leading, spacing: 0) {
                Text(name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(UniColor.ink)
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(UniColor.inkSecondary)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Space.xs) {
            Text(title)
                .font(.headline)
                .foregroundStyle(UniColor.ink)
                .accessibilityAddTraits(.isHeader)
            content()
                .raisedSurface()
        }
    }

    // MARK: Actions

    private var canApply: Bool { job.status == .open && myApplication == nil }
    private var canWithdraw: Bool { myApplication?.status == .pending }

    private var hasActions: Bool {
        switch role {
        case .freelancer: canApply || canWithdraw
        case .client: isMyJob && (job.status == .open || job.status == .assigned)
        default: false
        }
    }

    private var actions: some View {
        VStack(spacing: Space.xs) {
            if role == .freelancer {
                if canApply {
                    Button("Apply for this job") { isApplying = true }
                        .buttonStyle(PrimaryButtonStyle())
                } else if canWithdraw {
                    Button("Withdraw application") { pendingAction = .withdraw }
                        .buttonStyle(SecondaryButtonStyle(tint: UniColor.danger))
                }
            } else if isMyJob {
                if job.status == .open {
                    NavigationLink {
                        ApplicantsView(job: job)
                    } label: {
                        Text("Review applicants (\(job.applicationCount))")
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button("Cancel job") { pendingAction = .cancel }
                        .buttonStyle(SecondaryButtonStyle(tint: UniColor.danger))
                } else if job.status == .assigned {
                    Button("Mark as completed") { pendingAction = .complete }
                        .buttonStyle(PrimaryButtonStyle())
                }
            }
        }
        .disabled(isWorking)
        .padding(.horizontal, Space.screen)
        .padding(.vertical, Space.sm)
        .readableWidth()
        .background(UniColor.canvas.opacity(0.95))
    }

    private func perform(_ action: ConfirmAction) async {
        // TODO: call the API for this action:
        //   .withdraw → withdraw myApplication
        //   .cancel   → cancel the job
        //   .complete → complete the job
        // Set isWorking while it runs, put failures in errorMessage,
        // then refresh the job (or pop back to the list).
    }
}

#Preview("Freelancer") {
    NavigationStack { JobDetailView(job: SampleData.openJobs[0]) }
        .environment(AppSession.preview(as: .freelancer))
}

#Preview("Client") {
    NavigationStack { JobDetailView(job: SampleData.myJobs[0]) }
        .environment(AppSession.preview)
}
