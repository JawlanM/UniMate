import SwiftUI

struct WelcomeView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                WelcomeHero()

                VStack(alignment: .leading, spacing: 12) {
                    // Text + Text keeps it as one label for VoiceOver.
                    (Text("Campus help,\n")
                        .foregroundColor(Theme.ink)
                     + Text("matched to you.")
                        .foregroundColor(Theme.orangeDark))
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .accessibilityAddTraits(.isHeader)

                    Text("Post a task or pick up paid work from verified students near your campus.")
                        .font(.body)
                        .foregroundStyle(Theme.muted)
                }

                FlowLayout(spacing: 10) {
                    Chip(text: "Student verified", systemImage: "checkmark.shield", style: .green)
                    Chip(text: "Rated community", systemImage: "star", style: .orange)
                    Chip(text: "Near you", systemImage: "mappin.and.ellipse", style: .purple)
                }

                VStack(spacing: 12) {
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
            .padding(Theme.screenPadding)
        }
        .scrollBounceBehavior(.basedOnSize)
        .screenBackground()
        .toolbar(.hidden, for: .navigationBar)
    }
}

/// Orange card with floating student avatars. Positions are fractions of the
/// card size so it scales from iPhone SE to Pro Max.
private struct WelcomeHero: View {
    private struct Bubble: Identifiable {
        let id = UUID()
        let name: String
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
    }

    private let bubbles = [
        Bubble(name: "Priya Sharma", x: 0.18, y: 0.38, size: 64),
        Bubble(name: "Amara Mensah", x: 0.30, y: 0.66, size: 54),
        Bubble(name: "Daniel Park", x: 0.84, y: 0.44, size: 60),
        Bubble(name: "Jess Kim", x: 0.72, y: 0.72, size: 56)
    ]

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Theme.orangeGradient)

                ForEach(bubbles) { bubble in
                    AvatarView(name: bubble.name, size: bubble.size)
                        .position(x: size.width * bubble.x, y: size.height * bubble.y)
                }

                VStack(spacing: -6) {
                    AvatarView(name: "Liam Chen", size: 88)
                        .overlay(Circle().stroke(.white, lineWidth: 4))
                    Label("92 match", systemImage: "star")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.ink)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.white, in: Capsule())
                }
                .position(x: size.width * 0.55, y: size.height * 0.42)

                VStack {
                    HStack {
                        Label("UniMate", systemImage: "sparkles")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Theme.ink, in: Capsule())
                        Spacer()
                        Text("Melbourne")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.ink)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Theme.peach, in: Capsule())
                    }
                    Spacer()
                    HStack {
                        HStack(spacing: 8) {
                            Circle().fill(Color.green).frame(width: 8, height: 8)
                            Text("2,400+ students active")
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Theme.ink, in: Capsule())
                        Spacer()
                    }
                }
                .padding(20)
            }
        }
        .frame(height: 320)
        .shadow(color: Theme.orange.opacity(0.25), radius: 20, y: 10)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("UniMate, Melbourne. Over 2,400 students active."))
    }
}

#Preview {
    NavigationStack { WelcomeView() }
}
