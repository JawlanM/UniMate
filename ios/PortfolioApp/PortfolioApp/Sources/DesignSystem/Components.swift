import SwiftUI

// MARK: - Avatar

struct AvatarView: View {
    let name: String
    var size: CGFloat = 56

    private var initials: String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }

    var body: some View {
        Circle()
            .fill(AvatarPalette.color(for: name))
            .frame(width: size, height: size)
            .overlay(
                Text(initials)
                    .font(.system(size: size * 0.36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            )
            .accessibilityHidden(true)
    }
}

// MARK: - Chip

enum ChipStyle {
    case orange, green, blue, purple, red, dark

    var background: Color {
        switch self {
        case .orange: Theme.peach
        case .green: Theme.mint
        case .blue: Theme.sky
        case .purple: Theme.lavender
        case .red: Theme.rose
        case .dark: Theme.ink
        }
    }

    var foreground: Color {
        switch self {
        case .orange: Theme.orangeDark
        case .green: Theme.mintText
        case .blue: Theme.skyText
        case .purple: Theme.lavenderText
        case .red: Theme.roseText
        case .dark: .white
        }
    }
}

struct Chip: View {
    let text: String
    var systemImage: String? = nil
    var style: ChipStyle = .orange

    var body: some View {
        HStack(spacing: 6) {
            if let systemImage {
                Image(systemName: systemImage)
            }
            Text(text)
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(style.foreground)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(style.background, in: Capsule())
    }
}

// MARK: - Match score ring

struct ScoreRing: View {
    let score: Int
    var size: CGFloat = 56

    var body: some View {
        ZStack {
            Circle().stroke(Theme.peach, lineWidth: 5)
            Circle()
                .trim(from: 0, to: CGFloat(min(max(score, 0), 100)) / 100)
                .stroke(Theme.orange, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(score)")
                .font(.system(size: size * 0.32, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.ink)
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Match score \(score) out of 100"))
    }
}

// MARK: - Buttons

struct PrimaryButtonStyle: ButtonStyle {
    var color: Color = Theme.ink

    func makeBody(configuration: Configuration) -> some View {
        PrimaryButton(configuration: configuration, color: color)
    }

    private struct PrimaryButton: View {
        let configuration: ButtonStyleConfiguration
        let color: Color
        @Environment(\.isEnabled) private var isEnabled

        var body: some View {
            configuration.label
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(color, in: Capsule())
                .opacity(isEnabled ? (configuration.isPressed ? 0.85 : 1) : 0.4)
                .scaleEffect(configuration.isPressed ? 0.98 : 1)
                .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
        }
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(Theme.ink)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(Theme.card, in: Capsule())
            .overlay(Capsule().stroke(Theme.line, lineWidth: 1))
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

struct CircleIconButton: View {
    let systemImage: String
    let accessibilityText: String
    var showsBadge = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.title3.weight(.medium))
                .foregroundStyle(Theme.ink)
                .frame(width: 52, height: 52)
                .background(Theme.card.opacity(0.85), in: Circle())
                .overlay(alignment: .topTrailing) {
                    if showsBadge {
                        Circle().fill(Theme.orange).frame(width: 10, height: 10).offset(x: -13, y: 13)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(accessibilityText))
    }
}

// MARK: - Card

struct CardBackground: ViewModifier {
    var padding: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))
            .shadow(color: Theme.orange.opacity(0.07), radius: 14, y: 6)
    }
}

extension View {
    func card(padding: CGFloat = 20) -> some View { modifier(CardBackground(padding: padding)) }
}

// MARK: - Text input with a floating label (matches the C1 field style)

struct LabeledInput: View {
    enum Kind { case text, name, email, password, code }

    let label: String
    @Binding var text: String
    var kind: Kind = .text

    @FocusState private var isFocused: Bool
    @State private var isRevealed = false

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Theme.muted)
                field
                    .font(.body)
                    .foregroundStyle(Theme.ink)
                    .focused($isFocused)
            }

            if kind == .password {
                Button {
                    isRevealed.toggle()
                } label: {
                    Image(systemName: isRevealed ? "eye.slash" : "eye")
                        .foregroundStyle(Theme.muted)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(isRevealed ? "Hide password" : "Show password"))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .frame(minHeight: 68)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.fieldRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.fieldRadius, style: .continuous)
                .stroke(isFocused ? Theme.orange : Theme.line, lineWidth: isFocused ? 2 : 1)
        )
        .shadow(color: isFocused ? Theme.orange.opacity(0.18) : .clear, radius: 8)
        .contentShape(Rectangle())
        .onTapGesture { isFocused = true }
        .animation(.easeOut(duration: 0.15), value: isFocused)
    }

    @ViewBuilder
    private var field: some View {
        switch kind {
        case .text:
            TextField("", text: $text)
                .accessibilityLabel(Text(label))
        case .name:
            TextField("", text: $text)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .accessibilityLabel(Text(label))
        case .email:
            TextField("", text: $text)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityLabel(Text(label))
        case .code:
            TextField("", text: $text)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .accessibilityLabel(Text(label))
        case .password:
            Group {
                if isRevealed {
                    TextField("", text: $text)
                } else {
                    SecureField("", text: $text)
                }
            }
            .textContentType(.password)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .accessibilityLabel(Text(label))
        }
    }
}

// MARK: - Feedback

struct ErrorBanner: View {
    let message: String

    var body: some View {
        Label(message, systemImage: "exclamationmark.circle.fill")
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Theme.roseText)
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.rose, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .accessibilityElement(children: .combine)
    }
}

struct InfoCard: View {
    let systemImage: String
    let title: String
    let message: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(Theme.orangeDark)
                .frame(width: 52, height: 52)
                .background(Theme.peach, in: Circle())
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline).foregroundStyle(Theme.ink)
                Text(message).font(.subheadline).foregroundStyle(Theme.muted)
            }
        }
        .card()
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Flow layout (wraps chips onto new lines on narrow screens)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var widest: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0, x + size.width > maxWidth {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            widest = max(widest, x - spacing)
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: widest, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > bounds.minX, x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
