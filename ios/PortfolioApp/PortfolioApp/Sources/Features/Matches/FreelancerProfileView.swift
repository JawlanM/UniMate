import SwiftUI

/// A freelancer seen from a client's job: who they are and why they match.
struct FreelancerProfileView: View {
    let match: MatchPreview
    var jobTitle = MockData.topMatchesJobTitle

    @State private var isSendingOffer = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.xl) {
                identity
                stats
                whyTheyMatch
                reviews
                about
            }
            .padding(.horizontal, Space.screen)
            .padding(.bottom, Space.xl)
        }
        .screenBackground()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {} label: {
                    Image(systemName: "bookmark")
                }
                .accessibilityLabel(Text("Save \(match.name)"))
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: Space.sm) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("$\(match.hourlyRate)")
                        .font(UniFont.title)
                        .foregroundStyle(UniColor.ink)
                    Text("per hour")
                        .font(.footnote)
                        .foregroundStyle(UniColor.inkSecondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(Text("$\(match.hourlyRate) per hour"))

                Button("Send offer") { isSendingOffer = true }
                    .buttonStyle(PrimaryButtonStyle())
            }
            .padding(.horizontal, Space.screen)
            .padding(.vertical, Space.sm)
            .background(UniColor.canvas.opacity(0.96).ignoresSafeArea())
            .overlay(alignment: .top) { Divider().overlay(UniColor.hairline) }
        }
        .sheet(isPresented: $isSendingOffer) {
            NavigationStack {
                PlaceholderScreen(title: "Send offer", systemImage: "paperplane", message: "Offers to \(match.name) come next.")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") { isSendingOffer = false }
                        }
                    }
            }
        }
    }

    // MARK: Sections

    private var identity: some View {
        VStack(spacing: Space.sm) {
            ScoredAvatar(name: match.name, score: match.score)
            VStack(spacing: Space.xxs) {
                Text(match.name)
                    .font(UniFont.title)
                    .foregroundStyle(UniColor.ink)
                    .accessibilityAddTraits(.isHeader)
                Text("\(match.course), \(match.university)")
                    .font(.subheadline)
                    .foregroundStyle(UniColor.inkSecondary)
            }
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Space.xs)
    }

    /// Two plain facts in one row, separated by hairlines rather than boxed.
    private var stats: some View {
        HStack(spacing: 0) {
            stat(value: "\(match.completedJobs)", label: "Jobs done")
            Divider().overlay(UniColor.hairline).frame(height: 36)
            stat(value: String(format: "%.1f km", match.distanceKm), label: "From your job")
        }
        .padding(.vertical, Space.sm)
        .sunkenSurface(padding: 0)
    }

    private func stat(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(UniFont.title2)
                .monospacedDigit()
                .foregroundStyle(UniColor.ink)
            Text(label)
                .font(.footnote)
                .foregroundStyle(UniColor.inkSecondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    private var whyTheyMatch: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            VStack(alignment: .leading, spacing: Space.xxs) {
                SectionHeader(title: "Why \(match.name.split(separator: " ").first ?? "") matches")
                Text("How the \(match.score)% match for \(jobTitle) adds up.")
                    .font(.subheadline)
                    .foregroundStyle(UniColor.inkSecondary)
            }
            VStack(alignment: .leading, spacing: Space.md) {
                ForEach(match.breakdown) { ScoreFactorRow(factor: $0) }
            }
            .raisedSurface(padding: Space.md)
        }
    }

    private var reviews: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            SectionHeader(title: "Reviews")
            RatingSummary(rating: match.rating, reviewCount: match.completedJobs, praise: match.praise)
        }
    }

    private var about: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            SectionHeader(title: "About")
            Text(match.bio)
                .font(.body)
                .foregroundStyle(UniColor.ink)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: Space.xs) {
                Text("Skills")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(UniColor.inkSecondary)
                FlowLayout(spacing: 6) {
                    ForEach(match.skills, id: \.self) { Chip(text: $0) }
                }
            }

            VStack(alignment: .leading, spacing: Space.xs) {
                Text("Languages")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(UniColor.inkSecondary)
                FlowLayout(spacing: 6) {
                    ForEach(match.languages, id: \.self) { Chip(text: $0, systemImage: "character.bubble") }
                }
            }
        }
    }
}

#Preview {
    NavigationStack { FreelancerProfileView(match: MockData.topMatches[0]) }
}
