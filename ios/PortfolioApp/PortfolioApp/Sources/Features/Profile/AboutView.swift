import SwiftUI

/// What the app is, who made it, and what it's built with.
struct AboutView: View {
    private struct Credit: Identifiable {
        var id: String { name }
        let name: String
        let detail: String
    }

    private let acknowledgements: [Credit] = [
        Credit(name: "Bricolage Grotesque", detail: "Font by Mathieu Triay, SIL Open Font License 1.1"),
        Credit(name: "SF Symbols", detail: "Icons by Apple"),
        Credit(name: "ASP.NET Core", detail: "Web API framework, MIT License"),
        Credit(name: "Entity Framework Core", detail: "Database access, MIT License"),
        Credit(name: "Npgsql", detail: "PostgreSQL driver for .NET, PostgreSQL License"),
        Credit(name: "PostgreSQL", detail: "Database, PostgreSQL License"),
        Credit(name: "Swashbuckle", detail: "API documentation, MIT License")
    ]

    private var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.lg) {
                VStack(alignment: .leading, spacing: Space.xs) {
                    HStack(spacing: Space.xs) {
                        Image(systemName: "point.3.connected.trianglepath.dotted")
                            .foregroundStyle(UniColor.ember)
                            .accessibilityHidden(true)
                        Text("UniMate")
                            .font(UniFont.title)
                            .foregroundStyle(UniColor.ink)
                    }
                    Text("Version \(version)")
                        .font(.subheadline)
                        .foregroundStyle(UniColor.inkSecondary)
                }

                section(title: "What it does") {
                    Text("UniMate connects people who need a hand with short jobs, like moving, tutoring or tech help, with university students who want flexible paid work. Clients post jobs, students apply, and the client picks who does it.")
                        .fixedSize(horizontal: false, vertical: true)
                }

                section(title: "Made by") {
                    VStack(alignment: .leading, spacing: Space.xxs) {
                        Text("Maihemuti Jiewulan").fontWeight(.semibold)
                        Text("Student ID 34035176")
                        Text("FIT3178 iOS App Development, Monash University")
                            .foregroundStyle(UniColor.inkSecondary)
                    }
                }

                section(title: "Acknowledgements") {
                    VStack(alignment: .leading, spacing: Space.sm) {
                        ForEach(acknowledgements) { item in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name).fontWeight(.semibold)
                                Text(item.detail)
                                    .font(.subheadline)
                                    .foregroundStyle(UniColor.inkSecondary)
                            }
                            .accessibilityElement(children: .combine)
                        }
                    }
                }
            }
            .font(.body)
            .foregroundStyle(UniColor.ink)
            .padding(.horizontal, Space.screen)
            .padding(.vertical, Space.md)
            .readableWidth()
        }
        .screenBackground()
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Space.xs) {
            Text(title)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            content()
                .raisedSurface()
        }
    }
}

#Preview {
    NavigationStack { AboutView() }
}
