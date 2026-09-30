# UniMate iOS

SwiftUI app. Currently has the sign-in flow, home screen and tab shell, using mock data.
iOS 17+, Xcode 15+.

## First-time setup (on a Mac)

1. Xcode → File → New → Project → iOS **App**.
   - Product Name: `UniMate`
   - Interface: SwiftUI, Language: Swift, Storage: None
   - Save it inside this `ios/` folder.
2. In the new project, delete `ContentView.swift` and `UniMateApp.swift` (Move to Trash).
3. Drag the `ios/Sources` folder into the project navigator, under the UniMate group.
   Tick "Copy items if needed" **off**, choose "Create groups", and tick the UniMate target.
4. Target → General → Minimum Deployments → iOS **17.0**.
5. Run on an iPhone simulator (⌘R).

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
  DesignSystem/   Theme colours, buttons, inputs, chips, cards, FlowLayout
  Models/         AppUser, UserRole (matches backend JSON), mock home data
  Services/       AuthServicing protocol + MockAuthService, AppSession, Validation
  Features/       Auth (Welcome, SignIn, Register, ForgotPassword), Home, Profile
```

To connect the real backend later, write an `APIAuthService: AuthServicing` that calls
`/api/auth/*` with URLSession, and pass it in `UniMateApp.swift` instead of `MockAuthService()`.
