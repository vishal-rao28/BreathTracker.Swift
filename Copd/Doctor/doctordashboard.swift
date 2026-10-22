import SwiftUI

struct doctordashboard: View {
    @EnvironmentObject var session: PatientSession

    @State private var showMenu         = false
    @State private var goToPatients     = false
    @State private var goToNotifications = false
    @State private var goToAppointments = false
    @State private var goToUploadVideos = false
    @State private var goToProfile      = false
    @State private var goToLogout       = false
    @State private var goToSearchReports = false

    @State private var notificationCount: Int = 0
    @State private var timer: Timer? = nil
    @State private var contentVisible = false
    @State private var showLogoutAlert = false

    var body: some View {
        ZStack(alignment: .topLeading) {

            // ── Main content ─────────────────────────────────────
            VStack(spacing: 0) {
                doctorHeader
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        doctorHeroBanner
                        doctorActionGrid
                        Spacer(minLength: Spacing.xxl + Spacing.xl)
                    }
                }
            }
            .background(Color.btBackground.ignoresSafeArea())
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $goToNotifications) { NotificationsView() }
            .navigationDestination(isPresented: $goToPatients)      { PatientlistView() }
            .navigationDestination(isPresented: $goToAppointments)  { PatientAppointmentsView().navigationBarBackButtonHidden(true) }
            .navigationDestination(isPresented: $goToUploadVideos)  { UploadVideos().navigationBarBackButtonHidden(true) }
            .navigationDestination(isPresented: $goToSearchReports) { SearchPatientReportsView().navigationBarBackButtonHidden(true) }
            .navigationDestination(isPresented: $goToProfile)       { DoctorProfile().navigationBarBackButtonHidden(true) }
            .navigationDestination(isPresented: $goToLogout)        { AboutScreen2().navigationBarBackButtonHidden(true) }

            // ── Dim overlay ──────────────────────────────────────
            if showMenu {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { showMenu = false }
                    }
                    .zIndex(1)
            }

            // ── Side drawer ──────────────────────────────────────
            if showMenu {
                DoctorSideDrawer(
                    onProfile: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { showMenu = false }
                        goToProfile = true
                    },
                    onLogout: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { showMenu = false }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showLogoutAlert = true
                        }
                    },
                    onClose: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { showMenu = false }
                    }
                )
                .frame(width: 300)
                .transition(.move(edge: .leading))
                .zIndex(2)
            }
        }
        .alert("Sign Out", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                session.logout()
                goToLogout = true
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .onAppear {
            fetchNotificationCount()
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) { contentVisible = true }
            timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in fetchNotificationCount() }
        }
        .onDisappear {
            timer?.invalidate(); timer = nil
        }
    }

    // MARK: - Header
    private var doctorHeader: some View {
        HStack(spacing: Spacing.md) {
            // Menu button
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { showMenu.toggle() }
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.btTextPrimary)
                    .frame(width: 48, height: 48)
                    .background(Color.btSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .btCardShadow()
            }

            Spacer()

            VStack(spacing: 2) {
                Text("Doctor Portal")
                    .font(.btTitle3)
                    .foregroundColor(.btTextPrimary)
                Text("Manage your patients")
                    .font(.btCaption2)
                    .foregroundColor(.btTextSecond)
            }

            Spacer()

            // Notification button
            Button { goToNotifications = true } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.btTextPrimary)
                        .frame(width: 48, height: 48)
                        .background(Color.btSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .btCardShadow()

                    if notificationCount > 0 {
                        BTNotificationBadge(count: notificationCount)
                            .offset(x: 4, y: -4)
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.md)
        .padding(.bottom, Spacing.md)
        .background(Color.btBackground)
        .opacity(contentVisible ? 1 : 0)
        .animation(.easeIn(duration: 0.3), value: contentVisible)
    }

    // MARK: - Hero Banner
    private var doctorHeroBanner: some View {
        ZStack(alignment: .leading) {
            // Gradient background
            LinearGradient.btDoctorGradient
                .overlay(
                    ZStack {
                        Circle().fill(Color.white.opacity(0.1)).frame(width: 220).offset(x: 180, y: -50)
                        Circle().fill(Color.white.opacity(0.06)).frame(width: 160).offset(x: 220, y: 60)
                        Image(systemName: "stethoscope")
                            .font(.system(size: 110, weight: .ultraLight))
                            .foregroundColor(.white.opacity(0.12))
                            .offset(x: 140, y: 0)
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 28))

            VStack(alignment: .leading, spacing: Spacing.sm) {
                BTPillTag(label: "Doctor Dashboard", color: .white)
                    .background(Color.white.opacity(0.25))

                Text("Today's Overview")
                    .font(.btTitle2)
                    .foregroundColor(.white)

                Text("Check pending appointments and patient notifications")
                    .font(.btBody)
                    .foregroundColor(.white.opacity(0.9))
                    .lineSpacing(4)
                    .padding(.top, 2)

                // Stats row
                HStack(spacing: Spacing.lg) {
                    DoctorStatChip(value: "\(notificationCount)", label: "Pending", icon: "clock.fill")
                    DoctorStatChip(value: "Active",               label: "Status",  icon: "checkmark.circle.fill")
                }
                .padding(.top, Spacing.sm)
            }
            .padding(Spacing.lg)
        }
        .frame(height: 210)
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.sm)
        .padding(.bottom, Spacing.lg + Spacing.sm)
        .opacity(contentVisible ? 1 : 0)
        .offset(y: contentVisible ? 0 : 16)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: contentVisible)
    }

    // MARK: - Action Grid
    private var doctorActionGrid: some View {
        VStack(spacing: Spacing.md) {
            BTSectionHeader(title: "Quick Access", subtitle: "Your daily tools")
                .padding(.horizontal, Spacing.lg)

            // Action Cards in 2x2 Grid for compact neatness
            HStack(spacing: Spacing.md) {
                DoctorActionCard(
                    icon: "calendar.badge.clock",
                    title: "Appointments",
                    subtitle: "Manage schedule",
                    color: Color.btDoctorPrimary,
                    gradient: LinearGradient.btDoctorGradient,
                    size: .small,
                    delay: 0.18
                ) { goToAppointments = true }

                DoctorActionCard(
                    icon: "person.3.fill",
                    title: "Patient List",
                    subtitle: "Accepted patients",
                    color: Color.btPrimary,
                    gradient: LinearGradient.btPrimaryGradient,
                    size: .small,
                    delay: 0.24
                ) { goToPatients = true }
            }

            HStack(spacing: Spacing.md) {
                DoctorActionCard(
                    icon: "doc.text.magnifyingglass",
                    title: "Report Search",
                    subtitle: "Find ABG/PFT",
                    color: Color.btAccentOrange,
                    gradient: LinearGradient(colors: [Color.btAccentOrange, Color(hex: "FFD0B5")], startPoint: .topLeading, endPoint: .bottomTrailing),
                    size: .small,
                    delay: 0.30
                ) { goToSearchReports = true }

                DoctorActionCard(
                    icon: "play.rectangle.fill",
                    title: "Videos",
                    subtitle: "Manage library",
                    color: Color.btAccentPurple,
                    gradient: LinearGradient(colors: [Color.btAccentPurple, Color(hex: "9D8EFF")],
                                            startPoint: .topLeading, endPoint: .bottomTrailing),
                    size: .small,
                    delay: 0.36
                ) { goToUploadVideos = true }
            }
        }
        .padding(.horizontal, Spacing.lg)
    }

    // MARK: - Notification Fetch (logic unchanged)
    private func fetchNotificationCount() {
        guard let url = APIConfig.getURL(for: "fetch_appointments.php") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let appts = json["appointments"] as? [[String: Any]] else { return }
            let pending = appts.filter { ($0["status"] as? String ?? "").lowercased() == "pending" }.count
            DispatchQueue.main.async {
                withAnimation(.spring()) { self.notificationCount = pending }
            }
        }.resume()
    }
}

// MARK: - Doctor Stat Chip
private struct DoctorStatChip: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
            VStack(alignment: .leading, spacing: 1) {
                Text(value).font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                Text(label).font(.btCaption2).foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Doctor Action Card
private struct DoctorActionCard: View {
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

    private var height: CGFloat { size == .large ? 130 : 160 }

    var body: some View {
        Button(action: action) {
            ZStack(alignment: size == .large ? .leading : .bottomLeading) {
                gradient.clipShape(RoundedRectangle(cornerRadius: 28))

                // Deco
                Circle().fill(Color.white.opacity(0.1))
                    .frame(width: size == .large ? 100 : 80)
                    .offset(x: size == .large ? 200 : 20, y: size == .large ? -20 : -25)

                if size == .large {
                    HStack(spacing: Spacing.md) {
                        Image(systemName: icon)
                            .font(.system(size: 38, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 74, height: 74)
                            .background(Color.white.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 18))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(title).font(.btHeadline).foregroundColor(.white)
                            Text(subtitle).font(.btCaption).foregroundColor(.white.opacity(0.9)).lineLimit(2)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(Spacing.lg)
                } else {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Image(systemName: icon)
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Color.white.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        Spacer()
                        VStack(alignment: .leading, spacing: 2) {
                            Text(title).font(.btHeadline).foregroundColor(.white)
                            Text(subtitle).font(.btCaption2).foregroundColor(.white.opacity(0.85))
                        }
                    }
                    .padding(Spacing.md)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .btDeepShadow(color: color)
            .scaleEffect(pressed ? 0.96 : (appeared ? 1.0 : 0.9))
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 16)
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75).delay(delay)) { appeared = true }
        }
    }
}

// MARK: - Side Drawer
private struct DoctorSideDrawer: View {
    let onProfile: () -> Void
    let onLogout:  () -> Void
    let onClose:   () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.btSurface.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack {
                        Spacer()
                        Button(action: onClose) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.btTextSecond)
                                .frame(width: 36, height: 36)
                                .background(Color.btSurface2)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.top, 60)
                    .padding(.horizontal, Spacing.lg)

                    // Doctor avatar
                    ZStack {
                        Circle()
                            .fill(LinearGradient.btDoctorGradient)
                            .frame(width: 84, height: 84)
                            .btDeepShadow(color: Color.btDoctorPrimary.opacity(0.35))
                        Image(systemName: "stethoscope")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.sm)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Doctor")
                            .font(.btTitle2)
                            .foregroundColor(.btTextPrimary)
                        Text("Primary Medical Consultant")
                            .font(.btCaption2)
                            .foregroundColor(.btTextSecond)
                    }
                    .padding(.horizontal, Spacing.lg)
                }
                .padding(.bottom, Spacing.md)

                Divider().padding(.horizontal, Spacing.lg)

                // Menu items
                VStack(spacing: Spacing.xs) {
                    DrawerMenuItem(icon: "person.crop.circle.fill", label: "My Profile", color: Color.btDoctorPrimary, action: onProfile)
                    DrawerMenuItem(icon: "rectangle.portrait.and.arrow.right", label: "Sign Out", color: Color.btAccent, action: onLogout)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.md)

                Spacer()

                // Footer
                Text("BreathTrack v1.0")
                    .font(.btCaption2)
                    .foregroundColor(.btTextTertiary)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.xl)
            }
        }
        .frame(maxHeight: .infinity)
        .shadow(color: .black.opacity(0.15), radius: 20, x: 4, y: 0)
    }
}

private struct DrawerMenuItem: View {
    let icon:   String
    let label:  String
    let color:  Color
    let action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(color.opacity(0.12))
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(color)
                }
                Text(label)
                    .font(.btHeadline)
                    .foregroundColor(.btTextPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.btTextTertiary)
            }
            .padding(.all, 12)
            .background(pressed ? Color.btBackground.opacity(0.6) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.2)) { pressed = pressing }
        }, perform: {})
    }
}

// Kept for compile compat
struct DashboardCard: View {
    var title:    String
    var subtitle: String
    var icon:     String
    var color:    Color
    var action:   () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(color.opacity(0.12))
                        .frame(width: 56, height: 56)
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(color)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.btHeadline).foregroundColor(.btTextPrimary)
                    Text(subtitle).font(.btCaption).foregroundColor(.btTextSecond)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.btTextTertiary)
            }
            .padding(Spacing.md)
            .background(Color.btSurface)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .btCardShadow()
        }
        .buttonStyle(.plain)
    }
}

struct VideosView_Placeholder: View {
    var body: some View { Text("Videos Page").font(.btTitle) }
}

#Preview {
    NavigationStack {
        doctordashboard().environmentObject(PatientSession())
    }
}
