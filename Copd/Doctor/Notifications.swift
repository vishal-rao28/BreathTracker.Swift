import SwiftUI

// MARK: - Model

struct PatientNotification: Identifiable, Equatable, Hashable {
    let id: String
    let patientId: String
    var name: String
    var age: Int
    var gender: String
    var symptoms: String
    var phone: String
    var isPending: Bool = true
    
    // Add all fields for detail view
    var email: String = ""
    var address: String = ""
    var copdConfirmed: String = ""
    var durationSymptoms: String = ""
    var medications: String = ""
    var allergies: String = ""
    var smokingStatus: String = ""
    var preferredDate: String = ""
    var preferredTime: String = ""
    var consultationMode: String = ""
}

// MARK: - Event name for cross-screen communication
extension Notification.Name {
    static let notificationAccepted = Notification.Name("NotificationAccepted")
}

// MARK: - ViewModel

@MainActor
final class NotificationsViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published private(set) var items: [PatientNotification] = []
    @Published var isLoading = false
    @Published var showSuccessAlert = false
    @Published var alertMessage = ""
    
    func fetchNotifications() {
        guard let url = APIConfig.getURL(for: "fetch_appointments.php") else { return }
        isLoading = true
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            Task { @MainActor in
                self.isLoading = false
            }
            guard let data = data else { return }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let appts = json["appointments"] as? [[String: Any]] {
                    
                    let fetched = appts.compactMap { dict -> PatientNotification? in
                        let status = dict["status"] as? String ?? "Pending"
                        guard status.lowercased() == "pending" else { return nil }
                        
                        let id = "\(dict["appointment_id"] ?? "")"
                        let patientId = "\(dict["patient_id"] ?? "")"
                        let name = dict["name"] as? String ?? "Unnamed"
                        let age = Int("\(dict["age"] ?? "0")") ?? 0
                        let gender = dict["gender"] as? String ?? "Other"
                        let symptoms = dict["symptoms"] as? String ?? ""
                        let phone = dict["contact"] as? String ?? ""
                        
                        // Extra detail fields
                        let email = dict["email"] as? String ?? ""
                        let address = dict["address"] as? String ?? ""
                        let copd = "\(dict["copd_confirmed"] ?? "")"
                        let duration = dict["duration_symptoms"] as? String ?? ""
                        let meds = dict["medications"] as? String ?? ""
                        let allgs = dict["allergies"] as? String ?? ""
                        let smoking = dict["smoking_status"] as? String ?? ""
                        let date = dict["preferred_date"] as? String ?? ""
                        let time = dict["preferred_time"] as? String ?? ""
                        let mode = dict["consultation_mode"] as? String ?? ""
                        
                        return PatientNotification(
                            id: id,
                            patientId: patientId,
                            name: name,
                            age: age,
                            gender: gender,
                            symptoms: symptoms,
                            phone: phone,
                            isPending: true,
                            email: email,
                            address: address,
                            copdConfirmed: copd == "1" ? "Yes" : "No",
                            durationSymptoms: duration,
                            medications: meds,
                            allergies: allgs,
                            smokingStatus: smoking,
                            preferredDate: date,
                            preferredTime: time,
                            consultationMode: mode
                        )
                    }
                    
                    Task { @MainActor in
                        self.items = fetched
                    }
                }
            } catch {
                print("Error fetching notifications: \(error)")
            }
        }.resume()
    }
    
    var filteredItems: [PatientNotification] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return items }
        return items.filter {
            $0.name.localizedCaseInsensitiveContains(q)
            || $0.symptoms.localizedCaseInsensitiveContains(q)
            || $0.phone.localizedCaseInsensitiveContains(q)
        }
    }
    
    func accept(_ item: PatientNotification) {
        updateStatus(item, to: "Accepted")
    }
    
    func reject(_ item: PatientNotification) {
        updateStatus(item, to: "Rejected")
    }
    
    private func updateStatus(_ item: PatientNotification, to status: String) {
        guard let url = APIConfig.getURL(for: "update_appointment_status.php") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "appointment_id": item.id,
            "status": status
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error == nil {
                Task { @MainActor in
                    withAnimation {
                        self.items.removeAll { $0.id == item.id }
                    }
                    if status == "Accepted" {
                        self.alertMessage = "Patient request accepted successfully!"
                        self.showSuccessAlert = true
                        NotificationCenter.default.post(name: .notificationAccepted, object: item)
                    }
                }
            }
        }.resume()
    }
}

// MARK: - View

struct NotificationsView: View {
    @StateObject private var viewModel = NotificationsViewModel()
    @State private var selectedItem: PatientNotification?
    @Environment(\.dismiss) private var dismiss
    @State private var contentVisible = false
    
    var body: some View {
        ZStack {
            Color.btBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.btTextPrimary)
                            .frame(width: 44, height: 44)
                            .background(Color.btSurface)
                            .clipShape(Circle())
                            .btCardShadow()
                    }
                    Spacer()
                    Text("Notifications")
                        .font(.btHeadline)
                        .foregroundColor(.btTextPrimary)
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.md)
                .background(Color.btBackground)
                .alert("Success", isPresented: $viewModel.showSuccessAlert) {
                    Button("OK") { }
                } message: {
                    Text(viewModel.alertMessage)
                }
                
                // Search Field
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.btTextTertiary)
                    
                    TextField("Search requests...", text: $viewModel.searchText)
                        .font(.btBodyMedium)
                        .foregroundColor(.btTextPrimary)
                        .disableAutocorrection(true)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, 14)
                .background(Color.btSurface)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .btCardShadow()
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.md)
                .opacity(contentVisible ? 1 : 0)
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView().scaleEffect(1.5).tint(.btDoctorPrimary)
                    Spacer()
                } else if viewModel.filteredItems.isEmpty {
                    Spacer()
                    VStack(spacing: Spacing.md) {
                        ZStack {
                            Circle().fill(Color.btDoctorPrimary.opacity(0.1)).frame(width: 100, height: 100)
                            Image(systemName: "bell.slash")
                                .font(.system(size: 40))
                                .foregroundColor(.btDoctorPrimary.opacity(0.6))
                        }
                        Text(viewModel.searchText.isEmpty ? "No new notifications" : "No results found")
                            .font(.btHeadline)
                            .foregroundColor(.btTextSecond)
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: Spacing.md) {
                            ForEach(Array(viewModel.filteredItems.enumerated()), id: \.element.id) { index, item in
                                DoctorNotificationCard(
                                    item: item,
                                    delay: Double(index) * 0.05,
                                    onSelect: { selectedItem = item },
                                    onAccept: { viewModel.accept(item) },
                                    onReject: { viewModel.reject(item) }
                                )
                                .padding(.horizontal, Spacing.lg)
                            }
                        }
                        .padding(.top, Spacing.xs)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(item: $selectedItem) { item in
            AppointmentFormView(appointment: item)
        }
        .onAppear {
            viewModel.fetchNotifications()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                contentVisible = true
            }
        }
    }
}

// MARK: - Card View

private struct DoctorNotificationCard: View {
    let item: PatientNotification
    let delay: Double
    var onSelect: () -> Void
    var onAccept: () -> Void
    var onReject: () -> Void
    
    @State private var appeared = false
    @State private var pressed = false
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            HStack(alignment: .top, spacing: Spacing.md) {
                // Avatar with initial
                ZStack {
                    Circle()
                        .fill(LinearGradient.btDoctorGradient)
                        .frame(width: 48, height: 48)
                        .btDeepShadow(color: Color.btDoctorPrimary.opacity(0.4))
                    Text(initials(from: item.name))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.name)
                        .font(.btHeadline)
                        .foregroundStyle(Color.btTextPrimary)
                    
                    Text("Age: \(item.age) • \(item.gender) • \(item.phone)")
                        .font(.btCaption2)
                        .foregroundStyle(Color.btTextSecond)
                    
                    if !item.symptoms.trimmingCharacters(in: .whitespaces).isEmpty {
                        Text("Symp: \(item.symptoms)")
                            .font(.btCaption)
                            .foregroundStyle(Color.btAccentOrange)
                            .lineLimit(2)
                            .padding(.top, 2)
                    }
                }
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
            .onTapGesture { onSelect() }
            
            HStack(spacing: Spacing.md) {
                Button(action: onReject) {
                    Text("Reject")
                        .font(.btLabel)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.btSurface)
                        .foregroundStyle(Color.btAccentOrange)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.btAccentOrange.opacity(0.3), lineWidth: 1.5)
                        )
                }
                
                Button(action: onAccept) {
                    Text(item.isPending ? "Accept" : "Accepted")
                        .font(.btLabel)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(item.isPending ? Color.btDoctorPrimary : Color.btDoctorPrimary.opacity(0.5))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .btDeepShadow(color: Color.btDoctorPrimary.opacity(0.3))
                }
                .disabled(!item.isPending)
            }
            .padding(.top, Spacing.xs)
        }
        .padding(Spacing.md)
        .background(Color.btSurface)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .btCardShadow()
        .scaleEffect(pressed ? 0.96 : (appeared ? 1.0 : 0.9))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay)) {
                appeared = true
            }
        }

    }
    
    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        let first = parts.first?.first.map(String.init) ?? ""
        let last = parts.dropFirst().first?.first.map(String.init) ?? ""
        let combined = first + last
        return combined.isEmpty ? "P" : combined.uppercased()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        NotificationsView()
    }
}
