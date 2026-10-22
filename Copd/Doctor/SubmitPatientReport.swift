import SwiftUI

struct SubmitPatientReportView: View {
    @Environment(\.dismiss) private var dismiss
    var patientName: String
    var patientId: String
    
    @State private var goToPFT = false
    @State private var goToABG = false
    @State private var goToMedication = false
    @State private var goToAdherence = false
    @State private var goToSixMinWalk = false
    @State private var appeared = false
    
    var body: some View {
        ZStack {
            Color.btBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    BTBackButton(action: { dismiss() })
                    Spacer()
                    Text("Clinical Submission")
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
                        
                        // Hero Section
                        VStack(spacing: Spacing.md) {
                            ZStack {
                                Circle().fill(Color.btDoctorPrimary.opacity(0.12)).frame(width: 90, height: 90)
                                Image(systemName: "person.fill")
                                    .font(.system(size: 44))
                                    .foregroundStyle(LinearGradient.btDoctorGradient)
                            }
                            
                            VStack(spacing: 4) {
                                Text(patientName)
                                    .font(.btTitle)
                                    .foregroundColor(.btTextPrimary)
                                Text("New Clinical Entry")
                                    .font(.btBodyMedium)
                                    .foregroundColor(.btTextSecond)
                            }
                        }
                        .padding(.top, Spacing.lg)
                        .opacity(appeared ? 1 : 0)
                        .scaleEffect(appeared ? 1 : 0.9)

                        // Action Cards
                        VStack(spacing: Spacing.lg) {
                            ReportActionCard(
                                title: "PFT Values",
                                description: "Record lung function & severity",
                                icon: "wind",
                                color: .btDoctorPrimary,
                                delay: 0.1
                            ) { goToPFT = true }

                            ReportActionCard(
                                title: "ABG Report",
                                description: "Arterial blood gas analysis",
                                icon: "drop.fill",
                                color: .btAccent,
                                delay: 0.2
                            ) { goToABG = true }

                            ReportActionCard(
                                title: "Medication Diary",
                                description: "Update prescriptions & advice",
                                icon: "pills.fill",
                                color: .btAccentGreen,
                                delay: 0.3
                            ) { goToMedication = true }

                            ReportActionCard(
                                title: "Inhaler Adherence",
                                description: "View patient's inhaler history",
                                icon: "lungs.fill",
                                color: .btAccentPurple,
                                delay: 0.4
                            ) { goToAdherence = true }
                            
                            ReportActionCard(
                                title: "6 Min Walk Test",
                                description: "Record walk test observations",
                                icon: "figure.walk",
                                color: .btPrimary,
                                delay: 0.5
                            ) { goToSixMinWalk = true }
                        }
                        .padding(.horizontal, Spacing.lg)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $goToPFT) {
            PftValuesView(patientId: patientId).navigationBarBackButtonHidden(true)
        }
        .navigationDestination(isPresented: $goToABG) {
            ABGReportView(patientId: patientId).navigationBarBackButtonHidden(true)
        }
        .navigationDestination(isPresented: $goToMedication) {
            Medication(patientId: patientId).navigationBarBackButtonHidden(true)
        }
        .navigationDestination(isPresented: $goToAdherence) {
            InhalerAdherenceView(patientId: patientId, patientName: patientName).navigationBarBackButtonHidden(true)
        }
        .navigationDestination(isPresented: $goToSixMinWalk) {
            SixMinWalkTestView(patientId: patientId).navigationBarBackButtonHidden(true)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }
}

// MARK: - Report Action Card
private struct ReportActionCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let delay: Double
    let action: () -> Void
    
    @State private var showed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(color.opacity(0.12))
                        .frame(width: 60, height: 60)
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.btHeadline)
                        .foregroundColor(.btTextPrimary)
                    Text(description)
                        .font(.btCaption)
                        .foregroundColor(.btTextSecond)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.btTextTertiary)
            }
            .padding(Spacing.md)
            .background(Color.btSurface)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .btCardShadow()
            .opacity(showed ? 1 : 0)
            .offset(y: showed ? 0 : 20)
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.spring().delay(delay)) { showed = true }
        }
    }
}

#Preview {
    NavigationStack {
        SubmitPatientReportView(patientName: "John Anderson", patientId: "123")
    }
}
