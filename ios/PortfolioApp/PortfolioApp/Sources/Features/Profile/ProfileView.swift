import SwiftUI

struct ProfileView: View {
    @Environment(AppSession.self) private var session
    @State private var isConfirmingSignOut = false

    private var user: AppUser? { session.currentUser }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.lg) {
                Text("Profile")
                    .font(UniFont.largeTitle)
                    .foregroundStyle(UniColor.ink)
                    .accessibilityAddTraits(.isHeader)

                identityCard

                VStack(spacing: 0) {
                    MenuRow(title: "Edit profile", systemImage: "person")
                    Divider().overlay(UniColor.hairline)
                    MenuRow(title: "Skills and categories", systemImage: "bolt")
                    Divider().overlay(UniColor.hairline)
                    MenuRow(title: "Availability", systemImage: "calendar")
                    Divider().overlay(UniColor.hairline)
                    MenuRow(title: "Notifications", systemImage: "bell")
                    Divider().overlay(UniColor.hairline)

                    Button(role: .destructive) {
                        isConfirmingSignOut = true
                    } label: {
                        Label("Sign out", systemImage: "rectangle.portrait.and.arrow.right")
                            .font(.body.weight(.medium))
                            .foregroundStyle(UniColor.danger)
                            .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, Space.md)
                .raisedSurface(padding: 0)
            }
            .padding(.horizontal, Space.screen)
            .padding(.top, Space.xs)
            .padding(.bottom, Space.xl)
        }
        .screenBackground()
        .toolbar(.hidden, for: .navigationBar)
        .confirmationDialog("Sign out of UniMate?", isPresented: $isConfirmingSignOut, titleVisibility: .visible) {
            Button("Sign out", role: .destructive) { session.signOut() }
        }
    }

    private var identityCard: some View {
        VStack(spacing: Space.sm) {
            AvatarView(name: user?.fullName ?? "UniMate", size: 88)

            HStack(spacing: 6) {
                Text(user?.fullName ?? "")
                    .font(UniFont.title)
                    .foregroundStyle(UniColor.ink)
                if user?.isVerified == true {
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundStyle(UniColor.success)
                        .accessibilityLabel(Text("Verified student"))
                }
            }

            Text(user?.email ?? "")
                .font(.subheadline)
                .foregroundStyle(UniColor.inkSecondary)

            Chip(
                text: user?.role == .freelancer ? "Finding work" : "Finding help",
                systemImage: user?.role == .freelancer ? "briefcase" : "person.2",
                style: .brand
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Space.md)
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
                    .font(.body.weight(.semibold))
                    .foregroundStyle(UniColor.ember)
                    .frame(width: 28)
                    .accessibilityHidden(true)
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(UniColor.ink)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(UniColor.inkTertiary)
                    .accessibilityHidden(true)
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
