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
                    MenuRow(title: "About UniMate", systemImage: "info.circle") {
                        AboutView()
                    }
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
            .readableWidth()
        }
        .screenBackground()
        .toolbar(.hidden, for: .navigationBar)
        .confirmationDialog("Sign out of UniMate?", isPresented: $isConfirmingSignOut, titleVisibility: .visible) {
            Button("Sign out", role: .destructive) { session.signOut() }
        }
    }

    private var roleText: String {
        switch user?.role {
        case .freelancer: "Finding work"
        case .admin: "Administrator"
        default: "Finding help"
        }
    }

    private var roleIcon: String {
        switch user?.role {
        case .freelancer: "briefcase"
        case .admin: "checkmark.shield"
        default: "person.2"
        }
    }

    private var identityCard: some View {
        VStack(spacing: Space.sm) {
            AvatarView(name: user?.fullName ?? "UniMate", size: 88)

            Text(user?.fullName ?? "")
                .font(UniFont.title)
                .foregroundStyle(UniColor.ink)

            Text(user?.email ?? "")
                .font(.subheadline)
                .foregroundStyle(UniColor.inkSecondary)

            Chip(text: roleText, systemImage: roleIcon, style: .brand)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Space.md)
    }
}

private struct MenuRow<Destination: View>: View {
    let title: String
    let systemImage: String
    @ViewBuilder let destination: () -> Destination

    var body: some View {
        NavigationLink {
            destination()
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
