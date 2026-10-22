import SwiftUI
import UserNotifications

struct ActiveInhalerReminder: Identifiable {
    let id = UUID()
    let patientId: String
    let title: String
    let body: String
}

@MainActor
class LocalNotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = LocalNotificationManager()
    
    @Published var isAuthorized = false
    @Published var activeInhalerReminder: ActiveInhalerReminder? = nil

    nonisolated private var notificationSound: UNNotificationSound {
        return .default
    }
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        
        let takenAction = UNNotificationAction(identifier: "ACTION_TAKEN", title: "Taken", options: [])
        let snoozeAction = UNNotificationAction(identifier: "ACTION_SNOOZE", title: "Remind Me Later", options: [])
        let category = UNNotificationCategory(identifier: "INHALER_REMINDER", actions: [takenAction, snoozeAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        Task {
            await checkAuthorization()
        }
    }
    
    // Allow showing notifications while the app is actively running/open
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if notification.request.content.categoryIdentifier == "INHALER_REMINDER" {
            let userInfo = notification.request.content.userInfo
            let patientId = userInfo["patientId"] as? String ?? "unknown"
            
            Task { @MainActor in
                LocalNotificationManager.shared.activeInhalerReminder = ActiveInhalerReminder(
                    patientId: patientId,
                    title: notification.request.content.title,
                    body: notification.request.content.body
                )
            }
            completionHandler([.sound])
            return
        }
        completionHandler([.banner, .sound])
    }
    
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        let patientId = userInfo["patientId"] as? String ?? "unknown"
        
        if response.actionIdentifier == "ACTION_TAKEN" {
            let dateString = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
            UserDefaults.standard.set(true, forKey: "inhaler_taken_\(patientId)_\(dateString)")
            UserDefaults.standard.synchronize()
        } else if response.actionIdentifier == "ACTION_SNOOZE" {
            Task { @MainActor in
                LocalNotificationManager.shared.scheduleSnoozeAlarm(patientId: patientId)
            }
        }
        completionHandler()
    }
    
    func scheduleSnoozeAlarm(patientId: String) {
        let content = UNMutableNotificationContent()
        content.title = "Time for your Inhaler 🌬️"
        content.body = "You asked to be reminded later. Please take your prescribed dose now."
        content.sound = notificationSound
        content.categoryIdentifier = "INHALER_REMINDER"
        content.userInfo = ["patientId": patientId]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5 * 60, repeats: false)
        let request = UNNotificationRequest(identifier: "\(patientId)_inhaler_snooze", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Permissions
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            Task { @MainActor in
                self.isAuthorized = granted
                if let error = error {
                    print("Notification authorization error: \(error.localizedDescription)")
                }
            }
        }
    }

    func ensureAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                Task { @MainActor in
                    self.isAuthorized = true
                }
                completion(true)
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                    Task { @MainActor in
                        self.isAuthorized = granted
                        if let error = error {
                            print("Notification authorization error: \(error.localizedDescription)")
                        }
                    }
                    completion(granted)
                }
            default:
                Task { @MainActor in
                    self.isAuthorized = false
                }
                completion(false)
            }
        }
    }
    
    private func checkAuthorization() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        self.isAuthorized = settings.authorizationStatus == .authorized
    }
    
    // MARK: - 1. Daily Inhaler Alarm
    /// Schedules a repeating daily alarm at a specific time
    func scheduleDailyInhalerAlarm(time: Date, title: String, body: String, identifier: String = "inhaler_daily_alarm", patientId: String, completion: ((Bool) -> Void)? = nil) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = notificationSound
        content.categoryIdentifier = "INHALER_REMINDER"
        content.userInfo = ["patientId": patientId]
        
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.hour = calendar.component(.hour, from: time)
        dateComponents.minute = calendar.component(.minute, from: time)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "\(patientId)_\(identifier)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling daily inhaler alarm: \(error)")
                completion?(false)
            } else {
                print("Daily inhaler alarm scheduled successfully for \(dateComponents.hour!):\(dateComponents.minute!)")
                
                let timeFmt = DateFormatter()
                timeFmt.dateFormat = "HH:mm"
                let timeStr = timeFmt.string(from: time)
                
                self.syncSaveReminderToServer(
                    patientId: patientId,
                    id: identifier,
                    title: title,
                    body: body,
                    dueDate: "",
                    alarmTime: timeStr,
                    icon: "wind",
                    color: "#3b82f6"
                )
                completion?(true)
            }
        }
    }
    
    // MARK: - 2. Inhaler Completed / Empty Reminder
    /// Triggers a reminder to refill the inhaler at a specific DATE and TIME chosen by the user
    func scheduleInhalerCompletedReminder(time: Date, title: String, body: String, identifier: String = "inhaler_refill", patientId: String, completion: ((Bool) -> Void)? = nil) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = notificationSound
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: time)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "\(patientId)_\(identifier)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling inhaler completed reminder: \(error)")
                completion?(false)
            } else {
                print("Inhaler refill reminder scheduled for \(time)")
                
                let dateFmt = DateFormatter()
                dateFmt.dateFormat = "yyyy-MM-dd"
                let dateStr = dateFmt.string(from: time)
                
                let timeFmt = DateFormatter()
                timeFmt.dateFormat = "HH:mm"
                let timeStr = timeFmt.string(from: time)
                
                self.syncSaveReminderToServer(
                    patientId: patientId,
                    id: identifier,
                    title: title,
                    body: body,
                    dueDate: dateStr,
                    alarmTime: timeStr,
                    icon: "alert-triangle",
                    color: "#f59e0b"
                )
                completion?(true)
            }
        }
    }
    
    // MARK: - 3. Vaccine Reminder (Future Date)
    /// Schedules a reminder for a specific future date using the exact date + user-chosen time
    func scheduleVaccineReminder(for targetDate: Date, title: String, body: String, identifier: String, patientId: String, syncToServer: Bool = true, completion: ((Bool) -> Void)? = nil) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = notificationSound
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: targetDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "\(patientId)_\(identifier)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling vaccine reminder: \(error)")
                completion?(false)
            } else {
                print("Vaccine reminder scheduled for \(targetDate)")
                
                if syncToServer {
                    let dateFmt = DateFormatter()
                    dateFmt.dateFormat = "yyyy-MM-dd"
                    let dateStr = dateFmt.string(from: targetDate)
                    
                    let timeFmt = DateFormatter()
                    timeFmt.dateFormat = "HH:mm"
                    let timeStr = timeFmt.string(from: targetDate)
                    
                    self.syncSaveReminderToServer(
                        patientId: patientId,
                        id: identifier,
                        title: title,
                        body: body,
                        dueDate: dateStr,
                        alarmTime: timeStr,
                        icon: "syringe.fill",
                        color: "#10b981"
                    )
                }
                completion?(true)
            }
        }
    }
    
    // MARK: - Cancel Notifications
    func cancelNotification(identifier: String, patientId: String, syncToServer: Bool = true) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(patientId)_\(identifier)"])
        if syncToServer {
            self.syncDeleteReminderFromServer(identifier: identifier, patientId: patientId)
        }
    }

    func cancelAllNotifications(for patientId: String) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiersToCancel = requests.map { $0.identifier }.filter { $0.hasPrefix("\(patientId)_") }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToCancel)
        }
        self.syncClearRemindersFromServer(patientId: patientId)
    }
    
    // MARK: - Server Synchronization Helper Methods
    
    nonisolated func syncSaveVaccineReminders(reminders: [[String: Any]], patientId: String) {
        guard let url = APIConfig.getURL(for: "save_reminders.php") else { return }
        
        let payload: [String: Any] = [
            "patient_id": patientId,
            "reminders": reminders
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                print("Failed to sync batch vaccine reminders: \(error.localizedDescription)")
            } else {
                print("Successfully synced batch vaccine reminders to server")
            }
        }.resume()
    }
    
    nonisolated private func parseDateAndTime(dueDate: String, alarmTime: String) -> DateComponents? {
        var comps = DateComponents()
        
        // Parse time: "HH:mm"
        let timeParts = alarmTime.split(separator: ":")
        guard timeParts.count >= 2,
              let hour = Int(timeParts[0]),
              let minute = Int(timeParts[1]) else {
            return nil
        }
        comps.hour = hour
        comps.minute = minute
        
        if !dueDate.isEmpty {
            // Parse date "yyyy-MM-dd"
            let dateParts = dueDate.split(separator: "-")
            if dateParts.count == 3,
               let y = Int(dateParts[0]),
               let m = Int(dateParts[1]),
               let d = Int(dateParts[2]) {
                comps.year = y
                comps.month = m
                comps.day = d
            }
        }
        return comps
    }
    
    nonisolated func syncRemindersFromServer(patientId: String) {
        let hasSynced = UserDefaults.standard.bool(forKey: "has_synced_reminders_to_server_\(patientId)")
        
        guard let url = APIConfig.getURL(for: "get_reminders.php") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["patient_id": patientId])
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Failed to fetch reminders for sync: \(error.localizedDescription)")
                return
            }
            guard let data = data else { return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let status = json["status"] as? String, status == "success",
                   let remindersList = json["reminders"] as? [[String: Any]] {
                    
                    UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                        let prefix = "\(patientId)_"
                        let localPending = requests.filter { $0.identifier.hasPrefix(prefix) }
                        
                        var serverReminderMap: [String: [String: Any]] = [:]
                        for r in remindersList {
                            if let rid = r["id"] as? String {
                                serverReminderMap[rid] = r
                            }
                        }
                        
                        // If it has NEVER synced to the server, upload all local reminders to the server first
                        if !hasSynced && !localPending.isEmpty {
                            print("Performing initial reminders sync to server for patient \(patientId)...")
                            var uploadedCount = 0
                            let uploadGroup = DispatchGroup()
                            
                            for req in localPending {
                                let rid = String(req.identifier.dropFirst(prefix.count))
                                if rid.hasSuffix("_snooze") { continue }
                                
                                // Parse details from local notification request
                                let title = req.content.title
                                let body = req.content.body
                                var dueDate = ""
                                var alarmTime = "09:00"
                                var icon = "bell.fill"
                                var color = "#3b82f6"
                                
                                if rid.hasPrefix("vaccine") {
                                    icon = "syringe.fill"
                                    color = "#10b981"
                                } else if rid == "inhaler_daily_alarm" {
                                    icon = "lungs.fill"
                                    color = "#3b82f6"
                                } else if rid == "inhaler_completed" || rid == "inhaler_refill" {
                                    icon = "exclamationmark.triangle.fill"
                                    color = "#f59e0b"
                                }
                                
                                if let calTrigger = req.trigger as? UNCalendarNotificationTrigger {
                                    let comps = calTrigger.dateComponents
                                    
                                    // Parse time
                                    let h = comps.hour ?? 9
                                    let m = comps.minute ?? 0
                                    alarmTime = String(format: "%02d:%02d", h, m)
                                    
                                    // Parse date
                                    if !calTrigger.repeats, let y = comps.year, let m = comps.month, let d = comps.day {
                                        dueDate = String(format: "%04d-%02d-%02d", y, m, d)
                                    }
                                }
                                
                                uploadGroup.enter()
                                self.syncSaveReminderToServer(
                                    patientId: patientId,
                                    id: rid,
                                    title: title,
                                    body: body,
                                    dueDate: dueDate,
                                    alarmTime: alarmTime,
                                    icon: icon,
                                    color: color
                                ) { success in
                                    if success { uploadedCount += 1 }
                                    uploadGroup.leave()
                                }
                            }
                            
                            uploadGroup.notify(queue: .main) {
                                print("Uploaded \(uploadedCount) local reminders to server.")
                                UserDefaults.standard.set(true, forKey: "has_synced_reminders_to_server_\(patientId)")
                                // After upload completes, run syncRemindersFromServer again to consolidate
                                self.syncRemindersFromServer(patientId: patientId)
                            }
                            return
                        }
                        
                        let group = DispatchGroup()
                        
                        // 1. Cancel local notifications that are NOT in the server reminders list
                        var identifiersToCancel: [String] = []
                        for req in localPending {
                            let rid = String(req.identifier.dropFirst(prefix.count))
                            // Avoid deleting snooze alarms
                            if !rid.hasSuffix("_snooze") {
                                if serverReminderMap[rid] == nil {
                                    identifiersToCancel.append(req.identifier)
                                }
                            }
                        }
                        if !identifiersToCancel.isEmpty {
                            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToCancel)
                            print("Cancelled local notifications for sync: \(identifiersToCancel)")
                        }
                        
                        // 2. Schedule or update local notifications from the server list
                        for (rid, r) in serverReminderMap {
                            let title = r["title"] as? String ?? ""
                            let body = r["body"] as? String ?? ""
                            let dueDate = r["dueDate"] as? String ?? ""
                            let alarmTime = r["alarmTime"] as? String ?? ""
                            
                            let fullId = "\(patientId)_\(rid)"
                            
                            if let comps = self.parseDateAndTime(dueDate: dueDate, alarmTime: alarmTime) {
                                let trigger: UNNotificationTrigger
                                if rid == "inhaler_daily_alarm" {
                                    var timeComps = DateComponents()
                                    timeComps.hour = comps.hour
                                    timeComps.minute = comps.minute
                                    trigger = UNCalendarNotificationTrigger(dateMatching: timeComps, repeats: true)
                                } else {
                                    trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
                                }
                                
                                let content = UNMutableNotificationContent()
                                content.title = title
                                content.body = body
                                content.sound = self.notificationSound
                                if rid == "inhaler_daily_alarm" {
                                    content.categoryIdentifier = "INHALER_REMINDER"
                                    content.userInfo = ["patientId": patientId]
                                }
                                
                                let request = UNNotificationRequest(identifier: fullId, content: content, trigger: trigger)
                                group.enter()
                                UNUserNotificationCenter.current().add(request) { err in
                                    if let err = err {
                                        print("Failed to auto-reschedule reminder \(fullId) on sync: \(err)")
                                    } else {
                                        print("Successfully synced/rescheduled reminder \(fullId)")
                                    }
                                    group.leave()
                                }
                            }
                        }
                        
                        group.notify(queue: .main) {
                            UserDefaults.standard.set(true, forKey: "has_synced_reminders_to_server_\(patientId)")
                            NotificationCenter.default.post(name: NSNotification.Name("RemindersSynced"), object: nil)
                        }
                    }
                }
            } catch {
                print("Failed to decode sync response: \(error)")
            }
        }.resume()
    }
    
    nonisolated private func syncSaveReminderToServer(patientId: String, id: String, title: String, body: String, dueDate: String, alarmTime: String, icon: String, color: String, completion: ((Bool) -> Void)? = nil) {
        guard let url = APIConfig.getURL(for: "save_reminder.php") else {
            completion?(false)
            return
        }
        
        let payload: [String: Any] = [
            "patient_id": patientId,
            "id": id,
            "title": title,
            "body": body,
            "dueDate": dueDate,
            "alarmTime": alarmTime,
            "icon": icon,
            "color": color
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                print("Failed to sync save reminder: \(error.localizedDescription)")
                completion?(false)
            } else {
                print("Successfully synced save reminder to server: \(id)")
                completion?(true)
            }
        }.resume()
    }
    
    nonisolated private func syncDeleteReminderFromServer(identifier: String, patientId: String) {
        guard let url = APIConfig.getURL(for: "delete_reminder.php") else { return }
        
        let payload: [String: Any] = [
            "patient_id": patientId,
            "id": identifier
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                print("Failed to sync delete reminder: \(error.localizedDescription)")
            } else {
                print("Successfully synced delete reminder from server: \(identifier)")
            }
        }.resume()
    }
    
    nonisolated private func syncClearRemindersFromServer(patientId: String) {
        guard let url = APIConfig.getURL(for: "clear_reminders.php") else { return }
        
        let payload: [String: Any] = [
            "patient_id": patientId
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                print("Failed to sync clear reminders: \(error.localizedDescription)")
            } else {
                print("Successfully synced clear reminders from server for patient: \(patientId)")
            }
        }.resume()
    }
}
