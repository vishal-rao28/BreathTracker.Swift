import SwiftUI

enum LoginRole: String, CaseIterable {
    case patient = "Patient"
    case doctor = "Doctor"
}

// MARK: - Unified Login Screen (with Role Picker)
struct AboutScreen2: View {
    @EnvironmentObject var session: PatientSession

    @State private var selectedRole: LoginRole = .patient
    @State private var patientUserId = ""
    @State private var doctorUserId  = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var message   = ""
    @State private var msgStatus: BTStatusBadge.Status = .error

    @State private var contentVisible = false
    @State private var showSignup = false
    @State private var showDoctorDashboard = false
    @State private var showForgotPassword = false
    @State private var showDoctorForgotPassword = false
    @State private var showRecoverId = false

    var body: some View {
        ZStack {
            Color.btBackground.ignoresSafeArea()

            // Dynamic top wave
            GeometryReader { geo in
                Ellipse()
                    .fill(selectedRole == .patient ? LinearGradient.btPrimaryGradient : LinearGradient.btDoctorGradient)
                    .frame(width: geo.size.width * 1.4, height: 320)
                    .offset(x: -geo.size.width * 0.2, y: -160)
                    .opacity(0.12)
                    .animation(.easeInOut, value: selectedRole)
            }.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer().frame(height: UIScreen.main.bounds.height * 0.04)


                        
                        // ── Hero illustration ────────────────────────
                        ZStack {
                            Circle()
                                .fill((selectedRole == .patient ? Color.btPrimary : Color.btDoctorPrimary).opacity(0.08))
                                .frame(width: 160, height: 160)
                            Circle()
                                .fill((selectedRole == .patient ? Color.btPrimary : Color.btDoctorPrimary).opacity(0.05))
                                .frame(width: 200, height: 200)
                            Image(systemName: selectedRole == .patient ? "figure.wave" : "stethoscope")
                                .font(.system(size: 80, weight: .thin))
                                .foregroundStyle(selectedRole == .patient ? LinearGradient.btPrimaryGradient : LinearGradient.btDoctorGradient)
                        }
                        .padding(.top, Spacing.lg)
                        .opacity(contentVisible ? 1 : 0)
                        .scaleEffect(contentVisible ? 1 : 0.8)
                        .animation(.spring(response: 0.7, dampingFraction: 0.8), value: contentVisible)
                        .animation(.easeInOut, value: selectedRole)

                        // ── Header text ──────────────────────────────
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text(selectedRole == .patient ? "Welcome back" : "Doctor Sign In")
                                .font(.btTitle)
                                .foregroundColor(.btTextPrimary)
                            Text(selectedRole == .patient ? "Sign in to manage your health" : "Access your patient management portal")
                                .font(.btBody)
                                .foregroundColor(.btTextSecond)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.lg)
                        .opacity(contentVisible ? 1 : 0)
                        .offset(y: contentVisible ? 0 : 12)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: contentVisible)

                        // ── Role Picker ──────────────────────────────
                        Picker("Select Role", selection: $selectedRole) {
                            ForEach(LoginRole.allCases, id: \.self) { role in
                                Text(role.rawValue).tag(role)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.md)
                        .opacity(contentVisible ? 1 : 0)
                        .offset(y: contentVisible ? 0 : 14)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.15), value: contentVisible)

                        // ── Form ─────────────────────────────────────
                        VStack(spacing: Spacing.md) {
                            if selectedRole == .patient {
                                BTInputField(
                                    placeholder: "Patient ID (pat_...)",
                                    icon: "person.badge.key.fill",
                                    text: $patientUserId
                                )
                            } else {
                                BTInputField(
                                    placeholder: "Doctor ID (doc_...)",
                                    icon: "person.text.rectangle.fill",
                                    text: $doctorUserId
                                )
                            }
                            BTInputField(
                                placeholder: "Password",
                                icon: "lock.fill",
                                text: $password,
                                isSecure: true
                            )
                            
                            // ── Forgot Password & ID Links ──────────────────
                            if selectedRole == .patient {
                                HStack {
                                    Button("Forgot ID?") {
                                        showRecoverId = true
                                    }
                                    .font(.btCaption)
                                    .foregroundColor(.btPrimary)
                                    .padding(.top, 4)
                                    
                                    Spacer()
                                    
                                    Button("Forgot password?") {
                                        showForgotPassword = true
                                    }
                                    .font(.btCaption)
                                    .foregroundColor(.btPrimary)
                                    .padding(.top, 4)
                                }
                            } else {
                                HStack {
                                    Spacer()
                                    Button("Forgot Password?") {
                                        showDoctorForgotPassword = true
                                    }
                                    .font(.btCaption)
                                    .foregroundStyle(LinearGradient.btDoctorGradient)
                                    .padding(.top, 4)
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.lg)
                        .opacity(contentVisible ? 1 : 0)
                        .offset(y: contentVisible ? 0 : 16)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: contentVisible)
                        .animation(.easeInOut, value: selectedRole)

                        // ── Status message ───────────────────────────
                        if !message.isEmpty {
                            BTStatusBadge(message: message, status: msgStatus)
                                .padding(.horizontal, Spacing.lg)
                                .padding(.top, Spacing.sm)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        // ── Sign In button ───────────────────────────
                        BTPrimaryButton(
                            title: "Sign In",
                            icon: "arrow.right.circle.fill",
                            gradient: selectedRole == .patient ? LinearGradient.btPrimaryGradient : LinearGradient.btDoctorGradient,
                            isLoading: isLoading
                        ) { handleLogin() }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.lg)
                        .opacity(contentVisible ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: contentVisible)
                        .animation(.easeInOut, value: selectedRole)

                        // ── Sign up link (Only for Patient) ──────────
                        if selectedRole == .patient {
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
                        }

                        Spacer(minLength: Spacing.xxl)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showSignup) {
            PatientSignUp()
        }
        .navigationDestination(isPresented: $showDoctorDashboard) {
            doctordashboard().navigationBarBackButtonHidden(true)
        }
        .navigationDestination(isPresented: $showForgotPassword) {
            PatientForgotPasswordView()
        }
        .navigationDestination(isPresented: $showDoctorForgotPassword) {
            DoctorForgotPasswordView()
        }
        .navigationDestination(isPresented: $showRecoverId) {
            RecoverPatientIdView()
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                contentVisible = true
            }
            if let lastId = UserDefaults.standard.string(forKey: "lastCreatedPatientId") {
                patientUserId = lastId
                UserDefaults.standard.removeObject(forKey: "lastCreatedPatientId")
                selectedRole = .patient
            }
        }
        // Change logic on role swap
        .onChange(of: selectedRole) {
            message = ""
        }
    }

    // MARK: - Handlers
    private func handleLogin() {
        let trimmedPatientId = patientUserId.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDoctorId = doctorUserId.trimmingCharacters(in: .whitespacesAndNewlines)
        let currentUserId = selectedRole == .patient ? trimmedPatientId : trimmedDoctorId
        
        guard !currentUserId.isEmpty && !password.isEmpty else {
            withAnimation { message = "Please enter your ID and password."; msgStatus = .warning }
            return
        }

        if selectedRole == .patient {
            if currentUserId.contains(" ") {
                withAnimation { message = "Give Patient ID correctly without spaces"; msgStatus = .warning }
                return
            }
            loginPatient(id: currentUserId)
        } else {
            loginDoctor(id: currentUserId)
        }
    }

    // MARK: - Patient Login
    private func loginPatient(id: String) {
        isLoading = true
        message = ""

        guard let url = APIConfig.getURL(for: "patient_login.php") else {
            isLoading = false
            withAnimation { message = "Invalid server configuration."; msgStatus = .error }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["patient_id": id, "password": password])

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    withAnimation { message = "Connection error: \(error.localizedDescription)"; msgStatus = .error }
                    return
                }
                guard let data = data else {
                    withAnimation { message = "No response from server."; msgStatus = .error }
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
                            
                            withAnimation { message = "Sign In successful!"; msgStatus = .success }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                session.login(pid: pid, name: name, age: age, gender: gender, occupation: occupation)
                            }
                        } else {
                            withAnimation {
                                message = json["message"] as? String ?? "Login failed. Check your credentials."
                                msgStatus = .error
                            }
                        }
                    }
                } catch {
                    withAnimation { message = "Unexpected server response."; msgStatus = .error }
                }
            }
        }.resume()
    }

    // MARK: - Doctor Login
    private func loginDoctor(id: String) {
        isLoading = true
        message = ""

        guard let url = APIConfig.getURL(for: "doctor_login.php") else {
            isLoading = false
            withAnimation { message = "Invalid server configuration."; msgStatus = .error }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["doctor_id": id, "password": password])

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    withAnimation { message = "Connection error: \(error.localizedDescription)"; msgStatus = .error }
                    return
                }
                guard let data = data else {
                    withAnimation { message = "No response from server."; msgStatus = .error }
                    return
                }
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let status = json["status"] as? String, status == "success" {
                            withAnimation { message = "Login successful!"; msgStatus = .success }
                            UserDefaults.standard.set(id, forKey: "loggedInDoctorId")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showDoctorDashboard = true
                            }
                        } else {
                            withAnimation {
                                message = json["message"] as? String ?? "Login failed."
                                msgStatus = .error
                            }
                        }
                    }
                } catch {
                    if let raw = String(data: data, encoding: .utf8) { print("Backend: \(raw)") }
                    withAnimation { message = "Unexpected server response."; msgStatus = .error }
                }
            }
        }.resume()
    }
}

#Preview {
    NavigationStack { AboutScreen2().environmentObject(PatientSession()) }
}
