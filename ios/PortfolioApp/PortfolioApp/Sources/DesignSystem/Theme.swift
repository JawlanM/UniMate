import SwiftUI

// UniMate design tokens. Every colour, font, spacing value and radius used by a
// screen should come from here. The reasoning behind each token is in
// ios/DESIGN_SYSTEM.md.

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

// MARK: - Colour

enum UniColor {
    // Surfaces, from back to front
    static let canvas = Color(hex: 0xFBF5EC)      // page background (warm cream)
    static let sunken = Color(hex: 0xF3EADD)      // grouped lists, tracks, quiet tiles
    static let raised = Color(hex: 0xFFFDF9)      // cards that sit above the page
    static let hairline = Color(hex: 0xE6D9CA)    // dividers and outlines

    // Text and icons
    static let ink = Color(hex: 0x211B16)          // titles, body, primary buttons (15.7:1 on canvas)
    static let inkSecondary = Color(hex: 0x6A5F55) // supporting text (5.7:1)
    static let inkTertiary = Color(hex: 0x877B70)  // placeholders, chevrons, disabled (icons only)
    static let onInk = Color.white

    // Brand. Apricot is a fill colour only: put ink on it, never white text.
    static let apricot = Color(hex: 0xFFA266)
    static let apricotWash = Color(hex: 0xFFEBDC)  // tinted chips, selected rows
    static let apricotTrack = Color(hex: 0xF6D9C2) // empty part of score rings and bars
    static let ember = Color(hex: 0xA9531C)        // orange text and icons (4.9:1 on canvas)

    // Semantic, only for success and destructive states
    static let success = Color(hex: 0x2E7A4E)
    static let successWash = Color(hex: 0xE4F1E8)
    static let danger = Color(hex: 0xB23A2A)
    static let dangerWash = Color(hex: 0xFBE6E1)
}

// Stable avatar colour per name, so "Liam Chen" always gets the same one.
// Avatars are the only place these hues appear.
enum AvatarPalette {
    static let green = Color(hex: 0x2F6B4F)
    static let purple = Color(hex: 0x5B3F8C)
    static let pink = Color(hex: 0x9C3D66)

    private static let colors = [green, purple, pink]

    static func color(for name: String) -> Color {
        let sum = name.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return colors[sum % colors.count]
    }
}

// MARK: - Typography

/// Bricolage Grotesque for display text and score numbers; SF Pro for everything
/// else. Custom sizes are tied to a text style so they follow Dynamic Type.
/// If the font files are missing, Font.custom falls back to SF Pro.
enum UniFont {
    private static let semibold = "BricolageGrotesque-SemiBold"
    private static let bold = "BricolageGrotesque-Bold"
    private static let extraBold = "BricolageGrotesque-ExtraBold"

    static let display = Font.custom(extraBold, size: 36, relativeTo: .largeTitle) // Welcome, screen heroes
    static let largeTitle = Font.custom(bold, size: 32, relativeTo: .largeTitle)   // top-level screen titles
    static let title = Font.custom(bold, size: 26, relativeTo: .title)             // pushed screen titles, names
    static let title2 = Font.custom(semibold, size: 21, relativeTo: .title2)       // section titles

    static let headline = Font.headline      // row titles
    static let body = Font.body
    static let callout = Font.callout
    static let subheadline = Font.subheadline
    static let footnote = Font.footnote
    static let caption = Font.caption.weight(.medium)

    /// Score numerals, scaled from the ring size.
    static func score(_ size: CGFloat) -> Font {
        Font.custom(extraBold, size: size, relativeTo: .headline).monospacedDigit()
    }
}

// MARK: - Spacing and shape

enum Space {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let screen: CGFloat = 20 // horizontal page margin
}

/// Radius grows with the size of the thing: small controls are tight,
/// large panels are soft. Buttons and chips are always capsules.
enum Radius {
    static let control: CGFloat = 14 // text fields, small tiles
    static let card: CGFloat = 20    // cards, grouped lists
    static let panel: CGFloat = 28   // hero panels, sheets
}

// MARK: - Elevation

/// Only things that float above the page get a shadow (tab bar, top match,
/// sheets). Everything else is separated by colour or a hairline.
struct LiftShadow: ViewModifier {
    func body(content: Content) -> some View {
        content.shadow(color: Color(hex: 0x46280F, opacity: 0.10), radius: 18, y: 8)
    }
}

// MARK: - Surfaces

extension View {
    /// Flat cream page background.
    func screenBackground() -> some View {
        background(UniColor.canvas.ignoresSafeArea())
    }

    func lift() -> some View { modifier(LiftShadow()) }

    /// A card that sits above the page: raised colour, hairline, no shadow.
    func raisedSurface(padding: CGFloat = Space.md, radius: CGFloat = Radius.card) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(UniColor.raised, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: radius, style: .continuous).stroke(UniColor.hairline, lineWidth: 1))
    }

    /// A recessed area for grouped rows or quiet tiles.
    func sunkenSurface(padding: CGFloat = Space.md, radius: CGFloat = Radius.card) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(UniColor.sunken, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}
