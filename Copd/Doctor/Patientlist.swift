import SwiftUI

struct Patient: Identifiable, Hashable {
    let id: String
    let name: String
    let diagnosis: String
    let age: Int
}

struct PatientlistView: View {
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss
    @State private var patients: [Patient] = []
    @State private var isLoading = false
    @State private var contentVisible = false

    var filteredPatients: [Patient] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return patients }
        return patients.filter {
            $0.name.localizedCaseInsensitiveContains(q) ||
            $0.diagnosis.localizedCaseInsensitiveContains(q) ||
            "\($0.age)".contains(q)
        }
    }
    
    var body: some View {
        ZStack {
            Color.btBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Navigation Bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.btTextPrimary)
                            .frame(width: 44, height: 44)
                            .background(Color.btSurface)
                            .clipShape(Circle())
                            .btCardShadow()
                    }
                    Spacer()
                    Text("Patient List")
                        .font(.btHeadline)
                        .foregroundColor(.btTextPrimary)
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.sm)
                .background(Color.btBackground)
                
                // Search Bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.btTextTertiary)
                    
                    TextField("Search patients...", text: $searchText)
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
                
                ZStack {
                    if isLoading {
                        VStack(spacing: Spacing.md) {
                            Spacer()
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(Color.btDoctorPrimary)
                            Text("Loading Patients...")
                                .font(.btBodyMedium)
                                .foregroundColor(.btTextSecond)
                            Spacer()
                        }
                    } else if filteredPatients.isEmpty {
                        VStack(spacing: Spacing.md) {
                            Spacer()
                            ZStack {
                                Circle().fill(Color.btDoctorPrimary.opacity(0.1)).frame(width: 100, height: 100)
                                Image(systemName: "person.2.slash")
                                    .font(.system(size: 40))
                                    .foregroundColor(.btDoctorPrimary.opacity(0.6))
                            }
                            Text(searchText.isEmpty ? "No patients found" : "No results for \"\(searchText)\"")
                                .font(.btHeadline)
                                .foregroundColor(.btTextSecond)
                            Spacer()
                        }
                        .opacity(contentVisible ? 1 : 0)
                        
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: Spacing.sm) {
                                ForEach(Array(filteredPatients.enumerated()), id: \.element.id) { index, patient in
                                    NavigationLink {
                                        SubmitPatientReportView(patientName: patient.name, patientId: patient.id)
                                            .navigationBarBackButtonHidden(true)
                                    } label: {
                                        DoctorPatientRow(patient: patient, delay: Double(index) * 0.05)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, Spacing.lg)
                            .padding(.top, Spacing.xs)
                            .padding(.bottom, 40)
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                contentVisible = true
            }
            fetchPatients()
        }
    }

    private func fetchPatients() {
        guard !isLoading else { return }
        guard let url = APIConfig.getURL(for: "fetch_appointments.php") else { return }
        
        isLoading = true
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async { self.isLoading = false }
            
            guard let data = data else { return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let appointmentList = json["appointments"] as? [[String: Any]] {
                    
                    let fetchedPatients = appointmentList.compactMap { dict -> Patient? in
                        let status = dict["status"] as? String ?? ""
                        let s = status.lowercased()
                        guard s == "accepted" || s == "rejected" else { return nil }
                        guard let name = dict["name"] as? String else { return nil }
                        let id = dict["patient_id"] as? String ?? UUID().uuidString
                        let isCopd = "\(dict["copd_confirmed"] ?? "0")" == "1"
                        let diagnosis = isCopd ? "COPD" : "Awaiting Diagnosis"
                        let age = Int("\(dict["age"] ?? "0")") ?? 0
                        return Patient(id: id, name: name, diagnosis: diagnosis, age: age)
                    }
                    
                    let uniquePatients = Array(Dictionary(grouping: fetchedPatients, by: { $0.id }).values.compactMap { $0.first })
                    DispatchQueue.main.async {
                        self.patients = uniquePatients.sorted(by: { $0.name < $1.name })
                    }
                }
            } catch {
                print("Error parsing patients: \(error)")
            }
        }.resume()
    }
}

struct DoctorPatientRow: View {
    let patient: Patient
    let delay: Double
    
    @State private var appeared = false
    @State private var pressed = false
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // Elegant initial avatar
            ZStack {
                Circle()
                    .fill(LinearGradient.btDoctorGradient)
                    .frame(width: 52, height: 52)
                
                let initials = patient.name.split(separator: " ").prefix(2).map { String($0.prefix(1)) }.joined().uppercased()
                
                Text(initials.isEmpty ? "?" : initials)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(patient.name)
                    .font(.btHeadline)
                    .foregroundColor(.btTextPrimary)
                
                Text("Patient ID: \(patient.id)")
                    .font(.btCaption2)
                    .foregroundColor(.btPrimary)
                    .padding(.bottom, 2)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "stethoscope")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.btAccentOrange)
                        Text(patient.diagnosis)
                            .font(.btCaption2)
                            .foregroundColor(.btTextSecond)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.btDoctorPrimary)
                        Text("\(patient.age) yrs")
                            .font(.btCaption2)
                            .foregroundColor(.btTextSecond)
                    }
                }
            }
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.btTextTertiary)
        }
        .padding(Spacing.md)
        .background(Color.btSurface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
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
}
