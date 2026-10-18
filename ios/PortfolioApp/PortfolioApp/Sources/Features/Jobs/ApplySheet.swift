import SwiftUI

/// A freelancer writes a short message to the client and applies.
struct ApplySheet: View {
    @Environment(\.dismiss) private var dismiss
    let job: Job

    @State private var message = ""
    @State private var isSending = false
    @State private var errorMessage: String?

    // Same limit as the API.
    private let limit = 500

    private var messageProblem: String? {
        if message.count > limit { return "Keep it to \(limit) characters or fewer." }
        return nil
    }

    private var canSend: Bool {
        !message.trimmed.isEmpty && messageProblem == nil && !isSending
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Space.md) {
                    VStack(alignment: .leading, spacing: Space.xxs) {
                        Text(job.title)
                            .font(UniFont.title2)
                            .foregroundStyle(UniColor.ink)
                        Text("\(job.clientName), \(job.suburb), \(job.budgetText)")
                            .font(.subheadline)
                            .foregroundStyle(UniColor.inkSecondary)
                    }

                    LabeledTextEditor(label: "Message to \(job.clientName)", text: $message, limit: limit)
                    if let messageProblem {
                        FieldError(message: messageProblem)
                    }

                    Text("Say why you're a good fit and when you're free.")
                        .font(.footnote)
                        .foregroundStyle(UniColor.inkSecondary)

                    if let errorMessage {
                        ErrorBanner(message: errorMessage)
                    }

                    Button {
                        Task { await send() }
                    } label: {
                        if isSending {
                            ProgressView().tint(UniColor.onInk)
                        } else {
                            Text("Send application")
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
            .navigationTitle("Apply")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func send() async {
        // TODO: send the application to the API.
        // Set isSending while it runs. On failure set errorMessage and stay
        // open; on success dismiss and refresh the job screen.
        dismiss()
    }
}

#Preview {
    ApplySheet(job: SampleData.openJobs[0])
}
