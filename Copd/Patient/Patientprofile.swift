import SwiftUI

// MARK: - Patient Profile & Session (models unchanged, view redesigned)

struct PatientProfile: Equatable {
    var patient_id: String
    var name: String
    var age: Int?
    var gender: String?
    var occupation: String?
    var date_pneumococcal: String?
    var date_flu: String?
    var date_pertussis: String?
    var date_shingles1: String?
    var date_shingles2: String?
}

final class PatientSession: ObservableObject {
    @Published var current: PatientProfile?
    @Published var hasSeenIntro: Bool = false
    @Published var selectedTab: Int = 0
    @Published var hasUnreadNotification: Bool = false

    init(current: PatientProfile? = nil) {
        self.current = current
    }

    func login(pid: String, name: String, age: Int? = nil, gender: String? = nil, occupation: String? = nil) {
        current = PatientProfile(patient_id: pid, name: name, age: age, gender: gender, occupation: occupation)
        hasSeenIntro = true
        selectedTab = 0
    }

    func logout() { current = nil }
}

// MARK: - Patient Profile View
struct PatientProfileView: View {
    @EnvironmentObject var session: PatientSession
    var onLogout: (() -> Void)? = nil

    @State private var contentVisible = false
    @State private var showLogoutConfirm = false

    private var initials: String {
        let name = session.current?.name ?? "P"
        return String(name.prefix(2)).uppercased()
    }

    var body: some View {
        ZStack {
            Color.btBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // ── Hero avatar banner ───────────────────────────
                    avatarBanner
                        .opacity(contentVisible ? 1 : 0)
                        .offset(y: contentVisible ? 0 : -20)
                        .animation(.spring(response: 0.7, dampingFraction: 0.8), value: contentVisible)

                    // ── Info cards grid ──────────────────────────────
                    VStack(spacing: Spacing.md) {
                        BTSectionHeader(title: "Personal Info")
                            .padding(.horizontal, Spacing.lg)
                            .padding(.top, Spacing.xl)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.md) {
                            ProfileInfoCard(icon: "calendar",               label: "Age",
                                           value: session.current?.age != nil ? "\(session.current!.age!) yrs" : "—",
                                           color: .btAccentOrange, delay: 0.15)
                            ProfileInfoCard(icon: "person.text.rectangle",  label: "Gender",
                                           value: session.current?.gender ?? "—",
                                           color: .btAccentPurple, delay: 0.2)
                            ProfileInfoCard(icon: "briefcase.fill",         label: "Occupation",
                                           value: session.current?.occupation ?? "—",
                                           color: .btAccentGreen, delay: 0.25)
                            ProfileInfoCard(icon: "cross.case.fill",        label: "Condition",
                                           value: "COPD",
                                           color: .btPrimary, delay: 0.3)
                        }
                        .padding(.horizontal, Spacing.lg)
                    }
                    .opacity(contentVisible ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: contentVisible)


                    // ── Logout ───────────────────────────────────────
                    Button {
                        showLogoutConfirm = true
                    } label: {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 17, weight: .semibold))
                            Text("Sign Out")
                                .font(.btLabel)
                        }
                        .foregroundColor(.btAccent)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.btAccent.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.btAccent.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.xl)
                    .padding(.bottom, Spacing.xxl + Spacing.xl)
                    .opacity(contentVisible ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: contentVisible)
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .confirmationDialog("Are you sure you want to sign out?", isPresented: $showLogoutConfirm, titleVisibility: .visible) {
            Button("Sign Out", role: .destructive) {
                session.logout()
                onLogout?()
            }
            Button("Cancel", role: .cancel) {}
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                contentVisible = true
            }
        }
    }

    // MARK: - Avatar Banner
    private var avatarBanner: some View {
        ZStack(alignment: .bottomLeading) {
            // Gradient background
            LinearGradient.btPrimaryGradient
                .overlay(
                    ZStack {
                        Circle().fill(Color.white.opacity(0.08)).frame(width: 180).offset(x: 130, y: -40)
                        Circle().fill(Color.white.opacity(0.05)).frame(width: 100).offset(x: 170, y: 30)
                    }
                )
                .frame(height: 200)
                .clipShape(RoundedCorner(radius: 32, corners: [.bottomLeft, .bottomRight]))

            HStack(alignment: .bottom, spacing: Spacing.md) {
                // Avatar circle with initials
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 80, height: 80)
                        .btDeepShadow(color: Color.btPrimary)

                    Text(initials)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.btPrimary)
                }
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 80, height: 80)
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(session.current?.name ?? "Patient")
                        .font(.btTitle2)
                        .foregroundColor(.white)
                    Text("ID: \(session.current?.patient_id ?? "—")")
                        .font(.btCaption)
                        .foregroundColor(.white.opacity(0.75))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.lg)
        }
    }
}

// MARK: - Profile Info Card
private struct ProfileInfoCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    let delay: Double

    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.btCaption2)
                    .foregroundColor(.btTextSecond)
                Text(value)
                    .font(.btHeadline)
                    .foregroundColor(.btTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.md)
        .background(Color.btSurface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .btCardShadow()
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                appeared = true
            }
        }
    }
}

// MARK: - Profile Link Row
private struct ProfileLinkRow: View {
    let icon: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
            }
            Text(label)
                .font(.btBodyMedium)
                .foregroundColor(.btTextPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.btTextTertiary)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

// MARK: - Placeholders (kept for compatibility)
struct PatientProfilePlaceholder: View {
    var body: some View { PatientProfileView() }
}
struct PatientAppointmentsPlaceholder: View {
    var body: some View {
        VStack { Text("Appointments").font(.btTitle2) }
            .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        PatientProfileView()
            .environmentObject(PatientSession(current: PatientProfile(
                patient_id: "P001", name: "Arjun", age: 52, gender: "Male", occupation: "Engineer"
            )))
    }
}


// MARK: - Preview
#Preview {
    NavigationStack {
        PatientProfileView()
            .environmentObject(PatientSession(current: PatientProfile(
                patient_id: "P001", name: "Arjun", age: 52, gender: "Male", occupation: "Engineer"
            )))
    }
}
