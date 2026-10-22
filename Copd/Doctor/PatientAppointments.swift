import SwiftUI
import Foundation

// MARK: - Model

enum AppointmentStatus: String, CaseIterable, Identifiable {
    case accepted = "Accept"
    case rejected = "Reject"
    case pending = "Pending"
    
    var id: String { rawValue }
}

// MARK: - ViewModel

@MainActor
final class PatientAppointmentsVM: ObservableObject {
    @Published var searchText: String = ""
    @Published var selectedStatus: AppointmentStatus = .accepted
    @Published private(set) var items: [PatientNotification] = []
    @Published var isLoading = false
    
    func fetchAppointments() {
        guard let url = APIConfig.getURL(for: "fetch_appointments.php") else { return }
        isLoading = true
        
        let currentStatus = self.selectedStatus
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            Task { @MainActor in
                self.isLoading = false
            }
            guard let data = data else { return }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let appts = json["appointments"] as? [[String: Any]] {
                    
                    let fetched = appts.compactMap { dict -> PatientNotification? in
                        let id = "\(dict["appointment_id"] ?? "")"
                        let pid = "\(dict["patient_id"] ?? "")"
                        let name = dict["name"] as? String ?? "Unnamed"
                        let age = Int("\(dict["age"] ?? "0")") ?? 0
                        let gender = dict["gender"] as? String ?? "Other"
                        let symptoms = dict["symptoms"] as? String ?? ""
                        let phone = dict["contact"] as? String ?? ""
                        let email = dict["email"] as? String ?? ""
                        let address = dict["address"] as? String ?? ""
                        let copd = "\(dict["copd_confirmed"] ?? "")"
                        let rawStatus = dict["status"] as? String ?? "Pending"
                        
                        var matchesStatus = false
                        if currentStatus == .accepted && rawStatus.lowercased() == "accepted" { matchesStatus = true }
                        else if currentStatus == .rejected && rawStatus.lowercased() == "rejected" { matchesStatus = true }
                        else if currentStatus == .pending && rawStatus.lowercased() == "pending" { matchesStatus = true }
                        
                        guard matchesStatus else { return nil }
                        
                        return PatientNotification(
                            id: id,
                            patientId: pid,
                            name: name,
                            age: age,
                            gender: gender,
                            symptoms: symptoms,
                            phone: phone,
                            isPending: rawStatus.lowercased() == "pending",
                            email: email,
                            address: address,
                            copdConfirmed: copd == "1" ? "Yes" : "No",
                            durationSymptoms: dict["duration_symptoms"] as? String ?? "",
                            medications: dict["medications"] as? String ?? "",
                            allergies: dict["allergies"] as? String ?? "",
                            smokingStatus: dict["smoking_status"] as? String ?? "",
                            preferredDate: dict["preferred_date"] as? String ?? "",
                            preferredTime: dict["preferred_time"] as? String ?? "",
                            consultationMode: dict["consultation_mode"] as? String ?? ""
                        )
                    }
                    
                    // Filter to keep only unique patients (latest appointment)
                    let uniqueItems = Array(Dictionary(grouping: fetched, by: { $0.patientId }).values.compactMap { $0.first })
                    
                    Task { @MainActor in
                        self.items = uniqueItems.sorted { $0.name < $1.name }
                    }
                }
            } catch {
                print("Error parsing appointments: \(error)")
            }
        }.resume()
    }
    
    var filteredItems: [PatientNotification] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return items.filter { item in
            guard !q.isEmpty else { return true }
            return item.name.localizedCaseInsensitiveContains(q)
                || String(item.age).contains(q)
                || item.phone.localizedCaseInsensitiveContains(q)
        }
    }
    
    func setStatus(_ item: PatientNotification, to newStatus: AppointmentStatus) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        
        let oldStatus = items[idx].isPending
        withAnimation {
            items[idx].isPending = (newStatus == .pending)
        }
        
        guard let url = APIConfig.getURL(for: "update_appointment_status.php") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let statusString = (newStatus == .accepted) ? "Accepted" : (newStatus == .rejected ? "Rejected" : "Pending")
        let body: [String: Any] = [
            "appointment_id": item.id,
            "status": statusString
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error updating status: \(error)")
                Task { @MainActor in
                    withAnimation { self.items[idx].isPending = oldStatus }
                }
            } else {
                Task { @MainActor in
                    withAnimation { self.items.removeAll { $0.id == item.id } }
                }
            }
        }.resume()
    }
}

// MARK: - View

struct PatientAppointmentsView: View {
    @StateObject private var vm = PatientAppointmentsVM()
    @Environment(\.dismiss) private var dismiss
    @State private var contentVisible = false
    
    var body: some View {
        ZStack {
            Color.btBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
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
                    Text("Appointments")
                        .font(.btHeadline)
                        .foregroundColor(.btTextPrimary)
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.sm)
                
                // Search field
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.btTextTertiary)
                    
                    TextField("Search patient", text: $vm.searchText)
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
                .offset(y: contentVisible ? 0 : -10)
                
                // Segmented filter bar
                HStack(spacing: Spacing.sm) {
                    segment(title: "Accept", isSelected: vm.selectedStatus == .accepted, tint: .btAccentGreen) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { 
                            vm.selectedStatus = .accepted 
                            vm.fetchAppointments()
                        }
                    }
                    segment(title: "Reject", isSelected: vm.selectedStatus == .rejected, tint: .btAccentOrange) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { 
                            vm.selectedStatus = .rejected 
                            vm.fetchAppointments()
                        }
                    }
                    segment(title: "Pending", isSelected: vm.selectedStatus == .pending, tint: .btAccentPurple) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { 
                            vm.selectedStatus = .pending 
                            vm.fetchAppointments()
                        }
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.md)
                .opacity(contentVisible ? 1 : 0)
                
                if vm.isLoading {
                    Spacer()
                    ProgressView().scaleEffect(1.5).tint(.btDoctorPrimary)
                    Spacer()
                } else if vm.filteredItems.isEmpty {
                    Spacer()
                    VStack(spacing: Spacing.md) {
                        ZStack {
                            Circle().fill(Color.btDoctorPrimary.opacity(0.1)).frame(width: 100, height: 100)
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.system(size: 40))
                                .foregroundColor(.btDoctorPrimary.opacity(0.6))
                        }
                        Text("No \(vm.selectedStatus.rawValue) Appointments")
                            .font(.btHeadline)
                            .foregroundColor(.btTextSecond)
                    }
                    Spacer()
                } else {
                    // List
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: Spacing.md) {
                            ForEach(Array(vm.filteredItems.enumerated()), id: \.element.id) { index, item in
                                NavigationLink {
                                    PatientReports(patientId: item.patientId)
                                        .navigationBarBackButtonHidden(true)
                                } label: {
                                    DoctorAppointmentDetailRow(item: item, delay: Double(index) * 0.05)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.top, Spacing.xs)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            vm.fetchAppointments()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                contentVisible = true
            }
        }
    }
    
    private func segment(title: String, isSelected: Bool, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.btLabel)
                .foregroundColor(isSelected ? .white : .btTextSecond)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? tint : Color.btSurface)
                .cornerRadius(12)
                .btCardShadow(color: isSelected ? tint.opacity(0.3) : Color.clear)
        }
        .buttonStyle(.plain)
    }
}

private struct DoctorAppointmentDetailRow: View {
    let item: PatientNotification
    let delay: Double
    @State private var appeared = false
    @State private var pressed = false
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.btDoctorPrimary.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: "calendar")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.btDoctorPrimary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.btHeadline)
                    .foregroundColor(.btTextPrimary)
                Text("Age: \(item.age) • \(item.phone)")
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
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .btCardShadow()
        .scaleEffect(pressed ? 0.98 : (appeared ? 1.0 : 0.95))
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay)) {
                appeared = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        PatientAppointmentsView()
    }
}
