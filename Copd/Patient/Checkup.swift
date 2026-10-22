import SwiftUI

struct Checkup: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool
    @State private var temperature: Int = 98
    @State private var navigateToOxygen = false
    @State private var appeared = false
    
    private let minTemp = 90
    private let maxTemp = 110
    
    var body: some View {
        ZStack {
            Color.btBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    BTBackButton(action: { dismiss() })
                    Spacer()
                    Text("Health Checkup")
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
                                
                                Image(systemName: "thermometer.medium")
                                    .font(.system(size: 40, weight: .light))
                                    .foregroundColor(.btPrimary)
                                    .symbolEffect(.bounce, value: temperature)
                            }
                            
                            VStack(spacing: 4) {
                                Text("Body Temperature")
                                    .font(.btTitle2)
                                    .foregroundColor(.btTextPrimary)
                                
                                Text("Adjust to match your current thermometer reading.")
                                    .font(.system(size: 13))
                                    .foregroundColor(.btTextSecond)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                        }
                        .padding(.top, Spacing.md)
                        .opacity(appeared ? 1 : 0)
                        
                        // Main Temperature Card
                        VStack(spacing: Spacing.md) {
                            // Temperature Display
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("\(temperature)")
                                    .font(.system(size: 72, weight: .bold, design: .rounded))
                                    .foregroundColor(.btTextPrimary)
                                    .contentTransition(.numericText())
                                
                                Text("°F")
                                    .font(.btTitle)
                                    .foregroundColor(.btTextSecond)
                            }
                            
                            // Custom Stepper
                            HStack(spacing: 40) {
                                temperatureButton(icon: "minus") {
                                    if temperature > minTemp { temperature -= 1 }
                                }
                                
                                temperatureButton(icon: "plus") {
                                    if temperature < maxTemp { temperature += 1 }
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
                        BTPrimaryButton(title: "Continue to Oxygen Check", icon: "arrow.right") {
                            navigateToOxygen = true
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.bottom, Spacing.xl)
                        .opacity(appeared ? 1 : 0)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToOxygen) {
            Oxygen(isPresented: $isPresented, temperature: temperature)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }
    
    private func temperatureButton(icon: String, action: @escaping () -> Void) -> some View {
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
        if temperature < 97 { return "Below Normal" }
        if temperature <= 99 { return "Normal Range" }
        if temperature <= 100 { return "Slight Fever" }
        return "High Fever"
    }
    
    private var statusColor: Color {
        if temperature < 97 { return .blue }
        if temperature <= 99 { return .green }
        if temperature <= 100 { return .orange }
        return .red
    }
}

#Preview {
    Checkup(isPresented: .constant(true))
}
