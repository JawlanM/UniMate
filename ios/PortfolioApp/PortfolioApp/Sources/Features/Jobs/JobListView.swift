import SwiftUI

/// One list screen for two tabs: a client's My Jobs and a freelancer's Browse.
struct JobListView: View {
    enum Mode {
        case myJobs, browse
    }

    let mode: Mode

    @State private var state: LoadState = .loaded
    @State private var jobs: [Job]
    @State private var categories: [Category] = SampleData.categories
    /// nil means "All".
    @State private var selectedCategoryId: Int?

    init(mode: Mode) {
        self.mode = mode
        // TODO: start with [] and fill `jobs` from the API in load().
        _jobs = State(initialValue: mode == .browse ? SampleData.openJobs : SampleData.myJobs)
    }

    private var visibleJobs: [Job] {
        guard let selectedCategoryId else { return jobs }
        return jobs.filter { $0.categoryId == selectedCategoryId }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.lg) {
                VStack(alignment: .leading, spacing: Space.xxs) {
                    Text(mode == .browse ? "Browse jobs" : "My jobs")
                        .font(UniFont.largeTitle)
                        .foregroundStyle(UniColor.ink)
                        .accessibilityAddTraits(.isHeader)
                    Text(mode == .browse ? "Open jobs from students and locals." : "Jobs you've posted, newest first.")
                        .font(.subheadline)
                        .foregroundStyle(UniColor.inkSecondary)
                }

                if mode == .browse {
                    categoryFilter
                }

                LoadStateView(
                    state: state,
                    isEmpty: visibleJobs.isEmpty,
                    emptyTitle: mode == .browse ? "No open jobs" : "No jobs yet",
                    emptySystemImage: "briefcase",
                    emptyMessage: mode == .browse
                        ? "Nothing in this category right now. Pull down to check again."
                        : "Tap + to post your first job.",
                    retry: { Task { await load() } }
                ) {
                    JobList(jobs: visibleJobs, showsClient: mode == .browse)
                }
            }
            .padding(.horizontal, Space.screen)
            .padding(.top, Space.xs)
            .padding(.bottom, Space.xl)
            .readableWidth()
        }
        .refreshable { await load() }
        .task { await load() }
        .screenBackground()
        .toolbar(.hidden, for: .navigationBar)
        .jobNavigation()
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Space.xs) {
                filterChip(title: "All", systemImage: nil, id: nil)
                ForEach(categories) { category in
                    filterChip(title: category.name, systemImage: category.iconName, id: category.id)
                }
            }
        }
        // TODO: if the API filters by category, call load() when this changes.
        .onChange(of: selectedCategoryId) { }
    }

    private func filterChip(title: String, systemImage: String?, id: Int?) -> some View {
        let isSelected = selectedCategoryId == id
        return Button {
            selectedCategoryId = id
        } label: {
            Chip(text: title, systemImage: systemImage, style: isSelected ? .selected : .neutral)
                .frame(minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func load() async {
        // TODO: load from the API.
        // Set state = .loading, fetch the jobs (and categories for Browse),
        // then state = .loaded, or state = .failed(error.localizedDescription).
    }
}

#Preview("Browse") {
    NavigationStack { JobListView(mode: .browse) }
        .environment(AppSession.preview(as: .freelancer))
}

#Preview("My jobs") {
    NavigationStack { JobListView(mode: .myJobs) }
        .environment(AppSession.preview)
}
