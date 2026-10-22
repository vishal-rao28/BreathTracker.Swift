import SwiftUI
import UserNotifications

struct Vaccination: Identifiable {
    let id = UUID()
    let name: String
    var isTaken: Bool
    var date: Date
}

struct VaccinationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var session: PatientSession
    @Binding var isPresented: Bool

    // Standard vaccines
    @State private var pneumo = Vaccination(name: "Pneumococcal Vaccination", isTaken: false, date: Date())
    @State private var flu = Vaccination(name: "Flu Vaccine", isTaken: false, date: Date())
    @State private var pertussis = Vaccination(name: "Pertussis Vaccine", isTaken: false, date: Date())
    
    // Shingles Group
    @State private var shinglesTaken = false
    @State private var shinglesDose1Date = Date()
    @State private var shinglesDose2Taken = false
    @State private var shinglesDose2Date = Date()
    
    // 🔔 Alarm times per vaccine (user picks their own time)
    @State private var pneumoAlarmTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var fluAlarmTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var pertussisAlarmTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var shinglesAlarmTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    
    @State private var editingVaccine: String? = nil
    @State private var goToQuestions: Bool = false
    @State private var appeared = false
    @State private var isUploading = false
    @State private var showSuccessAlert = false

    var body: some View {
        ZStack {
            Color.btBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    BTBackButton(action: { dismiss() })
                    Spacer()
                    Text("Vaccination History")
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
                        
                        // Intro text
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Stay Protected")
                                .font(.btTitle)
                                .foregroundColor(.btTextPrimary)
                            Text("Keep track of your respiratory vaccinations for better health management.")
                                .font(.btBodyMedium)
                                .foregroundColor(.btTextSecond)
                        }
                        .padding(.top, Spacing.sm)
                        .padding(.horizontal, Spacing.lg)
                        .opacity(appeared ? 1 : 0)
                        
                        // 1. Standard Vaccines Section
                        VStack(spacing: Spacing.md) {
                            VaccineRow(vaccine: $pneumo, alarmTime: $pneumoAlarmTime, editingVaccine: $editingVaccine)
                            VaccineRow(vaccine: $flu, alarmTime: $fluAlarmTime, editingVaccine: $editingVaccine)
                            VaccineRow(vaccine: $pertussis, alarmTime: $pertussisAlarmTime, editingVaccine: $editingVaccine)
                        }
                        .opacity(appeared ? 1 : 0)
                        
                        // 2. Shingles Section
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            HStack {
                                ZStack {
                                    Circle().fill(Color.btPrimary.opacity(0.1)).frame(width: 40, height: 40)
                                    Image(systemName: "shield.lefthalf.filled")
                                        .foregroundColor(.btPrimary)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Shingles Vaccine")
                                        .font(.btHeadline)
                                        .foregroundColor(.btTextPrimary)
                                    Text(shinglesTaken ? "Dose Entry Active" : "Status: Not Taken")
                                        .font(.btCaption2)
                                        .foregroundColor(shinglesTaken ? .btAccentGreen : .btTextSecond)
                                }
                                Spacer()
                                Toggle("", isOn: $shinglesTaken.animation(.spring()))
                                    .labelsHidden()
                                    .tint(.btPrimary)
                            }
                            .padding(Spacing.md)
                            .background(Color.btSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .btCardShadow()
                            .padding(.horizontal, Spacing.lg)

                            if shinglesTaken {
                                VStack(spacing: Spacing.lg) {
                                    DoseEntryRow(
                                        title: "First Dose",
                                        date: $shinglesDose1Date,
                                        isEditing: Binding(
                                            get: { editingVaccine == "shingles1" },
                                            set: { if $0 { editingVaccine = "shingles1" } else { editingVaccine = nil } }
                                        )
                                    )
                                    
                                    Divider().background(Color.btBorder)
                                    
                                    VStack(alignment: .leading, spacing: Spacing.sm) {
                                        HStack {
                                            Text("Completed Dose 2?")
                                                .font(.btLabel)
                                                .foregroundColor(.btTextPrimary)
                                            Spacer()
                                            Toggle("", isOn: $shinglesDose2Taken.animation(.spring()))
                                                .labelsHidden()
                                                .tint(.btPrimary)
                                                .scaleEffect(0.8)
                                        }
                                        
                                        if shinglesDose2Taken {
                                            DoseEntryRow(
                                                title: "Second Dose",
                                                date: $shinglesDose2Date,
                                                isEditing: Binding(
                                                    get: { editingVaccine == "shingles2" },
                                                    set: { if $0 { editingVaccine = "shingles2" } else { editingVaccine = nil } }
                                                )
                                            )
                                            .transition(.opacity.combined(with: .move(edge: .top)))
                                        }
                                    }
                                    
                                    Divider().background(Color.btBorder)
                                    
                                    // ── Shingles Alarm Card ──────────────────────
                                    VStack(spacing: 0) {
                                        HStack(spacing: Spacing.sm) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.btPrimary.opacity(0.1))
                                                    .frame(width: 32, height: 32)
                                                Image(systemName: "bell.badge.fill")
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundColor(.btPrimary)
                                            }
                                            VStack(alignment: .leading, spacing: 2) {
                                                let info = calculateShinglesNextInfo()
                                                Text("Reminder Alarm")
                                                    .font(.btBodyMedium)
                                                    .foregroundColor(.btTextPrimary)
                                                Text(info)
                                                    .font(.btCaption2)
                                                    .foregroundColor(.btTextSecond)
                                            }
                                            Spacer()
                                            DatePicker("", selection: $shinglesAlarmTime, displayedComponents: .hourAndMinute)
                                                .labelsHidden()
                                                .tint(.btPrimary)
                                        }
                                        .padding(Spacing.md)
                                    }
                                    .background(Color.btBackground.opacity(0.6))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.btPrimary.opacity(0.15), lineWidth: 1)
                                    )
                                }
                                .padding(Spacing.md)
                                .background(Color.btSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 22))
                                .btCardShadow()
                                .padding(.horizontal, Spacing.lg)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .opacity(appeared ? 1 : 0)
                        
                        // Submit
                        BTPrimaryButton(title: "Confirm & Continue", icon: "arrow.right", isLoading: isUploading) {
                            submitVaccinations()
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.md)
                        .padding(.bottom, 60)
                        .opacity(appeared ? 1 : 0)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            fetchExistingVaccinations()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
        }
        .navigationDestination(isPresented: $goToQuestions) {
            QuestionsView(isPresented: $isPresented)
                .navigationBarBackButtonHidden(true)
        }
        .alert("Success", isPresented: $showSuccessAlert) {
            Button("OK") { goToQuestions = true }
        } message: {
            Text("Your vaccination details have been safely recorded!")
        }
    }
    
    // MARK: - Logic
    func submitVaccinations() {
        guard let url = APIConfig.getURL(for: "save_vaccine_dates.php") else { return }
        withAnimation { isUploading = true }
        
        let p_date = pneumo.isTaken ? formatDate(pneumo.date) : "N/A"
        let f_date = flu.isTaken ? formatDate(flu.date) : "N/A"
        let per_date = pertussis.isTaken ? formatDate(pertussis.date) : "N/A"
        let s1_date = shinglesTaken ? formatDate(shinglesDose1Date) : "N/A"
        let s2_date = (shinglesTaken && shinglesDose2Taken) ? formatDate(shinglesDose2Date) : "N/A"

        let payload: [String: Any] = [
            "patient_id": session.current?.patient_id ?? "guest",
            "date_pneumococcal": p_date,
            "date_flu": f_date,
            "date_pertussis": per_date,
            "date_shingles1": s1_date,
            "date_shingles2": s2_date
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                withAnimation { isUploading = false }
                session.current?.date_pneumococcal = p_date
                session.current?.date_flu = f_date
                session.current?.date_pertussis = per_date
                session.current?.date_shingles1 = s1_date
                session.current?.date_shingles2 = s2_date
                
                // ────────────────────────────────────────────────────
                // Schedule Local Notifications based on REAL medical intervals
                // All times use the patient's chosen reminder time
                // ────────────────────────────────────────────────────
                let cal = Calendar.current
                let pId = self.session.current?.patient_id ?? "unknown"
                let vaccineIdentifiers = [
                    "vaccine_flu_vaccine",
                    "vaccine_pneumococcal_vaccination",
                    "vaccine_pertussis_vaccine",
                    "vaccine_shingles"
                ]
                vaccineIdentifiers.forEach { id in
                    LocalNotificationManager.shared.cancelNotification(identifier: id, patientId: pId, syncToServer: false)
                }

                var remindersPayload: [[String: Any]] = []
                let ymdFmt = DateFormatter()
                ymdFmt.dateFormat = "yyyy-MM-dd"
                let hmFmt = DateFormatter()
                hmFmt.dateFormat = "HH:mm"

                // 🫁 FLU VACCINE → Remind every 1 year from vaccination date
                LocalNotificationManager.shared.ensureAuthorization { granted in
                    guard granted else { return }

                    // 🫁 FLU VACCINE → Remind every 1 year from vaccination date
                    if self.flu.isTaken {
                        let nextDue = cal.date(byAdding: .year, value: 1, to: self.flu.date)!
                        let alarmDate = self.mergeTime(self.fluAlarmTime, into: nextDue)
                        LocalNotificationManager.shared.scheduleVaccineReminder(
                            for: alarmDate,
                            title: "Flu Vaccine Due 💉",
                            body: "It has been 1 year since your Flu Shot. Time to get your next one!",
                            identifier: "vaccine_flu_vaccine",
                            patientId: pId,
                            syncToServer: false
                        )
                        remindersPayload.append([
                            "id": "vaccine_flu_vaccine",
                            "title": "Flu Vaccine Due 💉",
                            "body": "It has been 1 year since your Flu Shot. Time to get your next one!",
                            "dueDate": ymdFmt.string(from: nextDue),
                            "alarmTime": hmFmt.string(from: alarmDate),
                            "icon": "syringe.fill",
                            "color": "#10b981"
                        ])
                    }
                    
                    // 🫁 PNEUMOCOCCAL → Remind in 5 years (PPSV23 booster check for COPD patients)
                    if self.pneumo.isTaken {
                        let nextDue = cal.date(byAdding: .year, value: 5, to: self.pneumo.date)!
                        let alarmDate = self.mergeTime(self.pneumoAlarmTime, into: nextDue)
                        LocalNotificationManager.shared.scheduleVaccineReminder(
                            for: alarmDate,
                            title: "Pneumococcal Vaccine Check 💉",
                            body: "It has been 5 years since your Pneumococcal (PPSV23) Vaccine. COPD patients may need a booster — please consult your doctor.",
                            identifier: "vaccine_pneumococcal_vaccination",
                            patientId: pId,
                            syncToServer: false
                        )
                        remindersPayload.append([
                            "id": "vaccine_pneumococcal_vaccination",
                            "title": "Pneumococcal Vaccine Check 💉",
                            "body": "It has been 5 years since your Pneumococcal (PPSV23) Vaccine. COPD patients may need a booster — please consult your doctor.",
                            "dueDate": ymdFmt.string(from: nextDue),
                            "alarmTime": hmFmt.string(from: alarmDate),
                            "icon": "syringe.fill",
                            "color": "#10b981"
                        ])
                    }
                    
                    // 🫁 PERTUSSIS → Remind every 10 years from vaccination date
                    if self.pertussis.isTaken {
                        let nextDue = cal.date(byAdding: .year, value: 10, to: self.pertussis.date)!
                        let alarmDate = self.mergeTime(self.pertussisAlarmTime, into: nextDue)
                        LocalNotificationManager.shared.scheduleVaccineReminder(
                            for: alarmDate,
                            title: "Pertussis Booster Due 💉",
                            body: "It has been 10 years since your Pertussis Vaccine. Time for a booster shot!",
                            identifier: "vaccine_pertussis_vaccine",
                            patientId: pId,
                            syncToServer: false
                        )
                        remindersPayload.append([
                            "id": "vaccine_pertussis_vaccine",
                            "title": "Pertussis Booster Due 💉",
                            "body": "It has been 10 years since your Pertussis Vaccine. Time for a booster shot!",
                            "dueDate": ymdFmt.string(from: nextDue),
                            "alarmTime": hmFmt.string(from: alarmDate),
                            "icon": "syringe.fill",
                            "color": "#10b981"
                        ])
                    }
                    
                    // 🫁 SHINGLES →
                    // If Dose 2 NOT taken yet: Remind in 6 months from Dose 1 to take Dose 2
                    // If Dose 2 IS taken: Remind in 5 years for immunity review (Shingrix may wane)
                    if self.shinglesTaken {
                        if !self.shinglesDose2Taken {
                            // Hasn't had dose 2 yet → remind in 6 months to take dose 2
                            let dose2Due = cal.date(byAdding: .month, value: 6, to: self.shinglesDose1Date)!
                            let alarmDate = self.mergeTime(self.shinglesAlarmTime, into: dose2Due)
                            LocalNotificationManager.shared.scheduleVaccineReminder(
                                for: alarmDate,
                                title: "Shingles Dose 2 Due 💉",
                                body: "It has been 6 months since your first Shingles (Shingrix) dose. Time to get your second and final dose!",
                                identifier: "vaccine_shingles",
                                patientId: pId,
                                syncToServer: false
                            )
                            remindersPayload.append([
                                "id": "vaccine_shingles",
                                "title": "Shingles Dose 2 Due 💉",
                                "body": "It has been 6 months since your first Shingles (Shingrix) dose. Time to get your second and final dose!",
                                "dueDate": ymdFmt.string(from: dose2Due),
                                "alarmTime": hmFmt.string(from: alarmDate),
                                "icon": "syringe.fill",
                                "color": "#10b981"
                            ])
                        } else {
                            // ✅ Both doses complete → Remind in 5 years for immunity review
                            // Shingrix immunity may wane; COPD patients should consult doctor
                            let reviewDue = cal.date(byAdding: .year, value: 5, to: self.shinglesDose2Date)!
                            let alarmDate = self.mergeTime(self.shinglesAlarmTime, into: reviewDue)
                            LocalNotificationManager.shared.scheduleVaccineReminder(
                                for: alarmDate,
                                title: "Shingles Immunity Review 💉",
                                body: "It has been 5 years since your Shingles (Shingrix) series. Immunity may be waning — please consult your doctor for a booster evaluation.",
                                identifier: "vaccine_shingles",
                                patientId: pId,
                                syncToServer: false
                            )
                            remindersPayload.append([
                                "id": "vaccine_shingles",
                                "title": "Shingles Immunity Review 💉",
                                "body": "It has been 5 years since your Shingles (Shingrix) series. Immunity may be waning — please consult your doctor for a booster evaluation.",
                                "dueDate": ymdFmt.string(from: reviewDue),
                                "alarmTime": hmFmt.string(from: alarmDate),
                                "icon": "syringe.fill",
                                "color": "#10b981"
                            ])
                        }
                    }
                    
                    LocalNotificationManager.shared.syncSaveVaccineReminders(reminders: remindersPayload, patientId: pId)
                }
                
                showSuccessAlert = true 
            }
        }.resume()
    }
    
    func fetchExistingVaccinations() {
        guard let patientId = session.current?.patient_id else { return }
        guard let url = APIConfig.getURL(for: "get_patient_details.php") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["patient_id": patientId])
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let q = json["questionnaire"] as? [String: Any] else { return }
            
            DispatchQueue.main.async {
                if let p = q["date_pneumococcal"] as? String, p != "N/A" && !p.isEmpty {
                    pneumo.isTaken = true
                    pneumo.date = parseDate(p)
                }
                if let f = q["date_flu"] as? String, f != "N/A" && !f.isEmpty {
                    flu.isTaken = true
                    flu.date = parseDate(f)
                }
                if let per = q["date_pertussis"] as? String, per != "N/A" && !per.isEmpty {
                    pertussis.isTaken = true
                    pertussis.date = parseDate(per)
                }
                if let s1 = q["date_shingles1"] as? String, s1 != "N/A" && !s1.isEmpty {
                    shinglesTaken = true
                    shinglesDose1Date = parseDate(s1)
                }
                if let s2 = q["date_shingles2"] as? String, s2 != "N/A" && !s2.isEmpty {
                    shinglesDose2Taken = true
                    shinglesDose2Date = parseDate(s2)
                }
                
                session.current?.date_pneumococcal = q["date_pneumococcal"] as? String
                session.current?.date_flu = q["date_flu"] as? String
                session.current?.date_pertussis = q["date_pertussis"] as? String
                session.current?.date_shingles1 = q["date_shingles1"] as? String
                session.current?.date_shingles2 = q["date_shingles2"] as? String
            }
        }.resume()
    }
    
    func parseDate(_ str: String) -> Date {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.date(from: str) ?? Date()
    }
    
    func formatDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: date)
    }
    
    // Merges chosen hour:minute into a target date (e.g., tomorrow)
    func mergeTime(_ time: Date, into targetDate: Date) -> Date {
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day], from: targetDate)
        comps.hour = cal.component(.hour, from: time)
        comps.minute = cal.component(.minute, from: time)
        comps.second = 0
        return cal.date(from: comps) ?? targetDate
    }

    private func calculateShinglesNextInfo() -> String {
        let cal = Calendar.current
        let fmt = DateFormatter()
        fmt.dateFormat = "dd MMM yyyy"
        
        if !shinglesDose2Taken {
            if let nextDate = cal.date(byAdding: .month, value: 6, to: shinglesDose1Date) {
                return "Dose 2 due on \(fmt.string(from: nextDate))"
            }
        } else {
            if let nextDate = cal.date(byAdding: .year, value: 5, to: shinglesDose2Date) {
                return "Next review on \(fmt.string(from: nextDate))"
            }
        }
        return "Rings when next dose is due"
    }
}

// MARK: - Subviews

struct VaccineRow: View {
    @Binding var vaccine: Vaccination
    @Binding var alarmTime: Date
    @Binding var editingVaccine: String?
    @EnvironmentObject var session: PatientSession
    
    @State private var hasActiveAlarm: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(vaccine.name)
                        .font(.btHeadline)
                        .foregroundColor(.btTextPrimary)
                    Text(vaccine.isTaken ? "Status: Recorded" : "Status: Not Taken")
                        .font(.btCaption2)
                        .foregroundColor(vaccine.isTaken ? .btAccentGreen : .btTextSecond)
                }
                Spacer()
                Toggle("", isOn: $vaccine.isTaken.animation(.spring()))
                    .labelsHidden()
                    .tint(.btPrimary)
            }
            .padding(Spacing.md)
            .background(Color.btSurface)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .btCardShadow()
            .padding(.horizontal, Spacing.lg)
            
            if vaccine.isTaken {
                VStack(spacing: Spacing.sm) {
                    // Vaccination Date Picker
                    DoseEntryRow(
                        title: "Vaccination Date",
                        date: $vaccine.date,
                        isEditing: Binding(
                            get: { editingVaccine == vaccine.name },
                            set: { if $0 { editingVaccine = vaccine.name } else { editingVaccine = nil } }
                        )
                    )
                    
                    // 🔔 Alarm Reminder Card
                    VStack(spacing: 0) {
                        if hasActiveAlarm {
                            // Top row: bell icon + label + time picker
                            HStack(spacing: Spacing.sm) {
                                ZStack {
                                    Circle()
                                        .fill(Color.btPrimary.opacity(0.1))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "bell.badge.fill")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.btPrimary)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Reminder Alarm")
                                        .font(.btBodyMedium)
                                        .foregroundColor(.btTextPrimary)
                                    Text(calculateNextDoseInfo())
                                        .font(.btCaption2)
                                        .foregroundColor(.btTextSecond)
                                }
                                
                                Spacer()
                                
                                DatePicker("", selection: $alarmTime, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .tint(.btPrimary)
                            }
                            .padding(Spacing.md)
                            
                            Divider()
                                .background(Color.btBorder)
                                .padding(.horizontal, Spacing.md)
                            
                            // Bottom row: Cancel Alarm button
                            Button {
                                let pId = session.current?.patient_id ?? "unknown"
                                LocalNotificationManager.shared.cancelNotification(
                                    identifier: vaccineIdentifier(),
                                    patientId: pId
                                )
                                withAnimation(.spring()) {
                                    hasActiveAlarm = false
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "bell.slash")
                                        .font(.system(size: 13))
                                    Text("Cancel This Alarm")
                                        .font(.btCaption)
                                }
                                .foregroundColor(.btAccentOrange)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                            }
                        } else {
                            // Cancelled State
                            HStack(spacing: Spacing.sm) {
                                ZStack {
                                    Circle()
                                        .fill(Color.gray.opacity(0.12))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "bell.slash.fill")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.gray)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Alarm Cancelled")
                                        .font(.btBodyMedium)
                                        .foregroundColor(.gray)
                                    Text("You will not be notified")
                                        .font(.btCaption2)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Button {
                                    scheduleAlarmForCurrentVaccine {
                                        withAnimation(.spring()) {
                                            hasActiveAlarm = true
                                        }
                                    }
                                } label: {
                                    Text("Restore")
                                        .font(.btCaption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.btPrimary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.btPrimary.opacity(0.1))
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(Spacing.md)
                        }
                    }
                    .background(Color.btSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.btPrimary.opacity(0.15), lineWidth: 1)
                    )
                    .btCardShadow()
                    .padding(.horizontal, 6)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.sm)
                .transition(.opacity.combined(with: .move(edge: .top)))
                .onAppear {
                    refreshPendingAlarmState()
                }
            }
        }
        .onChange(of: vaccine.isTaken) { oldValue, newValue in
            if newValue {
                refreshPendingAlarmState()
            } else {
                hasActiveAlarm = false
            }
        }
    }

    private func vaccineIdentifier() -> String {
        var baseId = "vaccine_"
        if vaccine.name.contains("Pneumo") { baseId += "pneumo" }
        else if vaccine.name.contains("Flu") { baseId += "flu" }
        else if vaccine.name.contains("Pertussis") { baseId += "pertussis" }
        else { baseId += vaccine.name.lowercased().replacingOccurrences(of: " ", with: "_") }
        return baseId
    }

    private func refreshPendingAlarmState() {
        let pId = session.current?.patient_id ?? "unknown"
        let expectedId = "\(pId)_\(vaccineIdentifier())"
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let exists = requests.contains { $0.identifier == expectedId }
            DispatchQueue.main.async {
                hasActiveAlarm = exists
            }
        }
    }

    private func calculateNextDoseInfo() -> String {
        let cal = Calendar.current
        var intervalYear = 0
        var label = "Next dose"
        
        if vaccine.name.contains("Flu") {
            intervalYear = 1
            label = "Next shot"
        } else if vaccine.name.contains("Pneumo") {
            intervalYear = 5
            label = "Next checkup"
        } else if vaccine.name.contains("Pertussis") {
            intervalYear = 10
            label = "Next booster"
        }
        
        if intervalYear > 0, let dueDate = cal.date(byAdding: .year, value: intervalYear, to: vaccine.date) {
            let fmt = DateFormatter()
            fmt.dateFormat = "dd MMM yyyy"
            return "\(label) due on \(fmt.string(from: dueDate))"
        }
        
        return "Rings when next dose is due"
    }

    private func scheduleAlarmForCurrentVaccine(onSuccess: @escaping () -> Void) {
        let pId = session.current?.patient_id ?? "unknown"
        let cal = Calendar.current

        var intervalYear = 0
        if vaccine.name.contains("Flu") {
            intervalYear = 1
        } else if vaccine.name.contains("Pneumo") {
            intervalYear = 5  // PPSV23 booster check for COPD
        } else if vaccine.name.contains("Pertussis") {
            intervalYear = 10
        }
        // Shingles is managed separately (2-dose series logic) — no standalone restore here
        guard intervalYear > 0, let dueDate = cal.date(byAdding: .year, value: intervalYear, to: vaccine.date) else {
            return
        }

        var dueComponents = cal.dateComponents([.year, .month, .day], from: dueDate)
        dueComponents.hour = cal.component(.hour, from: alarmTime)
        dueComponents.minute = cal.component(.minute, from: alarmTime)
        dueComponents.second = 0
        let finalDueDate = cal.date(from: dueComponents) ?? dueDate

        LocalNotificationManager.shared.ensureAuthorization { granted in
            guard granted else { return }
            LocalNotificationManager.shared.scheduleVaccineReminder(
                for: finalDueDate,
                title: "\(vaccine.name) Due 💉",
                body: "Your next dose is due. Please consult your doctor.",
                identifier: vaccineIdentifier(),
                patientId: pId
            ) { success in
                if success {
                    onSuccess()
                }
            }
        }
    }
}

struct DoseEntryRow: View {
    let title: String
    @Binding var date: Date
    @Binding var isEditing: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text(title)
                    .font(.btLabel)
                    .foregroundColor(.btTextSecond)
                Spacer()
                Button {
                    withAnimation(.spring()) { isEditing.toggle() }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                        Text(formatDisplayDate(date))
                    }
                    .font(.btLabel)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.btPrimary.opacity(0.12))
                    .foregroundColor(.btPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            
            if isEditing {
                DatePicker("", selection: $date, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(.btPrimary)
                    .padding(Spacing.md)
                    .background(Color.btSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .btCardShadow()
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    func formatDisplayDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "dd MMM yyyy"
        return fmt.string(from: date)
    }
}

#Preview {
    NavigationStack {
        VaccinationView(isPresented: .constant(true))
            .environmentObject(PatientSession())
    }
}
