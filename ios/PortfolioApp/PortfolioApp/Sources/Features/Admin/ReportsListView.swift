import SwiftUI

struct ReportStatusChip: View {
    let status: ReportStatus

    var body: some View {
        switch status {
        case .open: Chip(text: "Open", systemImage: "flag", style: .danger)
        case .underReview: Chip(text: "Under review", systemImage: "eye", style: .brand)
        case .resolved: Chip(text: "Resolved", systemImage: "checkmark", style: .success)
        case .dismissed: Chip(text: "Dismissed", systemImage: "xmark")
        }
    }
}

/// The admin's first tab: every report, open ones first.
struct ReportsListView: View {
    enum Filter: String, CaseIterable, Identifiable {
        case needsAction = "To do"
        case closed = "Closed"

        var id: Self { self }
    }

    // TODO: start with [] and fill from the API in load().
    @State private var reports: [Report] = SampleData.reports
    @State private var state: LoadState = .loaded
    @State private var filter: Filter = .needsAction

    private var visibleReports: [Report] {
        reports.filter { report in
            let needsAction = report.status == .open || report.status == .underReview
            return filter == .needsAction ? needsAction : !needsAction
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.lg) {
                VStack(alignment: .leading, spacing: Space.xxs) {
                    Text("Reports")
                        .font(UniFont.largeTitle)
                        .foregroundStyle(UniColor.ink)
                        .accessibilityAddTraits(.isHeader)
                    Text("Problems users have flagged.")
                        .font(.subheadline)
                        .foregroundStyle(UniColor.inkSecondary)
                }

                Picker("Show", selection: $filter) {
                    ForEach(Filter.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)

                LoadStateView(
                    state: state,
                    isEmpty: visibleReports.isEmpty,
                    emptyTitle: filter == .needsAction ? "All clear" : "No closed reports",
                    emptySystemImage: "checkmark.shield",
                    emptyMessage: filter == .needsAction
                        ? "No reports need your attention."
                        : "Resolved and dismissed reports show up here.",
                    retry: { Task { await load() } }
                ) {
                    VStack(spacing: 0) {
                        ForEach(Array(visibleReports.enumerated()), id: \.element.id) { index, report in
                            if index > 0 { Divider().overlay(UniColor.hairline).padding(.leading, Space.md) }
                            NavigationLink(value: report) {
                                ReportRow(report: report)
                            }
                            .buttonStyle(.plain)
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
        .navigationDestination(for: Report.self) { report in
            ReportDetailView(report: report)
        }
    }

    private func load() async {
        // TODO: load all reports from the API and set `state`.
    }
}

private struct ReportRow: View {
    let report: Report

    var body: some View {
        HStack(alignment: .top, spacing: Space.sm) {
            VStack(alignment: .leading, spacing: 6) {
                Text(report.reason.label)
                    .font(.headline)
                    .foregroundStyle(UniColor.ink)
                Text("\(report.jobTitle), reported by \(report.reporterName)")
                    .font(.subheadline)
                    .foregroundStyle(UniColor.inkSecondary)
                    .multilineTextAlignment(.leading)
                ReportStatusChip(status: report.status)
            }
            Spacer(minLength: Space.xs)
            Text(report.createdAt.formatted(.relative(presentation: .named)))
                .font(.footnote)
                .foregroundStyle(UniColor.inkSecondary)
        }
        .padding(Space.md)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityHint(Text("Opens report"))
    }
}

#Preview {
    NavigationStack { ReportsListView() }
        .environment(AppSession.preview(as: .admin))
}
