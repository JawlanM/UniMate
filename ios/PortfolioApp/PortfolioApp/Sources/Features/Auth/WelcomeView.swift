import SwiftUI

struct WelcomeView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.xl) {
                HStack(spacing: Space.xs) {
                    Image(systemName: "point.3.connected.trianglepath.dotted")
                        .foregroundStyle(UniColor.ember)
                    Text("UniMate")
                        .font(UniFont.title2)
                        .foregroundStyle(UniColor.ink)
                }
                .accessibilityElement(children: .combine)

                WelcomeOrbit()

                VStack(alignment: .leading, spacing: Space.sm) {
                    Text("Campus help, matched to you.")
                        .font(UniFont.display)
                        .foregroundStyle(UniColor.ink)
                        .accessibilityAddTraits(.isHeader)

                    Text("Post a task and we'll rank verified students near your campus by how well they fit. Or pick up paid work between classes.")
                        .font(.body)
                        .foregroundStyle(UniColor.inkSecondary)
                }

                FlowLayout(spacing: Space.xs) {
                    Chip(text: "Student email verified", systemImage: "checkmark.shield")
                    Chip(text: "Ranked by fit", systemImage: "target")
                    Chip(text: "Suburb-level location", systemImage: "location")
                }

                VStack(spacing: Space.sm) {
                    NavigationLink(value: AuthRoute.register) {
                        Text("Create account")
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    NavigationLink(value: AuthRoute.signIn) {
                        Text("Sign in")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
            }
            .padding(.horizontal, Space.screen)
            .padding(.vertical, Space.md)
        }
        .scrollBounceBehavior(.basedOnSize)
        .screenBackground()
        .toolbar(.hidden, for: .navigationBar)
    }
}

/// Students on radar rings, linked to "you" in the middle. Closer = better match.
private struct WelcomeOrbit: View {
    private let nodes: [OrbitNode] = [
        .init(name: "Liam Chen", angle: -38, distance: 0.52, size: 52, score: 92),
        .init(name: "Priya Sharma", angle: 200, distance: 0.62, size: 46, score: 86),
        .init(name: "Daniel Park", angle: 115, distance: 0.74, size: 44),
        .init(name: "Sofia Nguyen", angle: 30, distance: 0.95, size: 40),
        .init(name: "Jess Kim", angle: 255, distance: 1.0, size: 36)
    ]

    var body: some View {
        MatchOrbit(nodes: nodes) {
            Image(systemName: "person.fill")
                .font(.title2)
                .foregroundStyle(UniColor.onInk)
                .frame(width: 64, height: 64)
                .background(UniColor.ink, in: Circle())
                .overlay(Circle().stroke(UniColor.canvas, lineWidth: 4))
        }
        .frame(height: 300)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Illustration: nearby students ranked around you by match score."))
    }
}

#Preview {
    NavigationStack { WelcomeView() }
}
