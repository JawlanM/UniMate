import SwiftUI

/// Matches the planned API:
/// 1) POST /api/auth/forgot-password {email}          → always 202
/// 2) POST /api/auth/reset-password {email, code, newPassword} → 204
struct ForgotPasswordView: View {
    private enum Stage { case request, reset, done }

    @Environment(AppSession.self) private var session
    @Environment(\.dismiss) private var dismiss

    @State private var stage: Stage = .request
    @State private var email = ""
    @State private var code = ""
    @State private var newPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.md) {
                switch stage {
                case .request: requestStage
                case .reset: resetStage
                case .done: doneStage
                }
            }
            .padding(Space.screen)
            .animation(.easeInOut(duration: 0.25), value: stage)
        }
        .scrollDismissesKeyboard(.interactively)
        .screenBackground()
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Stages

    private var requestStage: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            header(title: "Reset password", subtitle: "Enter your student email and we'll send you a 6-digit code.")

            LabeledInput(label: "Student email", text: $email, kind: .email)

            if let errorMessage { ErrorBanner(message: errorMessage) }

            actionButton(title: "Send code", isEnabled: Validation.isValidEmail(email)) {
                try await session.requestPasswordReset(email: email)
                stage = .reset
            }
        }
    }

    private var resetStage: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            header(title: "Check your email", subtitle: "If an account exists for \(email.trimmed), a code is on its way. It expires in 15 minutes.")

            LabeledInput(label: "6-digit code", text: $code, kind: .code)
                .onChange(of: code) { _, newValue in
                    code = String(newValue.filter(\.isNumber).prefix(6))
                }
            LabeledInput(label: "New password", text: $newPassword, kind: .password)

            Text(Validation.passwordProblem(newPassword) ?? "Looks good.")
                .font(.footnote)
                .foregroundStyle(UniColor.inkSecondary)

            if let errorMessage { ErrorBanner(message: errorMessage) }

            actionButton(
                title: "Reset password",
                isEnabled: Validation.isValidResetCode(code) && Validation.passwordProblem(newPassword) == nil
            ) {
                try await session.resetPassword(email: email, code: code, newPassword: newPassword)
                stage = .done
            }

            Button("Send a new code") {
                code = ""
                errorMessage = nil
                stage = .request
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(UniColor.ember)
            .frame(maxWidth: .infinity, minHeight: 44)
        }
    }

    private var doneStage: some View {
        VStack(spacing: Space.lg) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(UniColor.success)
                .padding(.top, Space.xxl)
                .accessibilityHidden(true)
            Text("Password updated")
                .font(UniFont.title)
                .accessibilityAddTraits(.isHeader)
            Text("You can now sign in with your new password.")
                .foregroundStyle(UniColor.inkSecondary)
                .multilineTextAlignment(.center)
            Button("Back to sign in") { dismiss() }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.top, Space.sm)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Helpers

    private func header(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: Space.xs) {
            Text(title)
                .font(UniFont.largeTitle)
                .foregroundStyle(UniColor.ink)
                .accessibilityAddTraits(.isHeader)
            Text(subtitle)
                .foregroundStyle(UniColor.inkSecondary)
        }
        .padding(.bottom, Space.sm)
    }

    private func actionButton(title: String, isEnabled: Bool, action: @escaping () async throws -> Void) -> some View {
        Button {
            Task {
                errorMessage = nil
                isLoading = true
                defer { isLoading = false }
                do {
                    try await action()
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        } label: {
            if isLoading {
                ProgressView().tint(UniColor.onInk)
            } else {
                Text(title)
            }
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(!isEnabled || isLoading)
    }
}

#Preview {
    NavigationStack { ForgotPasswordView() }
        .environment(AppSession(auth: MockAuthService()))
}
