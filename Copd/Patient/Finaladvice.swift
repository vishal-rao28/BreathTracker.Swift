import SwiftUI

struct FinalAdviceView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var session: PatientSession
    
    @State var advice: [Report] = []
    @State var medicationEntry = MedicationDiaryEntry(
        medicines: [],
        remarks: "No remarks provided by doctor yet.",
        imagePlaceholder: "medication_report"
    )

    @State var reportImages: [UUID: UIImage] = [:]
    @State var medicationImage: UIImage? = nil
    @State private var isLoading = true
    @State private var appeared = false

    var body: some View {
        ZStack {
            Color.btBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    BTBackButton(action: { dismiss() })
                    Spacer()
                    Text("Treatment Advice")
                        .font(.btHeadline)
                        .foregroundColor(.btTextPrimary)
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.sm)
                .background(Color.btBackground)

                if isLoading {
                    Spacer()
                    VStack(spacing: Spacing.md) {
                        ProgressView().tint(.btPrimary).scaleEffect(1.5)
                        Text("Gathering your records...")
                            .font(.btBodyMedium)
                            .foregroundColor(.btTextSecond)
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: Spacing.xl) {
                            
                            // Intro Header
                            VStack(alignment: .leading, spacing: Spacing.sm) {
                                Text("Your Care Plan")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(.btTextPrimary)
                                Text("Review your latest medical checkup results, medications, and therapeutic resources.")
                                    .font(.btBody)
                                    .foregroundColor(.btTextSecond)
                                    .lineSpacing(4)
                            }
                            .padding(.top, Spacing.md)
                            .padding(.horizontal, Spacing.lg)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 10)

                            VStack(spacing: Spacing.lg) {
                                // Card 1: COPD Review
                                NavigationLink {
                                    CopdReviewView()
                                        .navigationBarBackButtonHidden(true)
                                } label: {
                                    AdviceCardModern(
                                        title: "COPD Health Review",
                                        subtitle: "Personalized medical checklist",
                                        icon: "doc.text.magnifyingglass",
                                        color: .btPrimary,
                                        delay: 0.1
                                    )
                                }
                                .buttonStyle(.plain)

                                // Card 2: Medication Diary
                                NavigationLink {
                                    MedicationDiaryView(
                                        reports: advice,
                                        medicationEntry: medicationEntry,
                                        reportImages: reportImages,
                                        medicationImage: medicationImage
                                    )
                                    .navigationBarBackButtonHidden(true)
                                } label: {
                                    AdviceCardModern(
                                        title: "Medication Diary",
                                        subtitle: "Active prescriptions & advice",
                                        icon: "pills.fill",
                                        color: .btAccentGreen,
                                        delay: 0.2
                                    )
                                }
                                .buttonStyle(.plain)

                                // Card 3: Activity Diary (Videos)
                                NavigationLink {
                                    VideosView()
                                        .navigationBarBackButtonHidden(true)
                                } label: {
                                    AdviceCardModern(
                                        title: "Pulmonary Rehab",
                                        subtitle: "Guided videos and exercises",
                                        icon: "play.circle.fill",
                                        color: .btAccentPurple,
                                        delay: 0.3
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, Spacing.lg)
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            fetchAllData()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }

    private func fetchAllData() {
        guard let patientId = session.current?.patient_id else {
            isLoading = false
            return
        }
        
        isLoading = true
        let group = DispatchGroup()
        
        var fetchedReports: [Report] = []
        var fetchedMedication = MedicationDiaryEntry(medicines: [], remarks: "No remarks provided by doctor yet.", imagePlaceholder: "medication_report")
        
        group.enter()
        fetchMedicalReports(patientId: patientId) { reports in
            if let reports = reports {
                fetchedReports.append(contentsOf: reports)
            }
            group.leave()
        }
        
        group.enter()
        fetchMedicationDiary(patientId: patientId) { entry in
            if let e = entry { fetchedMedication = e }
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.advice = fetchedReports // Already sorted by date in backend normally, or we just pass it
            self.medicationEntry = fetchedMedication
            self.isLoading = false
        }
    }
    
    private func fetchMedicalReports(patientId: String, completion: @escaping ([Report]?) -> Void) {
        guard let url = APIConfig.getURL(for: "get_medical_reports.php") else { completion(nil); return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["patient_id": patientId])
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let status = json["status"] as? String, status == "success" else {
                completion(nil)
                return
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "dd MMM yyyy"
            
            var allReports: [Report] = []
            
            func formatDate(_ str: String) -> String {
                if let d = dateFormatter.date(from: str) {
                    return displayFormatter.string(from: d)
                }
                return str
            }
            
            func normalizeImagePath(_ path: String?) -> String? {
                guard let p = path, !p.isEmpty else { return nil }
                return p.hasPrefix("/") ? String(p.dropFirst()) : p
            }
            
            if let pftHist = json["pft_history"] as? [[String: Any]] {
                for r in pftHist {
                    allReports.append(Report(
                        id: UUID(),
                        title: "PFT",
                        condition: r["condition"] as? String ?? "Unknown",
                        remarks: r["comments"] as? String ?? "",
                        imagePlaceholder: "medication_report",
                        dateStr: formatDate(r["created_at"] as? String ?? ""),
                        documentUrl: normalizeImagePath(r["image_path"] as? String)
                    ))
                }
            }
            
            if let abgHist = json["abg_history"] as? [[String: Any]] {
                for r in abgHist {
                    allReports.append(Report(
                        id: UUID(),
                        title: "ABG",
                        condition: r["condition"] as? String ?? "Unknown",
                        remarks: r["comments"] as? String ?? "",
                        imagePlaceholder: "medication_report",
                        dateStr: formatDate(r["created_at"] as? String ?? ""),
                        documentUrl: normalizeImagePath(r["image_path"] as? String)
                    ))
                }
            }
            
            if let walkHist = json["walk_test_history"] as? [[String: Any]] {
                for r in walkHist {
                    allReports.append(Report(
                        id: UUID(),
                        title: "Walk Test",
                        condition: "N/A",
                        remarks: r["description"] as? String ?? "",
                        imagePlaceholder: "medication_report",
                        dateStr: formatDate(r["created_at"] as? String ?? ""),
                        documentUrl: normalizeImagePath(r["image_path"] as? String)
                    ))
                }
            }
            
            // Backend returns data ordered by created_at DESC for each history type.
            completion(allReports)
        }.resume()
    }
    
    private func fetchMedicationDiary(patientId: String, completion: @escaping (MedicationDiaryEntry?) -> Void) {
        guard let url = APIConfig.getURL(for: "get_medication_diary.php?patient_id=\(patientId)") else { completion(nil); return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let status = json["status"] as? String, status == "success" else {
                completion(nil)
                return
            }
            let entry = MedicationDiaryEntry(
                medicines: json["medicines"] as? [String] ?? [],
                remarks: json["remarks"] as? String ?? "No remarks provided by doctor yet.",
                imagePlaceholder: "medication_report"
            )
            completion(entry)
        }.resume()
    }
}

// MARK: - Modern Advice Card
struct AdviceCardModern: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let delay: Double
    
    @State private var appeared = false

    var body: some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 68, height: 68)
                
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(color)
            }
            .overlay(Circle().stroke(color.opacity(0.1), lineWidth: 1))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.btTitle3)
                    .foregroundColor(.btTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                Text(subtitle)
                    .font(.btBodyMedium)
                    .foregroundColor(.btTextSecond)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.btTextTertiary)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.lg)
        .background(Color.btSurface)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .btDeepShadow(color: color.opacity(0.4))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                appeared = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        FinalAdviceView()
            .environmentObject(PatientSession())
    }
}
