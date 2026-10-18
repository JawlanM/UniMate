import SwiftUI

/// The client's form for a new job. Opened as a sheet from the + button.
struct PostJobView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var categoryId: Int?
    @State private var description = ""
    @State private var budgetText = ""
    @State private var suburb = ""
    @State private var scheduledAt = Date.now.addingTimeInterval(24 * 60 * 60)
    @State private var categories: [Category] = SampleData.categories // TODO: load from the API
    @State private var isPosting = false
    @State private var errorMessage: String?

    // Same rules as the API, so problems show before anything is sent.
    private let titleLimit = 80
    private let descriptionLimit = 1000

    private var budget: Decimal? { Decimal(string: budgetText.trimmed) }

    private var titleProblem: String? {
        title.count > titleLimit ? "Keep the title to \(titleLimit) characters or fewer." : nil
    }

    private var budgetProblem: String? {
        guard !budgetText.isEmpty else { return nil }
        guard let budget else { return "Enter a number, like 60." }
        return budget <= 0 || budget > 10_000 ? "Budget must be between $1 and $10,000." : nil
    }

    private var canPost: Bool {
        !title.trimmed.isEmpty && titleProblem == nil
            && categoryId != nil
            && !description.trimmed.isEmpty && description.count <= descriptionLimit
            && budget != nil && budgetProblem == nil
            && !suburb.trimmed.isEmpty
            && scheduledAt > .now
            && !isPosting
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Space.md) {
                    LabeledInput(label: "Job title", text: $title)
                    if let titleProblem { FieldError(message: titleProblem) }

                    categoryPicker

                    LabeledTextEditor(label: "What do you need done?", text: $description, limit: descriptionLimit)

                    LabeledInput(label: "Budget ($)", text: $budgetText, kind: .decimal)
                    if let budgetProblem { FieldError(message: budgetProblem) }

                    LabeledInput(label: "Suburb", text: $suburb, kind: .name)

                    DatePicker("When", selection: $scheduledAt, in: Date.now..., displayedComponents: [.date, .hourAndMinute])
                        .font(.body.weight(.medium))
                        .foregroundStyle(UniColor.ink)
                        .padding(.horizontal, Space.md)
                        .frame(minHeight: 64)
                        .background(UniColor.raised, in: RoundedRectangle(cornerRadius: Radius.control, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: Radius.control, style: .continuous).stroke(UniColor.hairline, lineWidth: 1))

                    if let errorMessage {
                        ErrorBanner(message: errorMessage)
                    }

                    Button {
                        Task { await post() }
                    } label: {
                        if isPosting {
                            ProgressView().tint(UniColor.onInk)
                        } else {
                            Text("Post job")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(!canPost)
                    .padding(.top, Space.xs)
                }
                .padding(Space.screen)
                .readableWidth()
            }
            .scrollDismissesKeyboard(.interactively)
            .screenBackground()
            .navigationTitle("Post a job")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: Space.xs) {
            Text("Category")
                .font(.footnote.weight(.medium))
                .foregroundStyle(UniColor.inkSecondary)
            FlowLayout(spacing: Space.xs) {
                ForEach(categories) { category in
                    let isSelected = categoryId == category.id
                    Button {
                        categoryId = category.id
                    } label: {
                        Chip(text: category.name, systemImage: category.iconName, style: isSelected ? .selected : .neutral)
                            .frame(minHeight: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
        }
    }

    private func post() async {
        // TODO: send the new job to the API (title, categoryId, description,
        // budget, suburb, scheduledAt). Set isPosting while it runs. On failure
        // set errorMessage and stay open; on success dismiss and refresh My Jobs.
        dismiss()
    }
}

#Preview {
    PostJobView()
}
