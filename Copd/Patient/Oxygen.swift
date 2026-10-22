import SwiftUI

struct Oxygen: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool
    var temperature: Int = 98
    @State private var spo2: Int = 98
    @State private var navigateToLung = false
    @State private var appeared = false
    
    private let minSpO2 = 70
    private let maxSpO2 = 100
    
    var body: some View {
        ZStack {
            Color.btBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    BTBackButton(action: { dismiss() })
                    Spacer()
                    Text("Oxygen Check")
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
                                
                                Image(systemName: "lungs.fill")
                                    .font(.system(size: 40, weight: .light))
                                    .foregroundColor(.btPrimary)
                                    .symbolEffect(.pulse, value: spo2)
                            }
                            
                            VStack(spacing: 4) {
                                Text("Oxygen Saturation")
                                    .font(.btTitle2)
                                    .foregroundColor(.btTextPrimary)
                                
                                Text("Measure your SpO2 percentage using a pulse oximeter.")
                                    .font(.system(size: 13))
                                    .foregroundColor(.btTextSecond)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                        }
                        .padding(.top, Spacing.md)
                        .opacity(appeared ? 1 : 0)
                        
                        // Main SpO2 Card
                        VStack(spacing: Spacing.md) {
                            // SpO2 Display
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("\(spo2)")
                                    .font(.system(size: 72, weight: .bold, design: .rounded))
                                    .foregroundColor(.btTextPrimary)
                                    .contentTransition(.numericText())
                                
                                Text("%")
                                    .font(.btTitle)
                                    .foregroundColor(.btTextSecond)
                            }
                            
                            // Custom Stepper
                            HStack(spacing: 40) {
                                oxygenButton(icon: "minus") {
                                    if spo2 > minSpO2 { spo2 -= 1 }
                                }
                                
                                oxygenButton(icon: "plus") {
                                    if spo2 < maxSpO2 { spo2 += 1 }
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
                        
                        // Next Button
                        BTPrimaryButton(title: "Check Lung Capacity", icon: "arrow.right") {
                            navigateToLung = true
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.bottom, Spacing.xl)
                        .opacity(appeared ? 1 : 0)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToLung) {
            LungFunctionView(isPresented: $isPresented, temperature: temperature, spo2: spo2)
                .navigationBarBackButtonHidden(true)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }
    
    private func oxygenButton(icon: String, action: @escaping () -> Void) -> some View {
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
    
    // Status Logic
    private var statusText: String {
        if spo2 >= 95 { return "Normal (Safe)" }
        if spo2 >= 90 { return "Mild Hypoxia" }
        return "Critical Low"
    }
    
    private var statusColor: Color {
        if spo2 >= 95 { return .green }
        if spo2 >= 90 { return .orange }
        return .red
    }
}

#Preview {
    Oxygen(isPresented: .constant(true))
}
