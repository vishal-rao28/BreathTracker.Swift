import SwiftUI

struct LungFunctionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var session: PatientSession
    @Binding var isPresented: Bool
    
    var temperature: Int = 98
    var spo2: Int = 98
    @State private var value: Int = 100
    @State private var showPatientDashboard = false
    @State private var isLoading = false
    @State private var appeared = false
    @State private var showSuccessAlert = false
    
    private let minValue = 0
    private let maxValue = 100
    private let step = 1
    
    var body: some View {
        ZStack {
            Color.btBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    BTBackButton(action: { dismiss() })
                    Spacer()
                    Text("Lung Check")
                        .font(.btHeadline)
                        .foregroundColor(.btTextPrimary)
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.sm)
                
                VStack(spacing: 0) {
                    VStack(spacing: Spacing.lg) {
                        
                        // Illustration & Title
                        VStack(spacing: Spacing.sm) {
                            ZStack {
                                Circle()
                                    .fill(Color.btPrimary.opacity(0.1))
                                    .frame(width: 90, height: 90)
                                    .scaleEffect(appeared ? 1 : 0.8)
                                
                                Image(systemName: "wind")
                                    .font(.system(size: 40, weight: .light))
                                    .foregroundColor(.btPrimary)
                                    .symbolEffect(.variableColor.iterative, value: value)
                            }
                            
                            VStack(spacing: 4) {
                                Text("Lung Function")
                                    .font(.btTitle2)
                                    .foregroundColor(.btTextPrimary)
                                
                                Text("Measure your Peak Expiratory Flow (PEF) using your device.")
                                    .font(.system(size: 13))
                                    .foregroundColor(.btTextSecond)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                        }
                        .padding(.top, Spacing.md)
                        .opacity(appeared ? 1 : 0)
                        
                        // Main Value Card
                        VStack(spacing: Spacing.md) {
                            // Value Display
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("\(value)")
                                    .font(.system(size: 72, weight: .bold, design: .rounded))
                                    .foregroundColor(.btTextPrimary)
                                    .contentTransition(.numericText())
                                
                                Text("%")
                                    .font(.btTitle)
                                    .foregroundColor(.btTextSecond)
                            }
                            
                            // Custom Stepper
                            HStack(spacing: 40) {
                                stepButton(icon: "minus") {
                                    if value > minValue { value -= step }
                                }
                                
                                stepButton(icon: "plus") {
                                    if value < maxValue { value += step }
                                }
                            }
                        }
                        .padding(.vertical, Spacing.lg)
                        .frame(maxWidth: .infinity)
                        .background(Color.btSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 32))
                        .btCardShadow()
                        .padding(.horizontal, Spacing.lg)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                        
                        // Health Indicator
                        HStack(spacing: Spacing.sm) {
                            Circle()
                                .fill(statusColor)
                                .frame(width: 8, height: 8)
                            
                            Text(statusText)
                                .font(.btLabel)
                                .foregroundColor(.btTextPrimary)
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, 8)
                        .background(statusColor.opacity(0.12))
                        .clipShape(Capsule())
                        .opacity(appeared ? 1 : 0)
                        
                        Spacer()
                        
                        // Submit Button
                        BTPrimaryButton(title: "Complete Checkup", icon: "checkmark.circle.fill", isLoading: isLoading) {
                            submitCheckup()
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.bottom, Spacing.xl)
                        .opacity(appeared ? 1 : 0)
                    }
                }
            }
        }
        .alert("Success", isPresented: $showSuccessAlert) {
            Button("OK") {
                isPresented = false
            }
        } message: {
            Text("Medical Checkup Taken Successfully!")
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }
    
    private func stepButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(LinearGradient.btPrimaryGradient)
                    .frame(width: 64, height: 64)
                    .btDeepShadow(color: Color.btPrimary)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(.plain)
    }
    
    // Status Logic (Percentage based zones)
    private var statusText: String {
        if value >= 80 { return "Green Zone (Good)" }
        if value >= 50 { return "Yellow Zone (Caution)" }
        return "Red Zone (Alert!)"
    }
    
    private var statusColor: Color {
        if value >= 80 { return .green }
        if value >= 50 { return .orange }
        return .red
    }
    
    private func submitCheckup() {
        guard !isLoading else { return }
        guard let url = APIConfig.getURL(for: "save_checkup.php") else { return }
        
        withAnimation { isLoading = true }
        
        let payload: [String: Any] = [
            "patient_id": session.current?.patient_id ?? "guest",
            "temperature": temperature,
            "oxygen_level": spo2,
            "lung_function": value
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                withAnimation { isLoading = false }
                if let error = error {
                    print("Error submitting checkup: \(error.localizedDescription)")
                }
                showSuccessAlert = true
            }
        }.resume()
    }
}

#Preview {
    NavigationStack {
        LungFunctionView(isPresented: .constant(true))
            .environmentObject(PatientSession())
    }
}
