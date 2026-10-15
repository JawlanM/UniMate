import SwiftUI

enum MainTab: Hashable {
    case home, offers, profile
}

/// Home, Offers, (+), Profile, with the floating dark tab bar from the C1 design.
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
                        .foregroundStyle(UniColor.onApricot)
                        .frame(width: 56, height: 56)
                        .background(UniColor.apricot, in: Circle())
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .accessibilityLabel(Text("Post a job"))
                .accessibilityShowsLargeContentViewer {
                    Label("Post a job", systemImage: "plus")
                }
            }

            tabButton(.profile, title: "Profile", icon: "person")
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(UniColor.bar, in: Capsule())
        .lift()
        .padding(.horizontal, Space.screen)
        .padding(.bottom, 4)
        // Like the system tab bar: labels stop growing at a size that still fits,
        // and a long press shows the Large Content Viewer instead.
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
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
            .foregroundStyle(isSelected ? UniColor.onBar : UniColor.onBar.opacity(0.62))
            .frame(maxWidth: .infinity, minHeight: 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityShowsLargeContentViewer {
            Label(title, systemImage: icon)
        }
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
