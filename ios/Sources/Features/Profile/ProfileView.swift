import SwiftUI

struct ProfileView: View {
    @Environment(AppSession.self) private var session
    @State private var isConfirmingSignOut = false

    private var user: AppUser? { session.currentUser }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Profile")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(Theme.ink)
                    .accessibilityAddTraits(.isHeader)

                identityCard

                VStack(spacing: 0) {
                    MenuRow(title: "Edit profile", systemImage: "person")
                    Divider().overlay(Theme.line)
                    MenuRow(title: "Skills & categories", systemImage: "bolt")
                    Divider().overlay(Theme.line)
                    MenuRow(title: "Availability", systemImage: "calendar")
                    Divider().overlay(Theme.line)
                    MenuRow(title: "Notifications", systemImage: "bell")
                    Divider().overlay(Theme.line)

                    Button(role: .destructive) {
                        isConfirmingSignOut = true
                    } label: {
                        Label("Sign out", systemImage: "rectangle.portrait.and.arrow.right")
                            .font(.body.weight(.medium))
                            .foregroundStyle(Theme.roseText)
                            .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }
                .card(padding: 16)
            }
            .padding(.horizontal, Theme.screenPadding)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .screenBackground()
        .toolbar(.hidden, for: .navigationBar)
        .confirmationDialog("Sign out of UniMate?", isPresented: $isConfirmingSignOut, titleVisibility: .visible) {
            Button("Sign out", role: .destructive) { session.signOut() }
        }
    }

    private var identityCard: some View {
        VStack(spacing: 12) {
            AvatarView(name: user?.fullName ?? "UniMate", size: 96)

            HStack(spacing: 6) {
                Text(user?.fullName ?? "")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Theme.ink)
                if user?.isVerified == true {
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundStyle(Theme.mintText)
                        .accessibilityLabel(Text("Verified student"))
                }
            }

            Text(user?.email ?? "")
                .font(.subheadline)
                .foregroundStyle(Theme.muted)

            Chip(
                text: user?.role == .freelancer ? "Finding work" : "Finding help",
                systemImage: user?.role == .freelancer ? "briefcase" : "person.2",
                style: .orange
            )
        }
        .frame(maxWidth: .infinity)
        .card(padding: 24)
    }
}

private struct MenuRow: View {
    let title: String
    let systemImage: String

    var body: some View {
        NavigationLink {
            PlaceholderScreen(title: title, systemImage: systemImage, message: "Coming soon.")
        } label: {
            HStack(spacing: 16) {
                Image(systemName: systemImage)
                    .font(.title3)
                    .foregroundStyle(Theme.orangeDark)
                    .frame(width: 28)
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(Theme.ink)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.muted)
            }
            .frame(minHeight: 56)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack { ProfileView() }
        .environment(AppSession.preview)
}
