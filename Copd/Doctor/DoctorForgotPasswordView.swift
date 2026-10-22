import SwiftUI

struct DoctorForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var doctorId: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""

    @State private var isLoading = false
    @State private var isDoctorVerified = false
    @State private var message: String = ""
    @State private var messageStatus: BTStatusBadge.Status = .error

    @State private var contentVisible = false

    var body: some View {
        ZStack {
            Color.btBackground.ignoresSafeArea()

            // Purple top decoration (matches doctor login)
            GeometryReader { geo in
                Ellipse()
                    .fill(LinearGradient.btDoctorGradient)
                    .frame(width: geo.size.width * 1.4, height: 300)
                    .offset(x: -geo.size.width * 0.2, y: -150)
                    .opacity(0.12)
            }.ignoresSafeArea()

            VStack(spacing: 0) {
                // Nav bar
                HStack {
                    BTBackButton(action: { dismiss() })
                    Spacer()
                    Text("Reset Password")
                        .font(.btHeadline)
                        .foregroundColor(.btTextPrimary)
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.md)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Header icon
                        VStack(alignment: .center, spacing: Spacing.xs) {
                            ZStack {
                                Circle()
                                    .fill(Color.btDoctorPrimary.opacity(0.1))
                                    .frame(width: 80, height: 80)
                                Image(systemName: "lock.rotation")
                                    .font(.system(size: 32))
                                    .foregroundStyle(LinearGradient.btDoctorGradient)
                            }
                            .padding(.bottom, Spacing.sm)

                            Text("Forgot Password?")
                                .font(.btTitle2)
                                .foregroundColor(.btTextPrimary)

                            Text(isDoctorVerified
                                 ? "ID Verified! Set your new password."
                                 : "Enter your Doctor ID to verify your identity.")
                                .font(.btBody)
                                .foregroundColor(.btTextSecond)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, Spacing.xl)
                        }
                        .padding(.top, Spacing.xl)
                        .opacity(contentVisible ? 1 : 0)
                        .scaleEffect(contentVisible ? 1 : 0.9)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: contentVisible)

                        // Form
                        VStack(spacing: Spacing.md) {
                            BTInputField(
                                placeholder: "Doctor ID (doc_xxx)",
                                icon: "person.text.rectangle.fill",
                                text: $doctorId
                            )
                            .disabled(isDoctorVerified)
                            .opacity(isDoctorVerified ? 0.6 : 1.0)

                            if isDoctorVerified {
                                Divider()
                                    .padding(.vertical, Spacing.sm)
                                    .transition(.opacity)

                                BTInputField(
                                    placeholder: "New Password",
                                    icon: "lock.fill",
                                    text: $newPassword,
                                    isSecure: true
                                )
                                .transition(.move(edge: .top).combined(with: .opacity))

                                BTInputField(
                                    placeholder: "Confirm New Password",
                                    icon: "lock.square.fill",
                                    text: $confirmPassword,
                                    isSecure: true
                                )
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.xl)
                        .opacity(contentVisible ? 1 : 0)
                        .offset(y: contentVisible ? 0 : 16)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: contentVisible)

                        // Status message
                        if !message.isEmpty {
                            BTStatusBadge(message: message, status: messageStatus)
                                .padding(.horizontal, Spacing.lg)
                                .padding(.top, Spacing.md)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        // Action button (doctor purple gradient)
                        if !isDoctorVerified {
                            BTPrimaryButton(
                                title: "Verify Doctor ID",
                                icon: "magnifyingglass",
                                gradient: LinearGradient.btDoctorGradient,
                                isLoading: isLoading
                            ) { verifyDoctor() }
                            .padding(.horizontal, Spacing.lg)
                            .padding(.top, Spacing.xl)
                            .opacity(contentVisible ? 1 : 0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: contentVisible)
                        } else {
                            BTPrimaryButton(
                                title: "Reset Password",
                                icon: "checkmark.shield.fill",
                                gradient: LinearGradient.btDoctorGradient,
                                isLoading: isLoading
                            ) { resetPassword() }
                            .padding(.horizontal, Spacing.lg)
                            .padding(.top, Spacing.xl)
                        }

                        Spacer(minLength: 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                contentVisible = true
            }
        }
    }

    // MARK: - Verify Doctor ID
    private func verifyDoctor() {
        guard !doctorId.isEmpty else {
            withAnimation { message = "Please enter your Doctor ID."; messageStatus = .warning }
            return
        }

        isLoading = true
        message = ""

        guard let url = APIConfig.getURL(for: "verify_doctor.php") else {
            isLoading = false
            withAnimation { message = "Invalid API Configuration."; messageStatus = .error }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["doctor_id": doctorId])

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    withAnimation { message = "Network Error: \(error.localizedDescription)"; messageStatus = .error }
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    withAnimation { message = "Invalid response from server."; messageStatus = .error }
                    return
                }

                if let status = json["status"] as? String, status == "success" {
                    withAnimation {
                        isDoctorVerified = true
                        message = "Doctor ID verified successfully!"
                        messageStatus = .success
                    }
                } else {
                    withAnimation {
                        message = json["message"] as? String ?? "Doctor ID not found."
                        messageStatus = .error
                    }
                }
            }
        }.resume()
    }

    // MARK: - Reset Password
    private func resetPassword() {
        guard !newPassword.isEmpty, !confirmPassword.isEmpty else {
            withAnimation { message = "All fields are required."; messageStatus = .warning }
            return
        }

        guard newPassword == confirmPassword else {
            withAnimation { message = "Passwords do not match."; messageStatus = .error }
            return
        }

        isLoading = true
        message = ""

        guard let url = APIConfig.getURL(for: "doctor_forgot_password.php") else {
            isLoading = false
            withAnimation { message = "Invalid API Configuration."; messageStatus = .error }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "doctor_id": doctorId,
            "new_password": newPassword
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    withAnimation { message = "Network Error: \(error.localizedDescription)"; messageStatus = .error }
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    withAnimation { message = "Invalid response from server."; messageStatus = .error }
                    return
                }

                if let status = json["status"] as? String, status == "success" {
                    withAnimation { message = "Password Reset Successfully!"; messageStatus = .success }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                } else {
                    withAnimation {
                        message = json["message"] as? String ?? "Failed to reset password."
                        messageStatus = .error
                    }
                }
            }
        }.resume()
    }
}

#Preview {
    NavigationStack { DoctorForgotPasswordView() }
}
