import SwiftUI

enum MainTab: Hashable {
    case home, myJobs, browse, myWork, reports, profile

    var title: String {
        switch self {
        case .home: "Home"
        case .myJobs: "My jobs"
        case .browse: "Browse"
        case .myWork: "My work"
        case .reports: "Reports"
        case .profile: "Profile"
        }
    }

    /// Outline SF Symbol; the selected tab uses the ".fill" version.
    var icon: String {
        switch self {
        case .home: "house"
        case .myJobs: "briefcase"
        case .browse: "magnifyingglass.circle"
        case .myWork: "tray"
        case .reports: "flag"
        case .profile: "person"
        }
    }

    /// Which tabs each role sees, left to right.
    static func tabs(for role: UserRole?) -> [MainTab] {
        switch role {
        case .freelancer: [.home, .browse, .myWork, .profile]
        case .admin: [.reports, .profile]
        default: [.home, .myJobs, .profile]
        }
    }
}

/// Role-based tabs with the floating dark tab bar from the C1 design.
/// Clients also get the (+) button, which opens Post a job.
struct MainTabView: View {
    @Environment(AppSession.self) private var session
    @State private var selection: MainTab?
    @State private var isPostingJob = false

    private var role: UserRole? { session.currentUser?.role }
    private var tabs: [MainTab] { MainTab.tabs(for: role) }
    private var currentTab: MainTab { selection ?? tabs[0] }

    var body: some View {
        Group {
            switch currentTab {
            case .home:
                NavigationStack {
                    HomeView(onPostJob: { isPostingJob = true }, onSelectTab: { selection = $0 })
                }
            case .myJobs:
                NavigationStack { JobListView(mode: .myJobs) }
            case .browse:
                NavigationStack { JobListView(mode: .browse) }
            case .myWork:
                NavigationStack { MyWorkView() }
            case .reports:
                NavigationStack { ReportsListView() }
            case .profile:
                NavigationStack { ProfileView() }
            }
        }
        .safeAreaInset(edge: .bottom) {
            UniTabBar(
                tabs: tabs,
                selection: Binding(get: { currentTab }, set: { selection = $0 }),
                showsPostButton: role == .client
            ) {
                isPostingJob = true
            }
        }
        .sheet(isPresented: $isPostingJob) {
            PostJobView()
        }
        // A different account can have a different set of tabs.
        .onChange(of: session.currentUser?.id) {
            selection = nil
        }
    }
}

struct UniTabBar: View {
    let tabs: [MainTab]
    @Binding var selection: MainTab
    var showsPostButton: Bool
    var onPost: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.element) { index, tab in
                // The (+) sits just before Profile.
                if showsPostButton && index == tabs.count - 1 {
                    postButton
                }
                tabButton(tab)
            }
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

    private var postButton: some View {
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

    private func tabButton(_ tab: MainTab) -> some View {
        let isSelected = selection == tab
        return Button {
            selection = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? "\(tab.icon).fill" : tab.icon)
                    .font(.title3)
                Text(tab.title)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? UniColor.onBar : UniColor.onBar.opacity(0.62))
            .frame(maxWidth: .infinity, minHeight: 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityShowsLargeContentViewer {
            Label(tab.title, systemImage: tab.icon)
        }
    }
}

#Preview("Client") {
    MainTabView()
        .environment(AppSession.preview)
}

#Preview("Freelancer") {
    MainTabView()
        .environment(AppSession.preview(as: .freelancer))
}

#Preview("Admin") {
    MainTabView()
        .environment(AppSession.preview(as: .admin))
}
