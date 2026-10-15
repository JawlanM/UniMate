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
                    .foregroundStyle(UniColor.onInk)
            )
            .overlay {
                if outlined {
                    Circle().stroke(UniColor.canvas, lineWidth: max(2, size * 0.06))
                }
            }
            .accessibilityHidden(true)
    }
}

/// Overlapping avatars: "these students match". Used on Home and job rows.
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
    /// Match reasons and the brand moment. Wash background, ember text.
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

/// One reason a person matches, e.g. "1.4 km away". Strong reasons use the
/// brand tint; the rest stay neutral so the strong ones stand out.
struct MatchReasonChip: View {
    let reason: MatchReason

    var body: some View {
        Chip(text: reason.text, systemImage: reason.systemImage, style: reason.isStrong ? .brand : .neutral)
    }
}

// MARK: - Match score

/// Ring that fills to the score, always labelled "97% match" so it reads
/// without explanation. Large rings put the label inside, small ones below.
struct ScoreRing: View {
    let score: Int
    var size: CGFloat = 52
    var onDark = false
    /// "match" by default; "best match" where the ring summarises a group.
    var label = "match"

    private var lineWidth: CGFloat { max(4, size * 0.09) }
    private var fraction: CGFloat { CGFloat(min(max(score, 0), 100)) / 100 }
    private var labelInside: Bool { size >= 64 }
    private var textColor: Color { onDark ? UniColor.onInk : UniColor.ink }

    var body: some View {
        VStack(spacing: 3) {
            ZStack {
                Circle().stroke(onDark ? UniColor.onInk.opacity(0.18) : UniColor.apricotTrack, lineWidth: lineWidth)
                Circle()
                    .trim(from: 0, to: fraction)
                    .stroke(UniColor.apricot, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack(spacing: -2) {
                    Text("\(score)%")
                        .font(UniFont.score(size * (labelInside ? 0.27 : 0.29)))
                        .foregroundStyle(textColor)
                    if labelInside {
                        Text(label)
                            .font(.system(size: size * 0.14, weight: .semibold))
                            .foregroundStyle(onDark ? UniColor.onInk.opacity(0.75) : UniColor.inkSecondary)
                    }
                }
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .padding(lineWidth + 2)
            }
            .frame(width: size, height: size)

            if !labelInside {
                Text(label)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(onDark ? UniColor.onInk.opacity(0.75) : UniColor.inkSecondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(score)% \(label) for this job"))
    }
}

/// Avatar wrapped by its score ring. The profile header uses this.
struct ScoredAvatar: View {
    let name: String
    let score: Int
    var size: CGFloat = 112

    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                Circle().stroke(UniColor.apricotTrack, lineWidth: 6)
                Circle()
                    .trim(from: 0, to: CGFloat(score) / 100)
                    .stroke(UniColor.apricot, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                AvatarView(name: name, size: size - 22)
            }
            .frame(width: size, height: size)

            Text("\(score)% match")
                .font(UniFont.score(15))
                .foregroundStyle(UniColor.ink)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(UniColor.apricot, in: Capsule())
                .overlay(Capsule().stroke(UniColor.canvas, lineWidth: 3))
                .offset(y: 12)
        }
        .padding(.bottom, 12)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(name), \(score)% match for this job"))
    }
}

/// One factor of the score breakdown ("Distance, 1.4 km", 86 of 100).
struct ScoreFactorRow: View {
    let factor: MatchFactor

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Image(systemName: factor.systemImage)
                    .foregroundStyle(UniColor.ember)
                    .frame(width: 22)
                    .accessibilityHidden(true)
                Text(factor.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(UniColor.ink)
                Text(factor.detail)
                    .font(.subheadline)
                    .foregroundStyle(UniColor.inkSecondary)
                Spacer(minLength: 8)
                Text("\(factor.points)/\(factor.maxPoints)")
                    .font(.subheadline.weight(.semibold).monospacedDigit())
                    .foregroundStyle(UniColor.ink)
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(UniColor.apricotTrack)
                    Capsule()
                        .fill(UniColor.apricot)
                        .frame(width: proxy.size.width * CGFloat(factor.points) / CGFloat(max(factor.maxPoints, 1)))
                }
            }
            .frame(height: 6)
            .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Match orbit

/// Radar rings with students connected to a centre point. This is UniMate's
/// signature graphic: it appears on Welcome and Recommendations only.
struct OrbitNode: Identifiable {
    let id = UUID()
    let name: String
    /// Degrees, 0 = right, clockwise.
    let angle: Double
    /// 0 = centre, 1 = outer ring. Closer means a better match.
    let distance: CGFloat
    var size: CGFloat = 48
    var score: Int? = nil
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
                // Soft apricot glow: the closer to the centre, the stronger the match.
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
                    VStack(spacing: -8) {
                        AvatarView(name: node.name, size: node.size, outlined: true)
                        if let score = node.score {
                            Text("\(score)%")
                                .font(UniFont.score(13))
                                .foregroundStyle(UniColor.ink)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(UniColor.apricot, in: Capsule())
                        }
                    }
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
        let radians = node.angle * .pi / 180
        let r = maxR * node.distance
        return CGPoint(x: mid.x + cos(radians) * r, y: mid.y + sin(radians) * r)
    }
}

// MARK: - Rating

/// Five stars filled to the exact rating (4.8 fills 4.8 stars).
struct StarRow: View {
    let rating: Double
    var size: CGFloat = 16

    var body: some View {
        let stars = HStack(spacing: size * 0.15) {
            ForEach(0..<5, id: \.self) { _ in
                Image(systemName: "star.fill").font(.system(size: size))
            }
        }
        stars
            .foregroundStyle(UniColor.apricotTrack)
            .overlay(alignment: .leading) {
                GeometryReader { proxy in
                    stars
                        .foregroundStyle(UniColor.apricot)
                        .mask(alignment: .leading) {
                            Rectangle().frame(width: proxy.size.width * CGFloat(min(max(rating, 0), 5) / 5))
                        }
                }
            }
            .fixedSize()
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Rated \(rating, specifier: "%.1f") out of 5"))
    }
}

/// Compact rating for rows: star, number, review count. No reviews shows "New".
struct RatingBadge: View {
    let rating: Double?
    let reviewCount: Int

    var body: some View {
        if let rating, reviewCount > 0 {
            HStack(spacing: 3) {
                Image(systemName: "star.fill")
                    .imageScale(.small)
                    .foregroundStyle(UniColor.ember)
                Text("\(rating, specifier: "%.1f")")
                    .fontWeight(.semibold)
                    .foregroundStyle(UniColor.ink)
                    .monospacedDigit()
                Text("(\(reviewCount))")
                    .foregroundStyle(UniColor.inkSecondary)
            }
            .font(.subheadline)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Rated \(rating, specifier: "%.1f") from \(reviewCount) reviews"))
        } else {
            Chip(text: "New", systemImage: "sparkle", style: .brand)
                .accessibilityLabel(Text("New, no reviews yet"))
        }
    }
}

/// Profile rating block: big number, exact stars, count, and what people praise.
struct RatingSummary: View {
    let rating: Double?
    let reviewCount: Int
    let praise: [Praise]

    var body: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            if let rating, reviewCount > 0 {
                HStack(alignment: .center, spacing: Space.md) {
                    Text("\(rating, specifier: "%.1f")")
                        .font(UniFont.score(44))
                        .foregroundStyle(UniColor.ink)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: Space.xxs) {
                        StarRow(rating: rating, size: 18)
                        Text("From \(reviewCount) reviews")
                            .font(.subheadline)
                            .foregroundStyle(UniColor.inkSecondary)
                    }
                }
                if !praise.isEmpty {
                    VStack(alignment: .leading, spacing: Space.xs) {
                        Text("Clients mention")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(UniColor.inkSecondary)
                        FlowLayout(spacing: 6) {
                            ForEach(praise) { item in
                                HStack(spacing: 5) {
                                    Text(item.label)
                                    Text("\(item.count)")
                                        .monospacedDigit()
                                        .padding(.horizontal, 6)
                                        .background(UniColor.raised, in: Capsule())
                                }
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(UniColor.ink)
                                .padding(.leading, 10)
                                .padding(.trailing, 6)
                                .padding(.vertical, 6)
                                .background(UniColor.sunken, in: Capsule())
                                .accessibilityElement(children: .ignore)
                                .accessibilityLabel(Text("\(item.label), mentioned \(item.count) times"))
                            }
                        }
                    }
                }
            } else {
                HStack(spacing: Space.sm) {
                    StarRow(rating: 0, size: 18)
                    Text("No reviews yet. Ratings appear after the first completed job.")
                        .font(.subheadline)
                        .foregroundStyle(UniColor.inkSecondary)
                }
            }
        }
    }
}

// MARK: - Buttons

/// Near-black: the button that confirms (Sign in, Continue, Send offer).
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        StyledButton(configuration: configuration, fill: UniColor.ink, text: UniColor.onInk, outline: nil)
    }
}

/// Apricot: reserved for the matching action ("Find my matches").
struct BrandButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        StyledButton(configuration: configuration, fill: UniColor.apricot, text: UniColor.ink, outline: nil)
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
    enum Kind { case text, name, email, password, code }

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
