import SwiftUI

struct PatientDashboardView: View {
    @EnvironmentObject var session: PatientSession
    @State private var contentVisible = false
    @State private var greeting = ""
    @State private var greetingIcon = "sun.max.fill"

    // Navigation targets
    @State private var goCheckup = false
    @State private var goVaccination = false
    @State private var goAdvice = false

    var body: some View {
        ZStack {
            Color.btBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // ── Hero header ──────────────────────────────────
                    heroHeader
                        .opacity(contentVisible ? 1 : 0)
                        .offset(y: contentVisible ? 0 : -16)
                        .animation(.spring(response: 0.7, dampingFraction: 0.8), value: contentVisible)

                    // ── Section label ────────────────────────────────
                    BTSectionHeader(title: "Main Dashboard", subtitle: "Track your health progress")
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.xl)
                        .opacity(contentVisible ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.15), value: contentVisible)

                    // ── Action cards ─────────────────────────────────
                    VStack(spacing: Spacing.md) {
                        // Primary large card
                        DashActionCard(
                            icon: "heart.text.square.fill",
                            title: "Medical Checkup",
                            subtitle: "Vitals & daily logs for \(session.current?.name ?? "Patient")",
                            color: Color.btPrimary,
                            gradient: LinearGradient.btPrimaryGradient,
                            size: .large,
                            delay: 0.2
                        ) { goCheckup = true }

                        HStack(spacing: Spacing.md) {
                            DashActionCard(
                                icon: "doc.text.below.ecg.fill",
                                title: "Vaccination & Questionnaires",
                                subtitle: "Status & history",
                                color: Color.btAccentOrange,
                                gradient: LinearGradient(colors: [Color.btAccentOrange, Color(hex: "FFC371")], startPoint: .topLeading, endPoint: .bottomTrailing),
                                size: .small,
                                delay: 0.25
                            ) { goVaccination = true }

                            DashActionCard(
                                icon: "sparkles",
                                title: "Medical Advice",
                                subtitle: "Treatment plan",
                                color: Color.btAccentGreen,
                                gradient: LinearGradient(colors: [Color.btAccentGreen, Color(hex: "56D9A0")], startPoint: .topLeading, endPoint: .bottomTrailing),
                                size: .small,
                                delay: 0.3
                            ) { goAdvice = true }
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.md)
                    .padding(.bottom, Spacing.xl)

                    Spacer(minLength: Spacing.xl)
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $goCheckup)    { Checkup(isPresented: $goCheckup).navigationBarBackButtonHidden(true) }
        .navigationDestination(isPresented: $goVaccination){ VaccinationView(isPresented: $goVaccination).navigationBarBackButtonHidden(true) }
        .navigationDestination(isPresented: $goAdvice)     { FinalAdviceView().navigationBarBackButtonHidden(true) }
        .onAppear {
            LocalNotificationManager.shared.requestAuthorization()
            computeGreeting()
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                contentVisible = true
            }
        }
    }

    // MARK: - Hero Header
    private var heroHeader: some View {
        ZStack(alignment: .bottomLeading) {
            // Gradient banner
            LinearGradient.btPrimaryGradient
                .overlay(
                    // Pattern decoration
                    ZStack {
                        Circle().fill(Color.white.opacity(0.06)).frame(width: 200).offset(x: 100, y: -50)
                        Circle().fill(Color.white.opacity(0.04)).frame(width: 140).offset(x: 140, y: 30)
                    }
                )
                .frame(height: 220)
                .clipShape(
                    RoundedCorner(radius: 32, corners: [.bottomLeft, .bottomRight])
                )

            // Content
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Image(systemName: greetingIcon)
                                .font(.system(size: 14, weight: .bold))
                            Text(greeting)
                                .font(.btLabel)
                        }
                        .foregroundColor(.white.opacity(0.9))
                        
                        Text(session.current?.name ?? "Patient")
                            .font(.btTitle)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.25))
                            .frame(width: 62, height: 62)
                        Image(systemName: "person.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }
                    .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1))
                }
                .padding(.horizontal, Spacing.lg)

                // Daily tip chip
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "lungs.fill")
                        .font(.system(size: 11))
                    Text("Breathe easy — stay on track today")
                        .font(.btCaption2)
                }
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.18))
                .clipShape(Capsule())
                .padding(.horizontal, Spacing.lg)
                .padding(.top, 6)
            }
            .padding(.top, 20)
            .padding(.bottom, Spacing.lg)
        }
    }

    // MARK: - Greeting
    private func computeGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  greeting = "Good Morning,";   greetingIcon = "sun.and.horizon.fill"
        case 12..<17: greeting = "Good Afternoon,"; greetingIcon = "sun.max.fill"
        case 17..<21: greeting = "Good Evening,";   greetingIcon = "sunset.fill"
        default:      greeting = "Good Night,";     greetingIcon = "moon.stars.fill"
        }
    }
}

// MARK: - Dash Action Card
struct DashActionCard: View {
    enum CardSize { case large, small }

    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let gradient: LinearGradient
    let size: CardSize
    let delay: Double
    let action: () -> Void

    @State private var appeared = false
    @State private var pressed  = false

    private var height: CGFloat { size == .large ? 160 : 220 }

    var body: some View {
        Button(action: action) {
            ZStack(alignment: size == .large ? .leading : .bottomLeading) {
                // Background gradient
                gradient
                    .clipShape(RoundedRectangle(cornerRadius: 28))

                // Decoration circles
                if size == .large {
                    Circle().fill(Color.white.opacity(0.12)).frame(width: 120).offset(x: 220, y: -40)
                    Circle().fill(Color.white.opacity(0.08)).frame(width: 90).offset(x: 260, y: 40)
                } else {
                    Circle().fill(Color.white.opacity(0.12)).frame(width: 100).offset(x: 40, y: -40)
                }

                if size == .large {
                    HStack(spacing: Spacing.md) {
                        Image(systemName: icon)
                            .font(.system(size: 44, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 86, height: 86)
                            .background(Color.white.opacity(0.22))
                            .clipShape(RoundedRectangle(cornerRadius: 22))

                        VStack(alignment: .leading, spacing: 6) {
                            Text(title)
                                .font(.btTitle2)
                                .foregroundColor(.white)
                                .minimumScaleFactor(0.8)
                            Text(subtitle)
                                .font(.btBody)
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(2)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(Spacing.lg)
                } else {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Image(systemName: icon)
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 64, height: 64)
                            .background(Color.white.opacity(0.22))
                            .clipShape(RoundedRectangle(cornerRadius: 18))

                        Spacer()

                        VStack(alignment: .leading, spacing: 4) {
                            Text(title)
                                .font(.btTitle3)
                                .foregroundColor(.white)
                                .lineLimit(2)
                                .minimumScaleFactor(0.7)
                            Text(subtitle)
                                .font(.btCaption)
                                .foregroundColor(.white.opacity(0.85))
                        }
                    }
                    .padding(Spacing.md)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .btDeepShadow(color: color)
            .scaleEffect(pressed ? 0.96 : (appeared ? 1.0 : 0.88))
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 18)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(DragGesture(minimumDistance: 0)
            .onChanged { _ in withAnimation(.easeInOut(duration: 0.1)) { pressed = true } }
            .onEnded   { _ in withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { pressed = false } }
        )
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75).delay(delay)) {
                appeared = true
            }
        }
    }
}



#Preview {
    NavigationStack {
        PatientDashboardView()
            .environmentObject(PatientSession(current: PatientProfile(
                patient_id: "P001", name: "Arjun", age: 52, gender: "Male", occupation: "Engineer"
            )))
    }
}
