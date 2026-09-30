import SwiftUI

enum MainTab: Hashable {
    case home, offers, profile
}

/// Home · Offers · (+) · Profile, with the floating dark tab bar from the C1 design.
struct MainTabView: View {
    @Environment(AppSession.self) private var session
    @State private var selection: MainTab = .home
    @State private var isPostingJob = false

    private var canPostJobs: Bool { session.currentUser?.role == .client }

    var body: some View {
        Group {
            switch selection {
            case .home:
                NavigationStack { HomeView(onPostJob: { isPostingJob = true }) }
            case .offers:
                NavigationStack { PlaceholderScreen(title: "Offers", systemImage: "bubble.left.and.bubble.right", message: "Offers you send and receive will show up here.") }
            case .profile:
                NavigationStack { ProfileView() }
            }
        }
        .safeAreaInset(edge: .bottom) {
            UniTabBar(selection: $selection, showsPostButton: canPostJobs) {
                isPostingJob = true
            }
        }
        .sheet(isPresented: $isPostingJob) {
            NavigationStack {
                PlaceholderScreen(title: "Post a job", systemImage: "square.and.pencil", message: "Job posting comes next.")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") { isPostingJob = false }
                        }
                    }
            }
        }
    }
}

struct UniTabBar: View {
    @Binding var selection: MainTab
    var showsPostButton: Bool
    var onPost: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            tabButton(.home, title: "Home", icon: "house")
            tabButton(.offers, title: "Offers", icon: "bubble.left")

            if showsPostButton {
                Button(action: onPost) {
                    Image(systemName: "plus")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 60)
                        .background(Theme.orange, in: Circle())
                        .shadow(color: Theme.orange.opacity(0.5), radius: 12, y: 4)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .accessibilityLabel(Text("Post a job"))
            }

            tabButton(.profile, title: "Profile", icon: "person")
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(Theme.ink, in: Capsule())
        .shadow(color: .black.opacity(0.15), radius: 16, y: 6)
        .padding(.horizontal, Theme.screenPadding)
        .padding(.bottom, 4)
    }

    private func tabButton(_ tab: MainTab, title: String, icon: String) -> some View {
        let isSelected = selection == tab
        return Button {
            selection = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? "\(icon).fill" : icon)
                    .font(.title3)
                Text(title)
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(isSelected ? Color.white : Color.white.opacity(0.55))
            .frame(maxWidth: .infinity, minHeight: 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// Stand-in for screens that aren't built yet.
struct PlaceholderScreen: View {
    let title: String
    let systemImage: String
    let message: String

    var body: some View {
        ContentUnavailableView(title, systemImage: systemImage, description: Text(message))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .screenBackground()
            .navigationTitle(title)
    }
}

#Preview {
    MainTabView()
        .environment(AppSession.preview)
}
