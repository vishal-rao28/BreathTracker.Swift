import SwiftUI

struct PatientForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var patientId: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var isLoading = false
    @State private var isPatientVerified = false
    @State private var message: String = ""
    @State private var messageStatus: BTStatusBadge.Status = .error
    
    @State private var contentVisible = false
    
    var body: some View {
        ZStack {
            Color.btBackground.ignoresSafeArea()
            
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
                        // Header
                        VStack(alignment: .center, spacing: Spacing.xs) {
                            ZStack {
                                Circle()
                                    .fill(Color.btPrimary.opacity(0.1))
                                    .frame(width: 80, height: 80)
                                Image(systemName: "lock.rotation")
                                    .font(.system(size: 32))
                                    .foregroundColor(.btPrimary)
                            }
                            .padding(.bottom, Spacing.sm)
                            
                            Text("Forgot password?")
                                .font(.btTitle2)
                                .foregroundColor(.btTextPrimary)
                            Text(isPatientVerified ? "ID Verified! Set your new password." : "Enter your Patient ID to verify your identity.")
                                .font(.btBody)
                                .foregroundColor(.btTextSecond)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, Spacing.xl)
                        }
                        .padding(.top, Spacing.xl)
                        .opacity(contentVisible ? 1 : 0)
                        
                        // Form
                        VStack(spacing: Spacing.md) {
                            BTInputField(
                                placeholder: "Patient ID (pat_xxx)",
                                icon: "person.badge.key.fill",
                                text: $patientId
                            )
                            .disabled(isPatientVerified)
                            .opacity(isPatientVerified ? 0.6 : 1.0)
                            
                            if isPatientVerified {
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
                        
                        // Status message
                        if !message.isEmpty {
                            BTStatusBadge(message: message, status: messageStatus)
                                .padding(.horizontal, Spacing.lg)
                                .padding(.top, Spacing.md)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        // Action Button
                        if !isPatientVerified {
                            BTPrimaryButton(
                                title: "Verify Patient ID",
                                icon: "magnifyingglass",
                                isLoading: isLoading
                            ) { verifyPatient() }
                            .padding(.horizontal, Spacing.lg)
                            .padding(.top, Spacing.xl)
                            .opacity(contentVisible ? 1 : 0)
                        } else {
                            BTPrimaryButton(
                                title: "Reset Password",
                                icon: "checkmark.shield.fill",
                                isLoading: isLoading
                            ) { resetPassword() }
                            .padding(.horizontal, Spacing.lg)
                            .padding(.top, Spacing.xl)
                            .opacity(contentVisible ? 1 : 0)
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
    
    private func verifyPatient() {
        guard !patientId.isEmpty else {
            withAnimation { message = "Please enter your Patient ID."; messageStatus = .warning }
            return
        }
        
        isLoading = true
        message = ""
        
        guard let url = APIConfig.getURL(for: "verify_patient.php") else {
            isLoading = false
            withAnimation { message = "Invalid API Configuration."; messageStatus = .error }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["patient_id": patientId])
        
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
                        isPatientVerified = true 
                        message = "Patient ID verified successfully!"
                        messageStatus = .success
                    }
                } else {
                    withAnimation {
                        message = json["message"] as? String ?? "Patient ID not found."
                        messageStatus = .error
                    }
                }
            }
        }.resume()
    }
    
    private func resetPassword() {
        guard !patientId.isEmpty, !newPassword.isEmpty, !confirmPassword.isEmpty else {
            withAnimation { message = "All fields are required."; messageStatus = .warning }
            return
        }
        
        guard newPassword == confirmPassword else {
            withAnimation { message = "Passwords do not match."; messageStatus = .error }
            return
        }
        
        isLoading = true
        message = ""
        
        guard let url = APIConfig.getURL(for: "patient_forgot_password.php") else {
            isLoading = false
            withAnimation { message = "Invalid API Configuration."; messageStatus = .error }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "patient_id": patientId,
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
    PatientForgotPasswordView()
}
