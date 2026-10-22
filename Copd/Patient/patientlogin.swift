import SwiftUI

struct patientlogin: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var session: PatientSession

    @State private var patientId: String = ""
    @State private var password:  String = ""
    @State private var isLoading  = false
    @State private var message: String = ""
    @State private var messageStatus: BTStatusBadge.Status = .error
    @State private var showPatientDashboard = false
    @State private var showSignup = false
    @State private var showForgotPassword = false

    @State private var contentVisible = false
    @State private var showAlert = false

    var body: some View {
        ZStack {
            Color.btBackground.ignoresSafeArea()

            // Teal top wave
            GeometryReader { geo in
                ZStack(alignment: .topLeading) {
                    Ellipse()
                        .fill(LinearGradient.btPrimaryGradient)
                        .frame(width: geo.size.width * 1.4, height: 320)
                        .offset(x: -geo.size.width * 0.2, y: -160)
                        .opacity(0.12)
                }
            }.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Nav bar ──────────────────────────────────────────
                HStack {
                    Spacer()
                    BTPillTag(label: "Patient", color: .btPrimary)
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
                                .fill(Color.btPrimary.opacity(0.08))
                                .frame(width: 160, height: 160)
                            Circle()
                                .fill(Color.btPrimary.opacity(0.05))
                                .frame(width: 200, height: 200)
                            Image(systemName: "figure.wave")
                                .font(.system(size: 80, weight: .thin))
                                .foregroundStyle(LinearGradient.btPrimaryGradient)
                        }
                        .padding(.top, Spacing.lg)
                        .opacity(contentVisible ? 1 : 0)
                        .scaleEffect(contentVisible ? 1 : 0.8)
                        .animation(.spring(response: 0.7, dampingFraction: 0.8), value: contentVisible)

                        // ── Header text ──────────────────────────────
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Welcome back")
                                .font(.btTitle)
                                .foregroundColor(.btTextPrimary)
                            Text("Sign in to manage your health")
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
                                placeholder: "Patient ID (pat_xxx)",
                                icon: "person.badge.key.fill",
                                text: $patientId
                            )
                            BTInputField(
                                placeholder: "Password",
                                icon: "lock.fill",
                                text: $password,
                                isSecure: true
                            )
                            
                            // ── Forgot Password Link ──────────────────
                            HStack {
                                Spacer()
                                Button("Forgot password?") {
                                    showForgotPassword = true
                                }
                                .font(.btCaption)
                                .foregroundColor(.btPrimary)
                                .padding(.top, 4)
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

                        // ── Login button ─────────────────────────────
                        BTPrimaryButton(
                            title: "Sign In",
                            icon: "arrow.right.circle.fill",
                            isLoading: isLoading
                        ) { login() }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.lg)
                        .opacity(contentVisible ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: contentVisible)



                        // ── Sign up link ─────────────────────────────
                        HStack(spacing: Spacing.xs) {
                            Text("New to BreathTrack?")
                                .font(.btBody)
                                .foregroundColor(.btTextSecond)
                            Button("Create account") {
                                showSignup = true
                            }
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.btPrimary)
                        }
                        .padding(.top, Spacing.md)
                        .opacity(contentVisible ? 1 : 0)
                        .animation(.easeIn.delay(0.4), value: contentVisible)

                        Spacer(minLength: Spacing.xxl)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showSignup) {
            PatientSignUp()
        }
        .navigationDestination(isPresented: $showForgotPassword) {
            PatientForgotPasswordView()
        }

        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(message),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                contentVisible = true
            }
            if let lastId = UserDefaults.standard.string(forKey: "lastCreatedPatientId") {
                patientId = lastId
                UserDefaults.standard.removeObject(forKey: "lastCreatedPatientId")
            }
        }
    }

    // MARK: - Login Logic (unchanged)
    func login() {
        guard !patientId.isEmpty && !password.isEmpty else {
            withAnimation { message = "Please enter your Patient ID and password."; messageStatus = .warning }
            return
        }
        
        if !patientId.lowercased().hasPrefix("pat_") || patientId.contains(" ") {
            withAnimation { message = "Give Patient ID correctly and in pat_xxx format"; messageStatus = .warning }
            return
        }
        isLoading = true
        message = ""

        guard let url = APIConfig.getURL(for: "patient_login.php") else {
            isLoading = false
            withAnimation { message = "Invalid server configuration."; messageStatus = .error }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["patient_id": patientId, "password": password])

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
                            let pid  = json["patient_id"] as? String ?? ""
                            let name = json["name"] as? String ?? "Patient"
                            let age  = Int("\(json["age"] ?? "0")")
                            let gender = json["gender"] as? String
                            let occupation = json["occupation"] as? String
                            
                
                            
                            
                            // Direct login with a tiny delay to let the success badge be seen
                            withAnimation { message = "Sign In successful!"; messageStatus = .success }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                session.login(pid: pid, name: name, age: age, gender: gender, occupation: occupation)
                                LocalNotificationManager.shared.syncRemindersFromServer(patientId: pid)
                            }
                        } else {
                            withAnimation {
                                message = json["message"] as? String ?? "Login failed. Check your credentials."
                                messageStatus = .error
                            }
                        }
                    }
                } catch {
                    withAnimation { message = "Unexpected server response."; messageStatus = .error }
                }
            }
        }.resume()
    }
}

#Preview {
    NavigationStack { patientlogin().environmentObject(PatientSession()) }
}
