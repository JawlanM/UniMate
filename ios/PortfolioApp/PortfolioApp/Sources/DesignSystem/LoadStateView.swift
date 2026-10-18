import SwiftUI

/// What a screen that loads from the API is doing right now.
enum LoadState: Equatable {
    case loading
    case loaded
    case failed(String)
}

/// Shows a spinner, an error with Try again, an empty message, or the content.
/// Screens set `state` (and their data) and this view picks what to show.
struct LoadStateView<Content: View>: View {
    let state: LoadState
    let isEmpty: Bool
    let emptyTitle: String
    let emptySystemImage: String
    let emptyMessage: String
    let retry: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        switch state {
        case .loading:
            ProgressView("Loading…")
                .foregroundStyle(UniColor.inkSecondary)
                .frame(maxWidth: .infinity, minHeight: 280)
        case .failed(let message):
            ContentUnavailableView {
                Label("Couldn't load this", systemImage: "wifi.exclamationmark")
            } description: {
                Text(message)
            } actions: {
                Button("Try again", action: retry)
                    .buttonStyle(SecondaryButtonStyle())
                    .frame(maxWidth: 220)
            }
            .frame(maxWidth: .infinity, minHeight: 280)
        case .loaded:
            if isEmpty {
                ContentUnavailableView(emptyTitle, systemImage: emptySystemImage, description: Text(emptyMessage))
                    .frame(maxWidth: .infinity, minHeight: 280)
            } else {
                content()
            }
        }
    }
}
