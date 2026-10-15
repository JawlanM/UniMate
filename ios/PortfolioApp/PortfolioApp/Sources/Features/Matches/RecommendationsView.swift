import SwiftUI

/// Ranked freelancers for one job. Mirrors GET /api/jobs/{id}/matches.
struct RecommendationsView: View {
    var jobTitle = MockData.topMatchesJobTitle
    var when = MockData.topMatchesJobWhen
    var matches = MockData.topMatches

    @State private var isShowingScoreHelp = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.xl) {
                VStack(alignment: .leading, spacing: Space.xxs) {
                    Text(jobTitle)
                        .font(UniFont.largeTitle)
                        .foregroundStyle(UniColor.ink)
                        .accessibilityAddTraits(.isHeader)
                    Label(when, systemImage: "calendar")
                        .font(.subheadline)
                        .foregroundStyle(UniColor.inkSecondary)
                }

                MatchOrbit(nodes: orbitNodes) {
                    Image(systemName: "shippingbox.fill")
                        .font(.title3)
                        .foregroundStyle(UniColor.ink)
                        .frame(width: 56, height: 56)
                        .background(UniColor.apricot, in: Circle())
                        .overlay(Circle().stroke(UniColor.canvas, lineWidth: 4))
                }
                .frame(height: 290)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text("\(matches.count) students around your job. Closer to the centre means a better match."))

                VStack(alignment: .leading, spacing: Space.xxs) {
                    SectionHeader(title: "\(matches.count) matches, best first")
                    Button {
                        isShowingScoreHelp = true
                    } label: {
                        Label("How matching works", systemImage: "info.circle")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(UniColor.ember)
                            .frame(minHeight: 44)
                    }
                }

                if let top = matches.first {
                    NavigationLink(value: top) {
                        TopMatchCard(match: top)
                    }
                    .buttonStyle(.plain)
                }

                VStack(spacing: 0) {
                    ForEach(Array(matches.dropFirst().enumerated()), id: \.element.id) { index, match in
                        if index > 0 { Divider().overlay(UniColor.hairline).padding(.leading, 72) }
                        NavigationLink(value: match) {
                            MatchRow(match: match)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .raisedSurface(padding: 0)
            }
            .padding(.horizontal, Space.screen)
            .padding(.bottom, Space.xl)
        }
        .screenBackground()
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingScoreHelp) {
            ScoreHelpSheet()
                .presentationDetents([.medium, .large])
                .presentationBackground(UniColor.canvas)
        }
    }

    /// Spread students around the job; a higher score sits closer to the centre.
    private var orbitNodes: [OrbitNode] {
        let angles: [Double] = [-50, 200, 115, 35, 280, 160]
        return matches.prefix(angles.count).enumerated().map { index, match in
            let closeness = CGFloat(min(max(match.score - 55, 0), 45)) / 45
            return OrbitNode(
                name: match.name,
                angle: angles[index],
                distance: 0.55 + (1 - closeness) * 0.45, // never on top of the centre
                size: index == 0 ? 50 : 42,
                score: match.score
            )
        }
    }
}

/// The best match gets the only lifted card on the screen.
private struct TopMatchCard: View {
    let match: MatchPreview

    var body: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            HStack(spacing: Space.sm) {
                AvatarView(name: match.name, size: 52)
                VStack(alignment: .leading, spacing: 2) {
                    Text(match.name)
                        .font(.headline)
                        .foregroundStyle(UniColor.ink)
                    HStack(spacing: Space.xs) {
                        RatingBadge(rating: match.rating, reviewCount: match.completedJobs)
                        Text(match.university)
                            .font(.subheadline)
                            .foregroundStyle(UniColor.inkSecondary)
                            .lineLimit(1)
                    }
                }
                Spacer(minLength: Space.xs)
                ScoreRing(score: match.score, size: 64)
            }
            FlowLayout(spacing: 6) {
                ForEach(match.reasons, id: \.self) { MatchReasonChip(reason: $0) }
            }
        }
        .padding(Space.md)
        .background(UniColor.raised, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Radius.card, style: .continuous).stroke(UniColor.apricot, lineWidth: 2))
        .lift()
        .accessibilityElement(children: .combine)
        .accessibilityHint(Text("Top match. Opens profile"))
    }
}

/// Plain-language explanation of the weights (P6/HD1: the score must be explainable).
private struct ScoreHelpSheet: View {
    private let weights: [(String, String, Int)] = [
        ("Category", "shippingbox", 30),
        ("Distance", "location", 25),
        ("Availability", "calendar", 15),
        ("Rating", "star", 12),
        ("Language", "character.bubble", 10),
        ("Experience", "checkmark.seal", 8)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            Text("How matching works")
                .font(UniFont.title)
                .foregroundStyle(UniColor.ink)
                .accessibilityAddTraits(.isHeader)
            Text("Match % is how well a student fits this job. Each factor below adds points, up to 100 in total. These are all the factors; nothing else is counted.")
                .font(.body)
                .foregroundStyle(UniColor.inkSecondary)

            VStack(spacing: 0) {
                ForEach(Array(weights.enumerated()), id: \.offset) { index, item in
                    if index > 0 { Divider().overlay(UniColor.hairline) }
                    HStack {
                        Label(item.0, systemImage: item.1)
                            .foregroundStyle(UniColor.ink)
                        Spacer()
                        Text("up to \(item.2) pts")
                            .monospacedDigit()
                            .foregroundStyle(UniColor.inkSecondary)
                    }
                    .font(.body)
                    .frame(minHeight: 44)
                }
            }
            .sunkenSurface(padding: Space.md)
        }
        .padding(Space.xl)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    NavigationStack { RecommendationsView() }
}
