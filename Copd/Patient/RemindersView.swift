import SwiftUI
import UserNotifications

// MARK: - Model for a scheduled alarm
struct ScheduledAlarm: Identifiable {
    let id: String          // The notification identifier
    let title: String
    let body: String
    let triggerDescription: String
    let icon: String
    let iconColor: Color
}

// MARK: - RemindersView
struct RemindersView: View {
    @EnvironmentObject var session: PatientSession
    @Environment(\.dismiss) private var dismiss
    @State private var alarms: [ScheduledAlarm] = []
    @State private var appointmentStatus: String? = nil
    @State private var appointmentDate: String = ""
    @State private var appointmentTime: String = ""
    @State private var isLoading = true
    @State private var appeared = false
    @State private var showCancelAllAlert = false

    var body: some View {
        ZStack {
            Color.btBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    BTBackButton(action: {
                        // Navigate back to the Patient Dashboard (Home tab = 0)
                        session.selectedTab = 0
                    })
                    Spacer()
                    Text("My Reminders")
                        .font(.btHeadline)
                        .foregroundColor(.btTextPrimary)
                    Spacer()
                    if !alarms.isEmpty {
                        Button {
                            showCancelAllAlert = true
                        } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.btAccentOrange)
                                .frame(width: 40, height: 40)
                                .background(Color.btAccentOrange.opacity(0.1))
                                .clipShape(Circle())
                        }
                    } else {
                        Color.clear.frame(width: 40, height: 40)
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.sm)

                if isLoading {
                    Spacer()
                    ProgressView().scaleEffect(1.5).tint(.btPrimary)
                    Spacer()
                } else if alarms.isEmpty && (appointmentStatus?.lowercased() != "accepted" && appointmentStatus?.lowercased() != "rejected") {
                    Spacer()
                    VStack(spacing: Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(Color.btPrimary.opacity(0.08))
                                .frame(width: 100, height: 100)
                            Image(systemName: "bell.slash")
                                .font(.system(size: 40))
                                .foregroundColor(.btPrimary.opacity(0.5))
                        }
                        Text("No Reminders Set")
                            .font(.btHeadline)
                            .foregroundColor(.btTextPrimary)
                        Text("Set alarms from the Vaccination History or Medication & Advice pages.")
                            .font(.btBody)
                            .foregroundColor(.btTextSecond)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.xl)
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: Spacing.md) {
                            
                            // ── NEW: Appointment Accepted Notification on Top ──
                            if let status = appointmentStatus, status.lowercased() == "accepted" {
                                HStack(spacing: Spacing.md) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color.btAccentGreen.opacity(0.12))
                                            .frame(width: 50, height: 50)
                                        Image(systemName: "calendar.badge.checkmark")
                                            .font(.system(size: 22))
                                            .foregroundColor(.btAccentGreen)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Appointment Confirmed!")
                                            .font(.btHeadline)
                                            .foregroundColor(.btTextPrimary)
                                        Text("Your doctor has accepted your appointment on \(appointmentDate) at \(appointmentTime).")
                                            .font(.btCaption)
                                            .foregroundColor(.btTextSecond)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    Spacer()
                                }
                                .padding(Spacing.md)
                                .background(Color.btSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.btAccentGreen.opacity(0.3), lineWidth: 1)
                                )
                                .btCardShadow()
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                            
                            if let status = appointmentStatus, status.lowercased() == "rejected" {
                                HStack(spacing: Spacing.md) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color.btAccentOrange.opacity(0.12))
                                            .frame(width: 50, height: 50)
                                        Image(systemName: "calendar.badge.minus")
                                            .font(.system(size: 22))
                                            .foregroundColor(.btAccentOrange)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Appointment Rejected")
                                            .font(.btHeadline)
                                            .foregroundColor(.btTextPrimary)
                                        Text("Unfortunately, your doctor declined your appointment request for \(appointmentDate) at \(appointmentTime).")
                                            .font(.btCaption)
                                            .foregroundColor(.btTextSecond)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    Spacer()
                                }
                                .padding(Spacing.md)
                                .background(Color.btSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.btAccentOrange.opacity(0.3), lineWidth: 1)
                                )
                                .btCardShadow()
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }

                            ForEach(Array(alarms.enumerated()), id: \.element.id) { index, alarm in
                                AlarmCard(alarm: alarm, delay: Double(index) * 0.05) {
                                    // Cancel this specific alarm
                                    let pId = session.current?.patient_id ?? "unknown"
                                    let prefix = "\(pId)_"
                                    let baseId = alarm.id.hasPrefix(prefix) ? String(alarm.id.dropFirst(prefix.count)) : alarm.id
                                    LocalNotificationManager.shared.cancelNotification(identifier: baseId, patientId: pId)
                                    withAnimation(.spring()) {
                                        alarms.removeAll { $0.id == alarm.id }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.sm)
                        .padding(.bottom, 40)
                    }
                    .opacity(appeared ? 1 : 0)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Cancel All Reminders", isPresented: $showCancelAllAlert) {
            Button("Cancel All", role: .destructive) {
                let pId = session.current?.patient_id ?? "unknown"
                LocalNotificationManager.shared.cancelAllNotifications(for: pId)
                withAnimation { alarms.removeAll() }
            }
            Button("Keep", role: .cancel) { }
        } message: {
            Text("Are you sure you want to remove all scheduled reminders?")
        }
        .onAppear {
            if let pId = session.current?.patient_id {
                LocalNotificationManager.shared.syncRemindersFromServer(patientId: pId)
            }
            loadAlarms()
            fetchAppointmentStatus()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RemindersSynced"))) { _ in
            loadAlarms()
        }
    }
    
    private func fetchAppointmentStatus() {
        guard let pId = session.current?.patient_id else { return }
        guard let url = APIConfig.getURL(for: "get_appointment.php") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["patient_id": pId])
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let appt = json["appointment"] as? [String: Any],
                  let status = appt["status"] as? String else { return }
            
            let date = appt["preferred_date"] as? String ?? ""
            let time = appt["preferred_time"] as? String ?? ""
            
            DispatchQueue.main.async {
                withAnimation(.spring()) {
                    self.appointmentStatus = status
                    self.appointmentDate = date
                    self.appointmentTime = time
                }
            }
        }.resume()
    }

    // MARK: - Load pending notifications from system
    private func loadAlarms() {
        isLoading = true
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let currentPid = self.session.current?.patient_id ?? "unknown"
            let filteredRequests = requests.filter { $0.identifier.hasPrefix("\(currentPid)_") }
            
            let mapped = filteredRequests.map { req -> ScheduledAlarm in
                let title = req.content.title
                let body = req.content.body
                let id = req.identifier
                
                // Choose icon and color based on alarm type (strip prefix)
                let prefix = "\(currentPid)_"
                let idWithoutPrefix = id.hasPrefix(prefix) ? String(id.dropFirst(prefix.count)) : id
                let (icon, color) = self.iconAndColor(for: idWithoutPrefix)
                
                // Describe when it will trigger
                var triggerDesc = "Scheduled"
                if let calTrigger = req.trigger as? UNCalendarNotificationTrigger {
                    let comps = calTrigger.dateComponents
                    let timeFmt = DateFormatter()
                    timeFmt.timeStyle = .short
                    timeFmt.dateStyle = .none

                    if calTrigger.repeats {
                        // Daily repeating alarm — only has hour + minute, no date
                        // Show "Every day at 1:00 PM" instead of a broken date
                        if let h = comps.hour, let m = comps.minute {
                            var dummyComps = DateComponents()
                            dummyComps.hour = h
                            dummyComps.minute = m
                            if let time = Calendar.current.date(from: dummyComps) {
                                triggerDesc = "Every day at \(timeFmt.string(from: time))"
                            }
                        }
                    } else {
                        // One-time future alarm — try to show full date + time
                        let fullFmt = DateFormatter()
                        fullFmt.dateStyle = .medium
                        fullFmt.timeStyle = .short
                        
                        if let date = Calendar.current.date(from: comps) {
                            // Check: if year is way in the past (e.g. year 1 = broken date), show time only
                            let year = Calendar.current.component(.year, from: date)
                            if year < 2000 {
                                // Old alarm scheduled without a date — show just the time
                                let timeFmt2 = DateFormatter()
                                timeFmt2.timeStyle = .short
                                triggerDesc = "At \(timeFmt2.string(from: date)) (date not set)"
                            } else {
                                triggerDesc = fullFmt.string(from: date)
                            }
                        }
                    }
                } else if let intervalTrigger = req.trigger as? UNTimeIntervalNotificationTrigger {
                    triggerDesc = "In \(Int(intervalTrigger.timeInterval))s"
                }
                
                return ScheduledAlarm(id: id, title: title, body: body, triggerDescription: triggerDesc, icon: icon, iconColor: color)
            }
            
            DispatchQueue.main.async {
                self.alarms = mapped
                self.isLoading = false
            }
        }
    }
    
    private func iconAndColor(for id: String) -> (String, Color) {
        if id.hasPrefix("vaccine") {
            return ("syringe.fill", Color.btAccentGreen)
        } else if id == "inhaler_daily_alarm" {
            return ("lungs.fill", Color.btPrimary)
        } else if id == "inhaler_completed" || id == "inhaler_refill" {
            return ("exclamationmark.triangle.fill", Color.btAccentOrange)
        }
        return ("bell.fill", Color.btPrimary)
    }
}

// MARK: - Individual Alarm Card
private struct AlarmCard: View {
    let alarm: ScheduledAlarm
    let delay: Double
    let onCancel: () -> Void

    @State private var appeared = false

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(alarm.iconColor.opacity(0.12))
                    .frame(width: 50, height: 50)
                Image(systemName: alarm.icon)
                    .font(.system(size: 22))
                    .foregroundColor(alarm.iconColor)
            }

            // Text info
            VStack(alignment: .leading, spacing: 4) {
                Text(alarm.title)
                    .font(.btHeadline)
                    .foregroundColor(.btTextPrimary)
                    .lineLimit(1)
                Text(alarm.body)
                    .font(.btCaption)
                    .foregroundColor(.btTextSecond)
                    .lineLimit(2)
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                    Text(alarm.triggerDescription)
                        .font(.btCaption2)
                }
                .foregroundColor(alarm.iconColor)
                .padding(.top, 2)
            }

            Spacer()

            // Cancel button
            Button(action: onCancel) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.btAccentOrange)
                    .frame(width: 32, height: 32)
                    .background(Color.btAccentOrange.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(Spacing.md)
        .background(Color.btSurface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .btCardShadow()
        .scaleEffect(appeared ? 1 : 0.9)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay)) {
                appeared = true
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        RemindersView()
            .environmentObject(PatientSession())
    }
}
