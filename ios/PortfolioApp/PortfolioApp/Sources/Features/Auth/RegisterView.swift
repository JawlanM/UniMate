import SwiftUI

/// Two steps: 1) what you want to do (role), 2) your details.
struct RegisterView: View {
    @Environment(AppSession.self) private var session

    @State private var step = 1
    @State private var role: UserRole = .client
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showProblems = false
    @State private var errorMessage: String?

    private var formProblem: String? {
        if firstName.trimmed.isEmpty || lastName.trimmed.isEmpty {
            return "Enter your first and last name."
        }
        if !Validation.isValidEmail(email) {
            return "Enter a valid email address."
        }
        return Validation.passwordProblem(password)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.md) {
                StepIndicator(current: step, total: 2)

                if step == 1 {
                    roleStep
                        .transition(.move(edge: .leading).combined(with: .opacity))
                } else {
                    detailsStep
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .padding(Space.screen)
            .animation(.easeInOut(duration: 0.25), value: step)
        }
        .scrollDismissesKeyboard(.interactively)
        .screenBackground()
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(step == 2)
        .toolbar {
            if step == 2 {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        step = 1
                    } label: {
                        Label("Back", systemImage: "chevron.left")
                    }
                }
            }
        }
    }

    // MARK: Step 1

    private var roleStep: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            header(title: "What brings you here?", subtitle: "You can change this later in your profile.")

            RoleOptionCard(
                title: "Find help",
                message: "Post tasks and get matched with students nearby.",
                systemImage: "person.2",
                isSelected: role == .client
            ) { role = .client }

            RoleOptionCard(
                title: "Find work",
                message: "Pick up paid tasks that fit your skills and timetable.",
                systemImage: "briefcase",
                isSelected: role == .freelancer
            ) { role = .freelancer }

            Button("Continue") { step = 2 }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.top, Space.xs)
        }
    }

    // MARK: Step 2

    private var detailsStep: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            header(title: "Create your account", subtitle: "Use your university email so others know you're a student.")

            // Side by side on wide screens, stacked when text is large.
            ViewThatFits(in: .horizontal) {
                HStack(spacing: Space.sm) {
                    LabeledInput(label: "First name", text: $firstName, kind: .name)
                    LabeledInput(label: "Last name", text: $lastName, kind: .name)
                }
                VStack(spacing: Space.md) {
                    LabeledInput(label: "First name", text: $firstName, kind: .name)
                    LabeledInput(label: "Last name", text: $lastName, kind: .name)
                }
            }

            LabeledInput(label: "Student email", text: $email, kind: .email)
            LabeledInput(label: "Password", text: $password, kind: .password)

            Text("At least 8 characters, with a letter and a number.")
                .font(.footnote)
                .foregroundStyle(UniColor.inkSecondary)

            if let message = errorMessage ?? (showProblems ? formProblem : nil) {
                ErrorBanner(message: message)
            }

            Button {
                Task { await submit() }
            } label: {
                if isLoading {
                    ProgressView().tint(UniColor.onInk)
                } else {
                    Text("Create account")
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(isLoading)
            .padding(.top, Space.xs)

            Text("By creating an account you agree to keep UniMate a safe, respectful student community.")
                .font(.footnote)
                .foregroundStyle(UniColor.inkSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
    }

    private func header(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: Space.xs) {
            Text(title)
                .font(UniFont.largeTitle)
                .foregroundStyle(UniColor.ink)
                .accessibilityAddTraits(.isHeader)
            Text(subtitle)
                .foregroundStyle(UniColor.inkSecondary)
        }
        .padding(.bottom, Space.xs)
    }

    private func submit() async {
        errorMessage = nil
        showProblems = true
        guard formProblem == nil else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            try await session.register(
                RegistrationRequest(
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    password: password,
                    role: role
                )
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct StepIndicator: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: Space.xs) {
            ForEach(1...total, id: \.self) { index in
                Capsule()
                    .fill(index <= current ? UniColor.apricot : UniColor.hairline)
                    .frame(height: 6)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Step \(current) of \(total)"))
    }
}

private struct RoleOptionCard: View {
    let title: String
    let message: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Space.md) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundStyle(isSelected ? UniColor.ink : UniColor.ember)
                    .frame(width: 52, height: 52)
                    .background(isSelected ? UniColor.apricot : UniColor.apricotWash, in: Circle())
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: Space.xxs) {
                    Text(title).font(.headline).foregroundStyle(UniColor.ink)
                    Text(message).font(.subheadline).foregroundStyle(UniColor.inkSecondary)
                }
                .multilineTextAlignment(.leading)

                Spacer(minLength: 0)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isSelected ? UniColor.ink : UniColor.inkTertiary)
            }
            .padding(Space.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? UniColor.raised : UniColor.sunken, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                    .stroke(isSelected ? UniColor.apricot : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

#Preview {
    NavigationStack { RegisterView() }
        .environment(AppSession(auth: MockAuthService()))
}
