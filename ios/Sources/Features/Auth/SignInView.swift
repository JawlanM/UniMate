import SwiftUI

struct SignInView: View {
    @Environment(AppSession.self) private var session

    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    private var canSubmit: Bool {
        Validation.isValidEmail(email) && !password.isEmpty && !isLoading
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome back")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .foregroundStyle(Theme.ink)
                        .accessibilityAddTraits(.isHeader)
                    Text("Sign in with your student email.")
                        .foregroundStyle(Theme.muted)
                }
                .padding(.bottom, 12)

                LabeledInput(label: "Student email", text: $email, kind: .email)
                LabeledInput(label: "Password", text: $password, kind: .password)

                HStack {
                    Spacer()
                    NavigationLink(value: AuthRoute.forgotPassword) {
                        Text("Forgot password?")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.orangeDark)
                            .frame(minHeight: 44)
                    }
                }

                if let errorMessage {
                    ErrorBanner(message: errorMessage)
                }

                Button {
                    Task { await submit() }
                } label: {
                    if isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Sign in")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!canSubmit)

                InfoCard(
                    systemImage: "checkmark.shield",
                    title: "Only .edu.au emails",
                    message: "Every account belongs to a real student."
                )
                .padding(.top, 8)

                HStack(spacing: 4) {
                    Text("New to UniMate?")
                        .foregroundStyle(Theme.muted)
                    NavigationLink(value: AuthRoute.register) {
                        Text("Create account")
                            .fontWeight(.semibold)
                            .foregroundStyle(Theme.ink)
                    }
                }
                .font(.subheadline)
                .frame(maxWidth: .infinity, minHeight: 44)
                .padding(.top, 16)
            }
            .padding(Theme.screenPadding)
        }
        .scrollDismissesKeyboard(.interactively)
        .screenBackground()
        .navigationBarTitleDisplayMode(.inline)
        .onSubmit { if canSubmit { Task { await submit() } } }
    }

    private func submit() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            try await session.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack { SignInView() }
        .environment(AppSession(auth: MockAuthService()))
}
