import SwiftUI

struct SixMinWalkTestView: View {
    @Environment(\.dismiss) private var dismiss
    var patientId: String
    
    @State private var descriptionText: String = ""
    @State private var isSubmitting = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            Color.btBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    BTBackButton(action: { dismiss() })
                    Spacer()
                    Text("6 Min Walk Test")
                        .font(.btHeadline)
                        .foregroundColor(.btTextPrimary)
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.sm)
                
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        
                        // Hero Icon
                        VStack(spacing: Spacing.sm) {
                            ZStack {
                                Circle().fill(Color.btDoctorPrimary.opacity(0.12)).frame(width: 90, height: 90)
                                Image(systemName: "figure.walk")
                                    .font(.system(size: 40))
                                    .foregroundStyle(LinearGradient.btDoctorGradient)
                            }
                            
                            Text("Test Description")
                                .font(.btTitle2)
                                .foregroundColor(.btTextPrimary)
                            Text("Record observations and distance for Patient: \(patientId)")
                                .font(.btBodyMedium)
                                .foregroundColor(.btTextSecond)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, Spacing.md)
                        
                        // Text Editor Card
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Report Details")
                                .font(.btCaption)
                                .foregroundColor(.btTextSecond)
                                .textCase(.uppercase)
                                .padding(.leading, 8)
                            
                            TextEditor(text: $descriptionText)
                                .frame(height: 200)
                                .padding(12)
                                .scrollContentBackground(.hidden)
                                .background(Color.btBackground) // Use background on editor directly
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.btBorder, lineWidth: 1)
                                )
                                .font(.btBody)
                                .foregroundColor(.btTextPrimary)
                            
                            if descriptionText.isEmpty {
                                Text("Please enter the test results and observations...")
                                    .font(.btBody)
                                    .foregroundColor(.btTextTertiary)
                                    .padding(.top, -170)
                                    .padding(.leading, 16)
                                    .allowsHitTesting(false)
                            }
                        }
                        .padding(Spacing.md)
                        .background(Color.btSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .btCardShadow()
                        
                        // Submit Button
                        BTPrimaryButton(
                            title: "Save Report",
                            icon: "checkmark.circle.fill",
                            gradient: LinearGradient.btDoctorGradient,
                            isLoading: isSubmitting
                        ) {
                            submitReport()
                        }
                        .padding(.top, Spacing.lg)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, Spacing.lg)
                }
            }
        }
        .navigationBarHidden(true)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Submission"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if alertMessage.contains("successfully") {
                        dismiss()
                    }
                }
            )
        }
    }
    
    private func submitReport() {
        guard !descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "Please enter the report description."
            showAlert = true
            return
        }
        
        guard let url = APIConfig.getURL(for: "submit_six_min_walk.php") else {
            alertMessage = "Invalid API configuration."
            showAlert = true
            return
        }
        
        isSubmitting = true
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "patient_id": patientId,
            "description": descriptionText
        ])
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                isSubmitting = false
                
                if let error = error {
                    alertMessage = "Network Error: \(error.localizedDescription)"
                    showAlert = true
                    return
                }
                
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    alertMessage = "Invalid response from server."
                    showAlert = true
                    return
                }
                
                if let status = json["status"] as? String, status == "success" {
                    alertMessage = "6 Min Walk Test report saved successfully!"
                } else {
                    alertMessage = json["message"] as? String ?? "Failed to save report."
                }
                showAlert = true
            }
        }.resume()
    }
}

#Preview {
    SixMinWalkTestView(patientId: "pat_123")
}
