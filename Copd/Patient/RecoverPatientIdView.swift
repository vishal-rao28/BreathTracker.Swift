import SwiftUI

struct RecoverPatientIdView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var phoneNumber: String = ""
    @State private var isLoading = false
    @State private var recoveredId: String? = nil
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
                    Text("Recover Patient ID")
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
                                Image(systemName: "person.text.rectangle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.btPrimary)
                            }
                            .padding(.bottom, Spacing.sm)
                            
                            Text("Forgot Patient ID?")
                                .font(.btTitle2)
                                .foregroundColor(.btTextPrimary)
                            
                            if recoveredId != nil {
                                Text("We found your Patient ID!")
                                    .font(.btBody)
                                    .foregroundColor(.btTextSecond)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, Spacing.xl)
                            } else {
                                Text("Enter your registered Phone Number to recover your ID.")
                                    .font(.btBody)
                                    .foregroundColor(.btTextSecond)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, Spacing.xl)
                            }
                        }
                        .padding(.top, Spacing.xl)
                        .opacity(contentVisible ? 1 : 0)
                        
                        // Form & Result
                        VStack(spacing: Spacing.md) {
                            if let recoveredId = recoveredId {
                                VStack(spacing: Spacing.sm) {
                                    Text(recoveredId)
                                        .font(.system(size: 32, weight: .bold, design: .rounded))
                                        .foregroundColor(.btPrimary)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.btPrimary.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                    
                                    Text("You can now safely return to the login screen and use this ID to sign in.")
                                        .font(.btCaption)
                                        .foregroundColor(.btTextSecond)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.top, Spacing.md)
                            } else {
                                BTInputField(
                                    placeholder: "Phone Number",
                                    icon: "phone.fill",
                                    text: $phoneNumber
                                )
                                .keyboardType(.phonePad)
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
                        if let _ = recoveredId {
                            BTPrimaryButton(
                                title: "Back to Login",
                                icon: "arrow.left.circle.fill",
                                isLoading: false
                            ) { dismiss() }
                            .padding(.horizontal, Spacing.lg)
                            .padding(.top, Spacing.xl)
                            .opacity(contentVisible ? 1 : 0)
                        } else {
                            BTPrimaryButton(
                                title: "Find My ID",
                                icon: "magnifyingglass",
                                isLoading: isLoading
                            ) { recoverId() }
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
    
    private func recoverId() {
        guard !phoneNumber.isEmpty else {
            withAnimation { message = "Please enter your Phone Number."; messageStatus = .warning }
            return
        }
        
        isLoading = true
        message = ""
        
        guard let url = APIConfig.getURL(for: "recover_patient_id.php") else {
            isLoading = false
            withAnimation { message = "Invalid API Configuration."; messageStatus = .error }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["phone_number": phoneNumber])
        
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
                
                if let status = json["status"] as? String, status == "success", let foundId = json["patient_id"] as? String {
                    withAnimation(.spring()) { 
                        recoveredId = foundId
                        message = "ID Recovered Successfully!"
                        messageStatus = .success
                    }
                } else {
                    withAnimation {
                        message = json["message"] as? String ?? "No account found with this phone number."
                        messageStatus = .error
                    }
                }
            }
        }.resume()
    }
}

#Preview {
    RecoverPatientIdView()
}
