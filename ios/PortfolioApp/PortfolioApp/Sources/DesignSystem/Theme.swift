import SwiftUI
import UIKit

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

    /// A colour with a Light Mode and a Dark Mode value. iOS picks the right one
    /// and updates it automatically when the user changes appearance.
    nonisolated static func adaptive(light: UInt32, dark: UInt32) -> Color {
        Color(UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

extension UIColor {
    nonisolated convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}

// MARK: - Colour

enum UniColor {
    // Surfaces, from back to front
    static let canvas = Color.adaptive(light: 0xFBF5EC, dark: 0x17130F)   // page background
    static let sunken = Color.adaptive(light: 0xF3EADD, dark: 0x221C17)   // grouped lists, tracks, quiet tiles
    static let raised = Color.adaptive(light: 0xFFFDF9, dark: 0x2A231D)   // cards that sit above the page
    static let hairline = Color.adaptive(light: 0xE6D9CA, dark: 0x3D342C) // dividers and outlines

    // Text and icons. In Dark Mode ink becomes a warm off-white.
    static let ink = Color.adaptive(light: 0x211B16, dark: 0xF6EEE4)
    static let inkSecondary = Color.adaptive(light: 0x6A5F55, dark: 0xC2B5A8)
    static let inkTertiary = Color.adaptive(light: 0x877B70, dark: 0x8F8377)  // icons only
    static let onInk = Color.adaptive(light: 0xFFFFFF, dark: 0x17130F)        // text on an ink fill (primary button)

    // Floating tab bar: stays dark in both modes, lifted slightly in Dark Mode.
    static let bar = Color.adaptive(light: 0x211B16, dark: 0x2E2620)
    static let onBar = Color.white

    // Brand. Apricot is light in both modes, so content on it is always dark.
    static let apricot = Color(hex: 0xFFA266)
    static let onApricot = Color(hex: 0x211B16)
    static let apricotWash = Color.adaptive(light: 0xFFEBDC, dark: 0x3B2819)  // tinted chips, selected rows
    static let apricotTrack = Color.adaptive(light: 0xF6D9C2, dark: 0x4A3423) // empty part of bars
    static let ember = Color.adaptive(light: 0xA9531C, dark: 0xF29A5E)        // orange text and icons

    // Semantic, only for success and destructive states
    static let success = Color.adaptive(light: 0x2E7A4E, dark: 0x6CC892)
    static let successWash = Color.adaptive(light: 0xE4F1E8, dark: 0x16301F)
    static let danger = Color.adaptive(light: 0xB23A2A, dark: 0xF0806E)
    static let dangerWash = Color.adaptive(light: 0xFBE6E1, dark: 0x3A1C17)
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
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        // A brown shadow disappears on a dark page, so Dark Mode uses a stronger black one.
        content.shadow(
            color: colorScheme == .dark ? Color.black.opacity(0.45) : Color(hex: 0x46280F, opacity: 0.10),
            radius: 18,
            y: 8
        )
    }
}

// MARK: - Surfaces

extension View {
    /// Flat cream page background.
    func screenBackground() -> some View {
        background(UniColor.canvas.ignoresSafeArea())
    }

    func lift() -> some View { modifier(LiftShadow()) }

    /// Keeps content at a comfortable reading width in landscape and on iPad,
    /// centred on the screen instead of stretched edge to edge.
    func readableWidth(_ maxWidth: CGFloat = 640) -> some View {
        frame(maxWidth: maxWidth, alignment: .leading)
            .frame(maxWidth: .infinity)
    }

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
