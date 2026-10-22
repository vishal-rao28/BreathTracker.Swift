import SwiftUI

// MARK: - Data Models

struct Report: Identifiable, Hashable {
    let id: UUID
    let title: String
    let condition: String
    let remarks: String
    let imagePlaceholder: String // Default image asset name
    let imageUrl: String?
    let dateStr: String
    let documentUrl: String?

    init(id: UUID = UUID(), title: String, condition: String, remarks: String = "", imagePlaceholder: String, imageUrl: String? = nil, dateStr: String = "", documentUrl: String? = nil) {
        self.id = id
        self.title = title
        self.condition = condition
        self.remarks = remarks
        self.imagePlaceholder = imagePlaceholder
        self.imageUrl = imageUrl
        self.dateStr = dateStr
        self.documentUrl = documentUrl
    }
}

struct MedicationDiaryEntry: Hashable {
    let medicines: [String]
    let remarks: String
    let imagePlaceholder: String // Default image asset name
}

// MARK: - Main View

struct MedicationDiaryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var appeared = false

    // Provided by parent
    let reports: [Report]
    let medicationEntry: MedicationDiaryEntry

    // Images provided/owned by parent
    var reportImages: [UUID: UIImage]
    var medicationImage: UIImage?

    var body: some View {
        ZStack {
            Color.btBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
                HStack {
                    BTBackButton(action: { dismiss() })
                    Spacer()
                    Text("Medical Records")
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
                        
                        // All Reports Section
                        if !reports.isEmpty {
                            VStack(alignment: .leading, spacing: Spacing.md) {
                                // Group reports by type
                                let pftReports = reports.filter { $0.title == "PFT" }
                                let abgReports = reports.filter { $0.title == "ABG" }
                                let walkReports = reports.filter { $0.title == "Walk Test" }
                                
                                if !pftReports.isEmpty {
                                    ReportGroupView(title: "PFT REPORTS", reports: pftReports, appeared: appeared)
                                }
                                if !abgReports.isEmpty {
                                    ReportGroupView(title: "ABG REPORTS", reports: abgReports, appeared: appeared)
                                }
                                if !walkReports.isEmpty {
                                    ReportGroupView(title: "WALK TEST REPORTS", reports: walkReports, appeared: appeared)
                                }
                            }
                        }

                        // Medication Diary Card
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            SectionHeader(title: "Medication & Advice", icon: "pills.fill")
                                .padding(.horizontal, Spacing.lg)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 10)
                                .animation(.spring().delay(0.3), value: appeared)
                            
                            MedicationCard(entry: medicationEntry)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 20)
                                .animation(.spring().delay(0.4), value: appeared)
                        }
                        
                        Spacer(minLength: 60)
                    }
                    .padding(.top, Spacing.sm)
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
}

private struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .foregroundColor(.btPrimary)
                .font(.system(size: 16, weight: .bold))
            Text(title)
                .font(.btLabel)
                .foregroundColor(.btTextSecond)
                .textCase(.uppercase)
            Spacer()
        }
    }
}

// MARK: - Report Group & Card

private struct ReportGroupView: View {
    let title: String
    let reports: [Report]
    let appeared: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Group Header
            HStack {
                Image(systemName: "waveform.path.ecg")
                    .foregroundColor(.btPrimary)
                    .font(.system(size: 16, weight: .bold))
                
                Text(title)
                    .font(.btHeadline)
                    .foregroundColor(.btPrimary)
                
                Spacer()
                
                Text("\(reports.count)")
                    .font(.system(size: 13, weight: .black))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.btPrimary)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.btPrimary.opacity(0.06))
            
            // Rows
            VStack(spacing: 0) {
                ForEach(Array(reports.enumerated()), id: \.element.id) { index, report in
                    ReportRowView(report: report)
                    
                    if index < reports.count - 1 {
                        Divider().background(Color.btBorder)
                    }
                }
            }
            .background(Color.btSurface)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.btBorder, lineWidth: 1))
        .padding(.horizontal, Spacing.lg)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: appeared)
    }
}

private struct ReportRowView: View {
    let report: Report
    
    var conditionColor: Color {
        switch report.condition.lowercased() {
        case "normal": return .btAccentGreen
        case "mild", "moderate": return .btAccentOrange
        case "severe": return .red
        default: return .gray
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Text(report.dateStr)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.btTextSecond)
                    
                    if report.condition != "N/A" {
                        Text(report.condition)
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(conditionColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(conditionColor.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
                
                Text(report.remarks.isEmpty ? "No specific remarks." : report.remarks)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.btTextPrimary)
                    .lineLimit(2)
            }
            
            Spacer(minLength: 10)
            
            // Walk Test reports never have documents — skip the section entirely
            if report.title != "Walk Test" {
                if let docUrl = report.documentUrl, !docUrl.isEmpty {
                    Button {
                        if let url = URL(string: "\(APIConfig.baseURL)/\(docUrl)") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "doc.text")
                            Text("View Document")
                        }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.btPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .overlay(Capsule().stroke(Color.btPrimary, lineWidth: 1.5))
                    }
                } else {
                    Text("No document")
                        .font(.system(size: 13))
                        .foregroundColor(.btTextTertiary)
                        .padding(.top, 8)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// MARK: - Medication Card

private struct MedicationCard: View {
    let entry: MedicationDiaryEntry
    @EnvironmentObject var session: PatientSession
    @State private var alarmTime: Date = Date()
    @State private var refillAlarmTime: Date = Date()  // Stores BOTH the date AND the time
    @State private var showAlarmPicker = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isTakenToday = false

    private var currentPatientId: String {
        session.current?.patient_id ?? "unknown"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Prescribed Medicines")
                        .font(.btHeadline)
                        .foregroundColor(.btTextPrimary)
                    Text("Follow the dosage strictly")
                        .font(.btCaption2)
                        .foregroundColor(.btTextSecond)
                }
                Spacer()
                Image(systemName: "pills.fill")
                    .foregroundColor(.btPrimary)
                    .font(.title3)
            }
            
            Divider().background(Color.btBorder)
            
            VStack(alignment: .leading, spacing: Spacing.lg) {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Active Prescription")
                        .font(.btLabel)
                        .foregroundColor(.btTextPrimary)
                    
                    if entry.medicines.isEmpty {
                        Text("No specific medicines listed currently.")
                            .font(.btBodyMedium)
                            .foregroundColor(.btTextSecond)
                            .padding(Spacing.md)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.btBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(entry.medicines.indices, id: \.self) { idx in
                                HStack(spacing: Spacing.sm) {
                                    ZStack {
                                        Circle().fill(Color.btPrimary.opacity(0.1)).frame(width: 24, height: 24)
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 10, weight: .black))
                                            .foregroundColor(.btPrimary)
                                    }
                                    Text(entry.medicines[idx])
                                        .font(.btBodyMedium)
                                        .foregroundColor(.btTextPrimary)
                                }
                            }
                        }
                        .padding(Spacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.btPrimary.opacity(0.04))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("General Medical Advice")
                        .font(.btLabel)
                        .foregroundColor(.btTextPrimary)
                    
                    Text(entry.remarks.isEmpty ? "Continue standard respiratory care and monitor symptoms." : entry.remarks)
                        .font(.btBodyMedium)
                        .foregroundColor(.btTextPrimary)
                        .lineSpacing(4)
                        .padding(Spacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.btBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.btBorder, lineWidth: 1))
                }
                
                Divider().background(Color.btBorder)
                
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Inhaler Reminders (On Device Only)")
                        .font(.btLabel)
                        .foregroundColor(.btTextPrimary)
                    
                    // Daily Alarm Picker Trigger
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.btPrimary)
                        
                        DatePicker("Daily Alarm", selection: $alarmTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .tint(.btPrimary)
                        
                        Spacer()
                        
                        Button("Set Alarm") {
                            let pId = session.current?.patient_id ?? "unknown"
                            LocalNotificationManager.shared.ensureAuthorization { granted in
                                DispatchQueue.main.async {
                                    guard granted else {
                                        alertTitle = "Notifications Disabled"
                                        alertMessage = "Please enable notifications for this app in Settings to set inhaler alarms."
                                        showAlert = true
                                        return
                                    }
                                    
                                    LocalNotificationManager.shared.scheduleDailyInhalerAlarm(
                                        time: alarmTime,
                                        title: "Time for your Inhaler 🌬️",
                                        body: "Please take your prescribed dose now.",
                                        patientId: pId
                                    ) { scheduled in
                                        DispatchQueue.main.async {
                                            if scheduled {
                                                let formatter = DateFormatter()
                                                formatter.timeStyle = .short
                                                alertTitle = "Alarm Scheduled"
                                                alertMessage = "You will be reminded every day at \(formatter.string(from: alarmTime))."
                                            } else {
                                                alertTitle = "Could Not Set Alarm"
                                                alertMessage = "Something went wrong while scheduling this reminder. Please try again."
                                            }
                                            showAlert = true
                                        }
                                    }
                                }
                            }
                        }
                        .font(.btBodyMedium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.btPrimary.opacity(0.1))
                        .foregroundColor(.btPrimary)
                        .clipShape(Capsule())
                    }
                    .padding(.top, 4)
                    
                    //  udea8 Inhaler Refill Reminder Card
                    VStack(spacing: 0) {
                        // Header
                        HStack(spacing: Spacing.sm) {
                            ZStack {
                                Circle()
                                    .fill(Color.btAccentOrange.opacity(0.1))
                                    .frame(width: 32, height: 32)
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.btAccentOrange)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Refill Reminder")
                                    .font(.btBodyMedium)
                                    .foregroundColor(.btTextPrimary)
                                Text("Pick the exact date & time to be reminded")
                                    .font(.btCaption2)
                                    .foregroundColor(.btTextSecond)
                            }
                            Spacer()
                        }
                        .padding(Spacing.md)
                        
                        Divider().background(Color.btBorder).padding(.horizontal, Spacing.md)
                        
                        // Date + Time Picker (full date and time combined)
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.btPrimary)
                                    .font(.system(size: 13))
                                Text("Date")
                                    .font(.btCaption)
                                    .foregroundColor(.btTextSecond)
                                Spacer()
                                DatePicker("", selection: $refillAlarmTime, in: Date()..., displayedComponents: .date)
                                    .labelsHidden()
                                    .tint(.btPrimary)
                            }
                            
                            Divider().background(Color.btBorder)
                            
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.btPrimary)
                                    .font(.system(size: 13))
                                Text("Time")
                                    .font(.btCaption)
                                    .foregroundColor(.btTextSecond)
                                Spacer()
                                DatePicker("", selection: $refillAlarmTime, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .tint(.btPrimary)
                            }
                        }
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                        
                        Divider().background(Color.btBorder).padding(.horizontal, Spacing.md)
                        
                        // Set Alarm Button
                        Button {
                            let pId = session.current?.patient_id ?? "unknown"
                            LocalNotificationManager.shared.ensureAuthorization { granted in
                                DispatchQueue.main.async {
                                    guard granted else {
                                        alertTitle = "Notifications Disabled"
                                        alertMessage = "Please enable notifications for this app in Settings to set refill reminders."
                                        showAlert = true
                                        return
                                    }
                                    
                                    LocalNotificationManager.shared.scheduleInhalerCompletedReminder(
                                        time: refillAlarmTime,
                                        title: "Inhaler Empty! 🚨",
                                        body: "You've marked your inhaler as empty. Reminder to request a refill!",
                                        patientId: pId
                                    ) { scheduled in
                                        DispatchQueue.main.async {
                                            if scheduled {
                                                let fmt = DateFormatter()
                                                fmt.dateStyle = .medium
                                                fmt.timeStyle = .short
                                                alertTitle = "Refill Reminder Set ✅"
                                                alertMessage = "You'll be reminded to get a refill on \(fmt.string(from: refillAlarmTime))."
                                            } else {
                                                alertTitle = "Could Not Set Reminder"
                                                alertMessage = "Something went wrong while scheduling this reminder. Please try again."
                                            }
                                            showAlert = true
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "bell.badge.fill")
                                    .font(.system(size: 13))
                                Text("Set Refill Alarm")
                                    .font(.btBodyMedium)
                            }
                            .foregroundColor(.btAccentOrange)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }
                    }
                    .background(Color.btSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.btAccentOrange.opacity(0.2), lineWidth: 1)
                    )
                    .btCardShadow()
                    .padding(.top, 4)
                    
                    Divider().background(Color.btBorder).padding(.vertical, Spacing.sm)
                    
                    // Manual Daily Taken Toggle
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Daily Dose Tracking")
                            .font(.btLabel)
                            .foregroundColor(.btTextPrimary)
                        
                        if isTakenToday {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.btAccentGreen)
                                    .font(.system(size: 20))
                                Text("Inhaler Taken Today!")
                                    .font(.btHeadline)
                                    .foregroundColor(.btAccentGreen)
                                Spacer()
                            }
                            .padding(Spacing.md)
                            .background(Color.btAccentGreen.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        } else {
                            Button {
                                // Mark as taken
                                let dateString = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
                                UserDefaults.standard.set(true, forKey: "inhaler_taken_\(currentPatientId)_\(dateString)")
                                
                                // NEW: Save to Server database
                                InhalerAPI.markAsTaken(patientId: currentPatientId)
                                
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    isTakenToday = true
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "lungs.fill")
                                    Text("Mark Inhaler as Taken")
                                }
                                .font(.btHeadline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.btAccentGreen)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                    }
                }
            }
        }
        .padding(Spacing.lg)
        .background(Color.btSurface)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .btCardShadow()
        .padding(.horizontal, Spacing.lg)
        .alert(alertTitle, isPresented: $showAlert) {
            Button("Got it!", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            checkInhalerStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
            checkInhalerStatus()
        }
    }
    
    private func checkInhalerStatus() {
        let dateString = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        let localTaken = UserDefaults.standard.bool(forKey: "inhaler_taken_\(currentPatientId)_\(dateString)")
        if localTaken {
            isTakenToday = true
            return
        }

        // Query server for historical taken dates to sync (e.g. if done on web)
        guard !currentPatientId.isEmpty, currentPatientId != "unknown" else { return }
        guard let url = APIConfig.getURL(for: "get_inhaler_history.php") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["patient_id": currentPatientId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }

            struct HistoryResponse: Codable {
                let status: String
                let taken_dates: [String]?
            }

            if let decoded = try? JSONDecoder().decode(HistoryResponse.self, from: data),
               decoded.status == "success",
               let dates = decoded.taken_dates {

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let todayStr = formatter.string(from: Date())

                if dates.contains(todayStr) {
                    DispatchQueue.main.async {
                        withAnimation(.spring()) {
                            isTakenToday = true
                            UserDefaults.standard.set(true, forKey: "inhaler_taken_\(currentPatientId)_\(dateString)")
                        }
                    }
                }
            }
        }.resume()
    }
}

