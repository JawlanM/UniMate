import SwiftUI

extension ReportReason {
    /// Readable label ("No-show" rather than the API's "NoShow").
    var label: String {
        switch self {
        case .harassment: "Harassment"
        case .scam: "Scam or fraud"
        case .inappropriate: "Inappropriate content"
        case .noShow: "No-show"
        case .safety: "Safety concern"
        case .other: "Something else"
        }
    }
}

/// Report a job or the person behind it to the admins.
struct ReportSheet: View {
    @Environment(\.dismiss) private var dismiss
    let job: Job

    @State private var reason: ReportReason?
    @State private var details = ""
    @State private var isSending = false
    @State private var errorMessage: String?

    private let limit = 1000

    private var canSend: Bool {
        reason != nil && details.count <= limit && !isSending
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Space.md) {
                    Text("Reports go to the UniMate team, not to \(job.clientName). We'll look into it.")
                        .font(.subheadline)
                        .foregroundStyle(UniColor.inkSecondary)

                    VStack(alignment: .leading, spacing: Space.xs) {
                        Text("What's wrong?")
                            .font(.headline)
                            .foregroundStyle(UniColor.ink)
                        VStack(spacing: 0) {
                            ForEach(Array(ReportReason.allCases.enumerated()), id: \.element) { index, item in
                                if index > 0 { Divider().overlay(UniColor.hairline) }
                                reasonRow(item)
                            }
                        }
                        .padding(.horizontal, Space.md)
                        .raisedSurface(padding: 0)
                    }

                    LabeledTextEditor(label: "Details (optional)", text: $details, limit: limit)

                    if let errorMessage {
                        ErrorBanner(message: errorMessage)
                    }

                    Button {
                        Task { await send() }
                    } label: {
                        if isSending {
                            ProgressView().tint(UniColor.onInk)
                        } else {
                            Text("Send report")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(!canSend)
                }
                .padding(Space.screen)
                .readableWidth()
            }
            .scrollDismissesKeyboard(.interactively)
            .screenBackground()
            .navigationTitle("Report job")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func reasonRow(_ item: ReportReason) -> some View {
        Button {
            reason = item
        } label: {
            HStack {
                Text(item.label)
                    .foregroundStyle(UniColor.ink)
                Spacer()
                if reason == item {
                    Image(systemName: "checkmark")
                        .fontWeight(.semibold)
                        .foregroundStyle(UniColor.ember)
                }
            }
            .font(.body)
            .frame(minHeight: 48)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(reason == item ? .isSelected : [])
    }

    private func send() async {
        // TODO: send the report (job.id, reason, details) to the API.
        // On failure set errorMessage and stay open; on success dismiss.
        dismiss()
    }
}

#Preview {
    ReportSheet(job: SampleData.openJobs[0])
}
