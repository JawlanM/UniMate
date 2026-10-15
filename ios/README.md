# UniMate iOS

SwiftUI app. Currently has the sign-in flow, home screen and tab shell, using mock data.
iOS 17+, Xcode 15+.

## Running (on a Mac)

The Xcode project is `ios/PortfolioApp/PortfolioApp.xcodeproj`. All Swift code lives in
`ios/PortfolioApp/PortfolioApp/Sources/`. The project uses folder-synced groups, so new files
added there show up in Xcode automatically.

1. Open `PortfolioApp.xcodeproj` and run on an iPhone simulator (⌘R).
2. Fonts (one-time): go to Target → Info → add the key **Fonts provided by application**
   (`UIAppFonts`) with three items:
   `BricolageGrotesque-SemiBold.ttf`, `BricolageGrotesque-Bold.ttf`, `BricolageGrotesque-ExtraBold.ttf`.
   The files are in `PortfolioApp/Resources/Fonts`. If this step is skipped the app still runs,
   but headings fall back to SF Pro.
3. `ContentView.swift` is leftover Xcode template code and isn't used (the entry point is
   `Sources/App/UniMateApp.swift`). It can be deleted.

Design tokens and rules are in `DESIGN_SYSTEM.md`.

## Trying the mock login

| What | How |
|---|---|
| Sign in as a client | any valid email + any password with 8+ characters |
| Sign in as a freelancer | email starting with `work`, e.g. `work.liam@student.monash.edu` |
| "Email already taken" error | register with `taken@student.monash.edu` |
| Password reset code | `123456` |

## Structure

```
Sources/
  App/            entry point, RootView (auth ↔ tabs), MainTabView + custom tab bar
  DesignSystem/   tokens (colour, type, spacing, radius) and shared components
  Models/         AppUser, UserRole (matches backend JSON), mock home data
  Services/       AuthServicing protocol + MockAuthService, AppSession, Validation
  Features/       Auth (Welcome, SignIn, Register, ForgotPassword), Home, Matches (Recommendations, FreelancerProfile), Profile
../Resources/Fonts/   Bricolage Grotesque font files (OFL licence)
```

To connect the real backend later, write an `APIAuthService: AuthServicing` that calls
`/api/auth/*` with URLSession, and pass it in `UniMateApp.swift` instead of `MockAuthService()`.
