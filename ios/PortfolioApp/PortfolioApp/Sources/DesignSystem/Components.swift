import SwiftUI

// MARK: - Avatar

struct AvatarView: View {
    let name: String
    var size: CGFloat = 52
    /// Draws a canvas-coloured ring so overlapping avatars stay separate.
    var outlined = false

    private var initials: String {
        let letters = name.split(separator: " ").prefix(2).compactMap(\.first)
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
            .overlay {
                if outlined {
                    Circle().stroke(UniColor.canvas, lineWidth: max(2, size * 0.06))
                }
            }
            .accessibilityHidden(true)
    }
}

/// Overlapping avatars, e.g. the students who applied for a job.
struct AvatarStack: View {
    let names: [String]
    var size: CGFloat = 36
    var limit = 4

    var body: some View {
        HStack(spacing: -size * 0.22) {
            ForEach(Array(names.prefix(limit).enumerated()), id: \.offset) { index, name in
                AvatarView(name: name, size: size, outlined: true)
                    .zIndex(Double(limit - index))
            }
            if names.count > limit {
                Text("+\(names.count - limit)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(UniColor.ink)
                    .frame(width: size, height: size)
                    .background(UniColor.sunken, in: Circle())
                    .overlay(Circle().stroke(UniColor.canvas, lineWidth: 2))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(names.count) students"))
    }
}

// MARK: - Chips

enum ChipStyle {
    /// Default: quiet facts (time, price, university).
    case neutral
    /// The brand moment (open jobs, the role chip). Wash background, ember text.
    case brand
    case success
    case danger
    /// Selected state in a group of choices.
    case selected

    var background: Color {
        switch self {
        case .neutral: UniColor.sunken
        case .brand: UniColor.apricotWash
        case .success: UniColor.successWash
        case .danger: UniColor.dangerWash
        case .selected: UniColor.ink
        }
    }

    var foreground: Color {
        switch self {
        case .neutral: UniColor.ink
        case .brand: UniColor.ember
        case .success: UniColor.success
        case .danger: UniColor.danger
        case .selected: UniColor.onInk
        }
    }
}

struct Chip: View {
    let text: String
    var systemImage: String? = nil
    var style: ChipStyle = .neutral

    var body: some View {
        HStack(spacing: 5) {
            if let systemImage {
                Image(systemName: systemImage)
                    .imageScale(.small)
                    .accessibilityHidden(true)
            }
            Text(text)
        }
        .font(.footnote.weight(.semibold))
        .foregroundStyle(style.foreground)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(style.background, in: Capsule())
    }
}

// MARK: - Stat circle

/// A number in a soft apricot circle with a label under it ("$60 budget",
/// "3 applicants"). Fills the right side of job cards and rows.
struct StatCircle: View {
    let value: String
    let label: String
    var size: CGFloat = 52

    var body: some View {
        VStack(spacing: 3) {
            Text(value)
                .font(UniFont.numeral(size * 0.3))
                .foregroundStyle(UniColor.ink)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .padding(6)
                .frame(width: size, height: size)
                .background(UniColor.apricotWash, in: Circle())
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(UniColor.inkSecondary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(value) \(label)"))
    }
}

// MARK: - Match orbit

/// Radar rings with students connected to a centre point. This is UniMate's
/// signature graphic: it appears on Welcome only.
struct OrbitNode: Identifiable {
    let id = UUID()
    let name: String
    /// Degrees, 0 = right, clockwise.
    let angle: Double
    /// 0 = centre, 1 = outer ring.
    let distance: CGFloat
    var size: CGFloat = 48
}

struct MatchOrbit<Center: View>: View {
    let nodes: [OrbitNode]
    var onDark = false
    @ViewBuilder let center: () -> Center

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isShown = false

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            let mid = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
            let maxR = side / 2 - 30

            ZStack {
                // Soft apricot glow around the centre.
                RadialGradient(
                    colors: [UniColor.apricot.opacity(onDark ? 0.35 : 0.45), UniColor.apricot.opacity(0)],
                    center: .center, startRadius: 0, endRadius: maxR
                )
                .frame(width: maxR * 2, height: maxR * 2)
                .position(mid)

                ForEach([0.38, 0.69, 1.0], id: \.self) { fraction in
                    Circle()
                        .stroke(
                            onDark ? UniColor.onInk.opacity(0.16) : UniColor.hairline,
                            style: StrokeStyle(lineWidth: 1, dash: fraction == 1 ? [3, 5] : [])
                        )
                        .frame(width: maxR * 2 * fraction, height: maxR * 2 * fraction)
                        .position(mid)
                }

                ForEach(nodes) { node in
                    Path { path in
                        path.move(to: mid)
                        path.addLine(to: point(for: node, mid: mid, maxR: maxR))
                    }
                    .trim(from: 0, to: isShown ? 1 : 0)
                    .stroke(UniColor.ember.opacity(onDark ? 0.6 : 0.35), lineWidth: 1.2)
                }

                center().position(mid)

                ForEach(Array(nodes.enumerated()), id: \.element.id) { index, node in
                    AvatarView(name: node.name, size: node.size, outlined: true)
                        .position(point(for: node, mid: mid, maxR: maxR))
                        .opacity(isShown ? 1 : 0)
                        .scaleEffect(isShown ? 1 : 0.6)
                        .animation(
                            reduceMotion ? nil : .spring(duration: 0.5, bounce: 0.25).delay(0.15 + Double(index) * 0.07),
                            value: isShown
                        )
                }
            }
            .animation(reduceMotion ? nil : .easeOut(duration: 0.6), value: isShown)
        }
        .onAppear { isShown = true }
    }

    private func point(for node: OrbitNode, mid: CGPoint, maxR: CGFloat) -> CGPoint {
        let radians = CGFloat(node.angle) * .pi / 180
        let r = maxR * node.distance
        return CGPoint(x: mid.x + cos(radians) * r, y: mid.y + sin(radians) * r)
    }
}

// MARK: - Buttons

/// Near-black: the button that confirms (Sign in, Post job, Apply).
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        StyledButton(configuration: configuration, fill: UniColor.ink, text: UniColor.onInk, outline: nil)
    }
}

/// Apricot: the brand action. Not used by a screen yet.
struct BrandButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        StyledButton(configuration: configuration, fill: UniColor.apricot, text: UniColor.onApricot, outline: nil)
    }
}

/// Outlined: the alternative action next to a primary one.
struct SecondaryButtonStyle: ButtonStyle {
    var tint: Color = UniColor.ink

    func makeBody(configuration: Configuration) -> some View {
        StyledButton(configuration: configuration, fill: UniColor.raised, text: tint, outline: UniColor.hairline)
    }
}

private struct StyledButton: View {
    let configuration: ButtonStyleConfiguration
    let fill: Color
    let text: Color
    let outline: Color?
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(text)
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(fill, in: Capsule())
            .overlay {
                if let outline { Capsule().stroke(outline, lineWidth: 1.5) }
            }
            .opacity(isEnabled ? 1 : 0.4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
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
                .font(.body.weight(.semibold))
                .foregroundStyle(UniColor.ink)
                .frame(width: 44, height: 44)
                .background(UniColor.sunken, in: Circle())
                .overlay(alignment: .topTrailing) {
                    if showsBadge {
                        Circle()
                            .fill(UniColor.apricot)
                            .frame(width: 10, height: 10)
                            .overlay(Circle().stroke(UniColor.canvas, lineWidth: 2))
                            .offset(x: -9, y: 9)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(accessibilityText))
    }
}

// MARK: - Section header

struct SectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(UniFont.title2)
                .foregroundStyle(UniColor.ink)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(UniColor.ember)
                    .frame(minHeight: 44)
            }
        }
    }
}

// MARK: - Text input with a label above the value

struct LabeledInput: View {
    enum Kind { case text, name, email, password, code, decimal }

    let label: String
    @Binding var text: String
    var kind: Kind = .text

    @FocusState private var isFocused: Bool
    @State private var isRevealed = false

    var body: some View {
        HStack(spacing: Space.sm) {
            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(isFocused ? UniColor.ember : UniColor.inkSecondary)
                field
                    .font(.body)
                    .foregroundStyle(UniColor.ink)
                    .focused($isFocused)
            }

            if kind == .password {
                Button {
                    isRevealed.toggle()
                } label: {
                    Image(systemName: isRevealed ? "eye.slash" : "eye")
                        .foregroundStyle(UniColor.inkSecondary)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(isRevealed ? "Hide password" : "Show password"))
            }
        }
        .padding(.horizontal, Space.md)
        .padding(.vertical, 10)
        .frame(minHeight: 64)
        .background(UniColor.raised, in: RoundedRectangle(cornerRadius: Radius.control, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
                .stroke(isFocused ? UniColor.ember : UniColor.hairline, lineWidth: isFocused ? 2 : 1)
        )
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
        case .decimal:
            TextField("", text: $text)
                .keyboardType(.decimalPad)
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

// MARK: - Multi-line text input, same look as LabeledInput

struct LabeledTextEditor: View {
    let label: String
    @Binding var text: String
    var limit: Int? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(label)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(isFocused ? UniColor.ember : UniColor.inkSecondary)
                Spacer()
                if let limit {
                    Text("\(text.count)/\(limit)")
                        .font(.footnote.monospacedDigit())
                        .foregroundStyle(text.count > limit ? UniColor.danger : UniColor.inkSecondary)
                        .accessibilityLabel(Text("\(text.count) of \(limit) characters"))
                }
            }
            TextEditor(text: $text)
                .font(.body)
                .foregroundStyle(UniColor.ink)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 120)
                .focused($isFocused)
                .accessibilityLabel(Text(label))
        }
        .padding(.horizontal, Space.md)
        .padding(.vertical, 10)
        .background(UniColor.raised, in: RoundedRectangle(cornerRadius: Radius.control, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
                .stroke(isFocused ? UniColor.ember : UniColor.hairline, lineWidth: isFocused ? 2 : 1)
        )
        .animation(.easeOut(duration: 0.15), value: isFocused)
    }
}

/// Inline validation message under a field.
struct FieldError: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.footnote.weight(.medium))
            .foregroundStyle(UniColor.danger)
            .padding(.leading, Space.xxs)
    }
}

// MARK: - Feedback

struct ErrorBanner: View {
    let message: String

    var body: some View {
        Label(message, systemImage: "exclamationmark.circle.fill")
            .font(.subheadline.weight(.medium))
            .foregroundStyle(UniColor.danger)
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(UniColor.dangerWash, in: RoundedRectangle(cornerRadius: Radius.control, style: .continuous))
            .accessibilityElement(children: .combine)
    }
}

/// Quiet explanatory note: icon plus two lines, on the sunken colour.
struct InfoCard: View {
    let systemImage: String
    let title: String
    let message: String

    var body: some View {
        HStack(spacing: Space.sm) {
            Image(systemName: systemImage)
                .font(.body.weight(.semibold))
                .foregroundStyle(UniColor.ember)
                .frame(width: 40, height: 40)
                .background(UniColor.apricotWash, in: Circle())
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(UniColor.ink)
                Text(message).font(.footnote).foregroundStyle(UniColor.inkSecondary)
            }
        }
        .sunkenSurface(padding: 14, radius: Radius.card)
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
