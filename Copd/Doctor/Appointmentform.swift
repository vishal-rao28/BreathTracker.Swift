import SwiftUI

struct AppointmentFormView: View {
    @Environment(\.dismiss) private var dismiss
    let appointment: PatientNotification
    @State private var appeared = false
    
    var body: some View {
        ZStack {
            Color.btBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    BTBackButton(action: { dismiss() })
                    Spacer()
                    Text("Clinical Case Details")
                        .font(.btHeadline)
                        .foregroundColor(.btTextPrimary)
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.sm)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: Spacing.xl) {
                        
                        // Hero Profile Card
                        VStack(spacing: Spacing.md) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient.btDoctorGradient)
                                    .frame(width: 80, height: 80)
                                    .btDeepShadow(color: Color.btDoctorPrimary)
                                Text(initials(from: appointment.name))
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 4) {
                                Text(appointment.name)
                                    .font(.btTitle2)
                                    .foregroundColor(.btTextPrimary)
                                Text("\(appointment.age) Years • \(appointment.gender)")
                                    .font(.btBodyMedium)
                                    .foregroundColor(.btTextSecond)
                            }
                        }
                        .padding(.top, Spacing.md)
                        .opacity(appeared ? 1 : 0)
                        .scaleEffect(appeared ? 1 : 0.9)

                        // Information Groups
                        VStack(spacing: Spacing.xl) {
                            
                            InfoGroupModern(title: "Patient Info", icon: "person.text.rectangle.fill", tint: .btDoctorPrimary, delay: 0.1) {
                                ModernDetailRow(icon: "phone.fill", title: "Phone", value: appointment.phone)
                                ModernDetailRow(icon: "envelope.fill", title: "Email", value: appointment.email)
                                ModernDetailRow(icon: "map.fill", title: "Residential Address", value: appointment.address, isLast: true)
                            }
                            
                            InfoGroupModern(title: "Medical Status", icon: "heart.text.square.fill", tint: .btAccent, delay: 0.2) {
                                ModernDetailRow(icon: "stethoscope", title: "COPD Diagnosis", value: appointment.copdConfirmed)
                                ModernDetailRow(icon: "doc.plaintext.fill", title: "Primary Symptoms", value: appointment.symptoms)
                                ModernDetailRow(icon: "lungs.fill", title: "Smoking History", value: appointment.smokingStatus, isLast: true)
                            }
                            
                            InfoGroupModern(title: "Scheduling", icon: "calendar.badge.clock", tint: .btAccentOrange, delay: 0.3) {
                                ModernDetailRow(icon: "calendar", title: "Preferred Date", value: appointment.preferredDate)
                                ModernDetailRow(icon: "clock.fill", title: "Preferred Time", value: appointment.preferredTime)
                                ModernDetailRow(icon: "video.fill", title: "Consultation Type", value: appointment.consultationMode, isLast: true)
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                        .opacity(appeared ? 1 : 0)
                        
                        Spacer(minLength: 60)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }
    
    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        let first = parts.first?.first.map(String.init) ?? ""
        let last = parts.dropFirst().first?.first.map(String.init) ?? ""
        return (first + last).isEmpty ? "P" : (first + last).uppercased()
    }
}

// MARK: - Modern Info Components

private struct InfoGroupModern<Content: View>: View {
    let title: String; let icon: String; let tint: Color; let delay: Double
    @ViewBuilder var content: Content
    @State private var showed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: icon).font(.system(size: 16, weight: .bold)).foregroundColor(tint)
                Text(title).font(.btLabel).foregroundColor(.btTextSecond).textCase(.uppercase).kerning(1)
            }
            .padding(.leading, Spacing.xs)
            
            VStack(spacing: 0) { content }
                .background(Color.btSurface)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .btCardShadow()
        }
        .opacity(showed ? 1 : 0).offset(y: showed ? 0 : 20)
        .onAppear { withAnimation(.spring().delay(delay)) { showed = true } }
    }
}

private struct ModernDetailRow: View {
    let icon: String; let title: String; let value: String; var isLast: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.btTextTertiary)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.btCaption2).foregroundColor(.btTextSecond)
                    Text(value.isEmpty ? "Not provided" : value)
                        .font(.btBodyMedium).foregroundColor(.btTextPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
            .padding(.horizontal, Spacing.md + 4).padding(.vertical, 16)
            
            if !isLast {
                Divider().background(Color.btBorder).padding(.leading, 56)
            }
        }
    }
}

#Preview {
    AppointmentFormView(appointment: PatientNotification(id: "1", patientId: "P001", name: "Sarah J. Peterson", age: 62, gender: "Female", symptoms: "Wheezing, Nocturnal Cough", phone: "+91 9876543210", email: "sarah.p@icloud.com", address: "Central Park West, Mumbai", copdConfirmed: "Yes (Confirmed)", durationSymptoms: "2 Years", medications: "Inhaler", allergies: "Dust", smokingStatus: "Never Smoked", preferredDate: "15 Oct, 2026", preferredTime: "10:30 AM", consultationMode: "Clinical Visit"))
}
