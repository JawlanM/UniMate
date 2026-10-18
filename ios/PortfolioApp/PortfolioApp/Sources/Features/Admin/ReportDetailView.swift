import SwiftUI

/// One report. The admin moves it to Under review, Resolved or Dismissed.
struct ReportDetailView: View {
    let report: Report

    @State private var status: ReportStatus
    @State private var isSaving = false
    @State private var errorMessage: String?

    init(report: Report) {
        self.report = report
        _status = State(initialValue: report.status)
    }

    private var isClosed: Bool { status == .resolved || status == .dismissed }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.lg) {
                VStack(alignment: .leading, spacing: Space.sm) {
                    ReportStatusChip(status: status)
                    Text(report.reason.label)
                        .font(UniFont.title)
                        .foregroundStyle(UniColor.ink)
                        .accessibilityAddTraits(.isHeader)
                    Text("Reported \(report.createdAt.formatted(.relative(presentation: .named))) by \(report.reporterName)")
                        .font(.subheadline)
                        .foregroundStyle(UniColor.inkSecondary)
                }

                VStack(alignment: .leading, spacing: Space.xs) {
                    Text("Job")
                        .font(.headline)
                        .foregroundStyle(UniColor.ink)
                    Text(report.jobTitle)
                        .font(.body)
                        .foregroundStyle(UniColor.ink)
                        .raisedSurface()
                }

                VStack(alignment: .leading, spacing: Space.xs) {
                    Text("Details")
                        .font(.headline)
                        .foregroundStyle(UniColor.ink)
                    Text(report.details.isEmpty ? "No details given." : report.details)
                        .font(.body)
                        .foregroundStyle(report.details.isEmpty ? UniColor.inkSecondary : UniColor.ink)
                        .fixedSize(horizontal: false, vertical: true)
                        .raisedSurface()
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
            if !isClosed {
                VStack(spacing: Space.xs) {
                    if status == .open {
                        Button("Start review") { Task { await update(to: .underReview) } }
                            .buttonStyle(SecondaryButtonStyle())
                    }
                    Button("Resolve") { Task { await update(to: .resolved) } }
                        .buttonStyle(PrimaryButtonStyle())
                    Button("Dismiss report") { Task { await update(to: .dismissed) } }
                        .buttonStyle(SecondaryButtonStyle(tint: UniColor.danger))
                }
                .disabled(isSaving)
                .padding(.horizontal, Space.screen)
                .padding(.vertical, Space.sm)
                .readableWidth()
                .background(UniColor.canvas.opacity(0.95))
            }
        }
        .screenBackground()
        .navigationTitle("Report")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func update(to newStatus: ReportStatus) async {
        // TODO: send the new status to the API. Set isSaving while it runs,
        // then update `status` on success or set errorMessage on failure.
    }
}

#Preview {
    NavigationStack { ReportDetailView(report: SampleData.reports[0]) }
}
