import SwiftUI

// Colours taken from the C1 v2 design (warm orange palette).
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

enum Theme {
    // Surfaces
    static let background = Color(hex: 0xFBF3EA)
    static let backgroundDeep = Color(hex: 0xF6E7D6)
    static let card = Color.white
    static let line = Color(hex: 0xEFE4D8)

    // Text
    static let ink = Color(hex: 0x17120F)
    static let muted = Color(hex: 0x8C8078)

    // Brand
    static let orange = Color(hex: 0xFF7A1A)
    static let orangeDark = Color(hex: 0xE8590C)
    static let peach = Color(hex: 0xFFE6D1)

    // Chip tints
    static let mint = Color(hex: 0xE2F4EA)
    static let mintText = Color(hex: 0x1F7A45)
    static let sky = Color(hex: 0xE3F0FF)
    static let skyText = Color(hex: 0x2459A8)
    static let lavender = Color(hex: 0xECE8FF)
    static let lavenderText = Color(hex: 0x5B45C9)
    static let rose = Color(hex: 0xFFE4E4)
    static let roseText = Color(hex: 0xC62828)

    static let backgroundGradient = LinearGradient(
        colors: [background, backgroundDeep],
        startPoint: .top,
        endPoint: .bottom
    )

    static let orangeGradient = LinearGradient(
        colors: [Color(hex: 0xFF9A3C), orange, Color(hex: 0xF76B10)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let softOrangeGradient = LinearGradient(
        colors: [Color(hex: 0xFFC48A), Color(hex: 0xFFA552)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Layout
    static let screenPadding: CGFloat = 24
    static let cardRadius: CGFloat = 28
    static let fieldRadius: CGFloat = 22
}

// Stable colour per name, so "Liam Chen" always gets the same avatar colour.
enum AvatarPalette {
    private static let colors: [Color] = [
        Color(hex: 0x3B82F6), Color(hex: 0xDB2777), Color(hex: 0x10B981),
        Color(hex: 0x0E9AA7), Color(hex: 0x7C4DFF), Color(hex: 0xF08C00),
        Color(hex: 0x4B5563)
    ]

    static func color(for name: String) -> Color {
        let sum = name.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return colors[sum % colors.count]
    }
}

// Page background used by every screen.
struct ScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        content.background(Theme.backgroundGradient.ignoresSafeArea())
    }
}

extension View {
    func screenBackground() -> some View { modifier(ScreenBackground()) }
}
