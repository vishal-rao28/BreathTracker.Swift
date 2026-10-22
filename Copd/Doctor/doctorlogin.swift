import SwiftUI

struct doctorlogin: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var session: PatientSession

    @State private var doctorId: String = ""
    @State private var password: String = ""
    @State private var isLoading = false
    @State private var message: String = ""
    @State private var messageStatus: BTStatusBadge.Status = .error
    @State private var showDoctorDashboard = false
    @State private var showForgotPassword = false
    @State private var contentVisible = false

    var body: some View {
        ZStack {
            Color.btBackground.ignoresSafeArea()

            // Purple top decoration
            GeometryReader { geo in
                Ellipse()
                    .fill(LinearGradient.btDoctorGradient)
                    .frame(width: geo.size.width * 1.4, height: 300)
                    .offset(x: -geo.size.width * 0.2, y: -150)
                    .opacity(0.12)
            }.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Nav bar ──────────────────────────────────────────
                HStack {
                    Spacer()
                    BTPillTag(label: "Doctor", color: Color.btDoctorPrimary)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.md)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Dynamic top spacing for all iPhone sizes
                        Spacer().frame(height: UIScreen.main.bounds.height * 0.06)

                        // ── Hero illustration ────────────────────────
                        ZStack {
                            Circle()
                                .fill(Color.btDoctorPrimary.opacity(0.08))
                                .frame(width: 160, height: 160)
                            Circle()
                                .fill(Color.btDoctorPrimary.opacity(0.05))
                                .frame(width: 200, height: 200)
                            Image(systemName: "stethoscope")
                                .font(.system(size: 72, weight: .thin))
                                .foregroundStyle(LinearGradient.btDoctorGradient)
                        }
                        .padding(.top, Spacing.lg)
                        .opacity(contentVisible ? 1 : 0)
                        .scaleEffect(contentVisible ? 1 : 0.8)
                        .animation(.spring(response: 0.7, dampingFraction: 0.8), value: contentVisible)

                        // ── Header text ──────────────────────────────
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Doctor Sign In")
                                .font(.btTitle)
                                .foregroundColor(.btTextPrimary)
                            Text("Access your patient management portal")
                                .font(.btBody)
                                .foregroundColor(.btTextSecond)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.lg)
                        .opacity(contentVisible ? 1 : 0)
                        .offset(y: contentVisible ? 0 : 12)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: contentVisible)

                        // ── Form ─────────────────────────────────────
                        VStack(spacing: Spacing.md) {
                            BTInputField(
                                placeholder: "Doctor ID",
                                icon: "person.text.rectangle.fill",
                                text: $doctorId
                            )
                            BTInputField(
                                placeholder: "Password",
                                icon: "lock.fill",
                                text: $password,
                                isSecure: true
                            )

                            HStack {
                                Spacer()
                                Button("Forgot Password?") {
                                    showForgotPassword = true
                                }
                                .font(.btCaption)
                                .foregroundStyle(LinearGradient.btDoctorGradient)
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.lg)
                        .opacity(contentVisible ? 1 : 0)
                        .offset(y: contentVisible ? 0 : 16)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: contentVisible)

                        // ── Status message ───────────────────────────
                        if !message.isEmpty {
                            BTStatusBadge(message: message, status: messageStatus)
                                .padding(.horizontal, Spacing.lg)
                                .padding(.top, Spacing.sm)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        // ── Login button (purple) ────────────────────
                        BTPrimaryButton(
                            title: "Sign In",
                            icon: "arrow.right.circle.fill",
                            gradient: LinearGradient.btDoctorGradient,
                            isLoading: isLoading
                        ) { login() }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.lg)
                        .opacity(contentVisible ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: contentVisible)

                        Spacer(minLength: Spacing.xxl)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showDoctorDashboard) {
            doctordashboard().navigationBarBackButtonHidden(true)
        }
        .navigationDestination(isPresented: $showForgotPassword) {
            DoctorForgotPasswordView()
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                contentVisible = true
            }
        }
    }

    // MARK: - Login Logic (unchanged)
    func login() {
        guard !doctorId.isEmpty && !password.isEmpty else {
            withAnimation { message = "Please fill in all fields."; messageStatus = .warning }
            return
        }
        isLoading = true
        message = ""

        guard let url = APIConfig.getURL(for: "doctor_login.php") else {
            isLoading = false
            withAnimation { message = "Invalid server configuration."; messageStatus = .error }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["doctor_id": doctorId, "password": password])

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    withAnimation { message = "Connection error: \(error.localizedDescription)"; messageStatus = .error }
                    return
                }
                guard let data = data else {
                    withAnimation { message = "No response from server."; messageStatus = .error }
                    return
                }
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let status = json["status"] as? String, status == "success" {
                            withAnimation { message = "Login successful!"; messageStatus = .success }
                            UserDefaults.standard.set(doctorId, forKey: "loggedInDoctorId")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showDoctorDashboard = true
                            }
                        } else {
                            withAnimation {
                                message = json["message"] as? String ?? "Login failed."
                                messageStatus = .error
                            }
                        }
                    }
                } catch {
                    if let raw = String(data: data, encoding: .utf8) { print("Backend: \(raw)") }
                    withAnimation { message = "Unexpected server response."; messageStatus = .error }
                }
            }
        }.resume()
    }
}

#Preview {
    NavigationStack { doctorlogin().environmentObject(PatientSession()) }
}
