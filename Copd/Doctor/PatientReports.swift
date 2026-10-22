import SwiftUI

struct PatientReports: View {
    @Environment(\.dismiss) private var dismiss
    var patientId: String
    
    @State private var patientData: [String: Any] = [:]
    @State private var checkupData: [String: Any] = [:]
    @State private var questionnaireData: [String: Any] = [:]
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
                    Text("Clinical Analysis")
                        .font(.btHeadline)
                        .foregroundColor(.btTextPrimary)
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.sm)

                if isLoading {
                    Spacer()
                    VStack(spacing: Spacing.md) {
                        ProgressView().tint(.btDoctorPrimary).scaleEffect(1.5)
                        Text("Retrieving clinical records...")
                            .font(.btBodyMedium)
                            .foregroundColor(.btTextSecond)
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: Spacing.xl) {
                            
                            // Patient Summary Card
                            VStack(alignment: .leading, spacing: Spacing.lg) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(patientData["name"] as? String ?? "Patient")
                                            .font(.btTitle)
                                            .foregroundColor(.btTextPrimary)
                                        Text("\((patientData["age"] as? Int).map(String.init) ?? (patientData["age"] as? String) ?? "—") yrs • \(patientData["gender"] as? String ?? "N/A")")
                                            .font(.btBodyMedium)
                                            .foregroundColor(.btTextSecond)
                                    }
                                    Spacer()
                                    
                                    let avgScore = Double("\(questionnaireData["average_score"] ?? "0")") ?? 0.0
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text(String(format: "%.2f", avgScore))
                                            .font(.system(size: 32, weight: .heavy, design: .rounded))
                                            .foregroundColor(.btDoctorPrimary)
                                        
                                        let cat = getScoreCategory(avgScore)
                                        Text(cat)
                                            .font(.btCaption2)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(catColor(cat).opacity(0.15))
                                            .foregroundColor(catColor(cat))
                                            .clipShape(Capsule())
                                    }
                                }
                                
                                Divider().background(Color.btBorder)
                                
                                HStack(spacing: Spacing.xl) {
                                    reportDetail(label: "Height", value: "\(patientData["height"] ?? "—") cm")
                                    reportDetail(label: "Weight", value: "\(patientData["weight"] ?? "—") kg")
                                    reportDetail(label: "Occupation", value: patientData["occupation"] as? String ?? "—")
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Reported Diagnosis")
                                        .font(.btCaption2)
                                        .foregroundColor(.btTextSecond)
                                    Text(patientData["diagnosis"] as? String ?? "Chronic Respiratory Condition")
                                        .font(.btHeadline)
                                        .foregroundColor(.btTextPrimary)
                                }
                            }
                            .padding(Spacing.lg)
                            .background(Color.btSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 28))
                            .btCardShadow()
                            .padding(.horizontal, Spacing.lg)
                            .padding(.top, Spacing.sm)
                            .opacity(appeared ? 1 : 0)

                            // Vitals Grid
                            VStack(alignment: .leading, spacing: Spacing.md) {
                                BTSectionHeader(title: "Patient Vitals")
                                    .padding(.horizontal, Spacing.lg)
                                
                                HStack(spacing: Spacing.md) {
                                    ReportVitalBadge(icon: "thermometer", title: "Temp", value: "\(checkupData["temperature"] ?? "—")°F", color: .btAccentOrange, delay: 0.1)
                                    ReportVitalBadge(icon: "lungs.fill", title: "SpO₂", value: "\(checkupData["oxygen_level"] ?? "—")%", color: .btDoctorPrimary, delay: 0.2)
                                    ReportVitalBadge(icon: "wind", title: "Lung", value: "\(checkupData["lung_function"] ?? "—")%", color: .btAccentPurple, delay: 0.3)
                                }
                                .padding(.horizontal, Spacing.lg)
                            }
                            .opacity(appeared ? 1 : 0)

                            // Vaccination Status
                            VStack(alignment: .leading, spacing: Spacing.md) {
                                BTSectionHeader(title: "Vaccination Record")
                                    .padding(.horizontal, Spacing.lg)
                                
                                VStack(spacing: Spacing.sm) {
                                    ReportVaccineRow(title: "Pneumococcal", date: questionnaireData["date_pneumococcal"] as? String)
                                    ReportVaccineRow(title: "Flu Vaccine", date: questionnaireData["date_flu"] as? String)
                                    ReportVaccineRow(title: "Pertussis", date: questionnaireData["date_pertussis"] as? String)
                                    ReportVaccineRow(title: "Shingles (Dose 1)", date: questionnaireData["date_shingles1"] as? String)
                                    ReportVaccineRow(title: "Shingles (Dose 2)", date: questionnaireData["date_shingles2"] as? String)
                                }
                                .padding(Spacing.md)
                                .background(Color.btSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 22))
                                .btCardShadow()
                                .padding(.horizontal, Spacing.lg)
                            }
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 20)
                            .animation(.spring().delay(0.4), value: appeared)

                            // Questionnaire Analysis
                            VStack(alignment: .leading, spacing: Spacing.md) {
                                BTSectionHeader(title: "Questionnaire Answers")
                                    .padding(.horizontal, Spacing.lg)
                                
                                VStack(spacing: 0) {
                                    // Table Header
                                    HStack {
                                        Text("Question")
                                            .font(.btHeadline)
                                            .foregroundColor(.btTextPrimary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Text("Answer")
                                            .font(.btHeadline)
                                            .foregroundColor(.btTextPrimary)
                                            .frame(width: 140, alignment: .trailing)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Color.btSurface2.opacity(0.5))
                                    
                                    ReportSymptomRow(q: "Q1. I never cough (0) - I cough all the time (5)", a: "\(questionnaireData["q1_cough"] ?? "0")")
                                    Divider().background(Color.btBorder).padding(.horizontal, Spacing.md)
                                    ReportSymptomRow(q: "Q2. No phlegm (0) - Chest full of phlegm (5)", a: "\(questionnaireData["q2_phlegm"] ?? "0")")
                                    Divider().background(Color.btBorder).padding(.horizontal, Spacing.md)
                                    ReportSymptomRow(q: "Q3. Chest does not feel tight (0) - Feels tight (5)", a: "\(questionnaireData["q3_chest_tightness"] ?? "0")")
                                    Divider().background(Color.btBorder).padding(.horizontal, Spacing.md)
                                    ReportSymptomRow(q: "Q4. Not breathless (0) - Very breathless (5)", a: "\(questionnaireData["q4_breathlessness"] ?? "0")")
                                    Divider().background(Color.btBorder).padding(.horizontal, Spacing.md)
                                    ReportSymptomRow(q: "Q5. No limitation (0) - Very limited (5)", a: "\(questionnaireData["q5_activity_limitation"] ?? "0")")
                                    Divider().background(Color.btBorder).padding(.horizontal, Spacing.md)
                                    ReportSymptomRow(q: "Q6. Confident leaving home (0) - Not confident (5)", a: "\(questionnaireData["q6_confidence_leaving_home"] ?? "0")")
                                    Divider().background(Color.btBorder).padding(.horizontal, Spacing.md)
                                    ReportSymptomRow(q: "Q7. Sleep soundly (0) - Do not sleep soundly (5)", a: "\(questionnaireData["q7_sleep_quality"] ?? "0")")
                                    Divider().background(Color.btBorder).padding(.horizontal, Spacing.md)
                                    ReportSymptomRow(q: "Q8. Lots of energy (0) - No energy (5)", a: "\(questionnaireData["q8_energy_level"] ?? "0")")
                                    
                                    // Average Score Row
                                    // Average Score Row
                                    let avgScore = Double("\(questionnaireData["average_score"] ?? "0")") ?? 0.0
                                    let cat = getScoreCategory(avgScore)
                                    HStack {
                                        Text("Average Score")
                                            .font(.btHeadline)
                                            .foregroundColor(.btTextPrimary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Text(String(format: "%.2f (%@)", avgScore, cat))
                                            .font(.btHeadline)
                                            .foregroundColor(.btDoctorPrimary)
                                            .frame(width: 180, alignment: .trailing)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(Color.btDoctorPrimary.opacity(0.05))
                                }
                                .padding(.vertical, 0)
                                .background(Color.btSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 22))
                                .btCardShadow()
                                .padding(.horizontal, Spacing.lg)
                            }
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 20)
                            .animation(.spring().delay(0.5), value: appeared)

                            Spacer(minLength: 60)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            fetchDetails()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }

    private func fetchDetails() {
        guard let url = APIConfig.getURL(for: "fetch_patient_details.php") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["patient_id": patientId])
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let status = json["status"] as? String, status == "success" else { return }
            
            DispatchQueue.main.async {
                self.patientData = json["patient"] as? [String: Any] ?? [:]
                self.checkupData = json["checkup"] as? [String: Any] ?? [:]
                self.questionnaireData = json["questionnaire"] as? [String: Any] ?? [:]
                self.isLoading = false
            }
        }.resume()
    }
    
    private func getScoreCategory(_ s: Double) -> String {
        if s == 0 { return "N/A" }
        if s <= 1.0 { return "Mild" }
        if s <= 2.5 { return "Moderate" }
        return "Severe"
    }

    private func catColor(_ cat: String) -> Color {
        switch cat {
        case "Mild": return .btAccentGreen
        case "Moderate": return .btAccentOrange
        case "Severe": return .btAccent
        default: return .btTextTertiary
        }
    }
    
    private func reportDetail(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.btCaption)
                .foregroundColor(.btTextSecond)
            Text(value)
                .font(.btHeadline)
                .foregroundColor(.btTextPrimary)
        }
    }
}

// MARK: - Subviews

private struct ReportVitalBadge: View {
    let icon: String; let title: String; let value: String; let color: Color; let delay: Double
    @State private var showed = false
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle().fill(color.opacity(0.12)).frame(width: 44, height: 44)
                Image(systemName: icon).font(.system(size: 18)).foregroundColor(color)
            }
            Text(value).font(.btLabel).foregroundColor(.btTextPrimary)
            Text(title).font(.btCaption2).foregroundColor(.btTextSecond)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.md)
        .background(Color.btSurface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .btCardShadow()
        .opacity(showed ? 1 : 0).scaleEffect(showed ? 1 : 0.8)
        .onAppear { withAnimation(.spring().delay(delay)) { showed = true } }
    }
}

private struct ReportVaccineRow: View {
    let title: String; let date: String?
    var body: some View {
        HStack {
            Text(title).font(.btBodyMedium).foregroundColor(.btTextPrimary)
            Spacer()
            let d = (date == nil || date == "N/A" || date == "NA") ? "Not Taken" : date!
            Text(d).font(.btLabel).foregroundColor(d == "Not Taken" ? .btTextTertiary : .btAccentGreen)
        }
        .padding(.vertical, 4).padding(.horizontal, 4)
    }
}

private struct ReportSymptomRow: View {
    let q: String; let a: String
    var body: some View {
        HStack(alignment: .top) {
            Text(q)
                .font(.btBody)
                .foregroundColor(.btTextSecond)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
            
            Text(ansLabel(a))
                .font(.btBodyMedium)
                .foregroundColor(.btTextPrimary)
                .frame(width: 140, alignment: .trailing)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
    
    private func ansLabel(_ val: String) -> String {
        guard let i = Int(val) else { return val }
        let label: String
        switch i {
        case 0: label = "No symptom"
        case 1: label = "Very mild"
        case 2: label = "Mild"
        case 3: label = "Moderate"
        case 4: label = "Severe"
        case 5: label = "Very severe"
        default: label = "Score: \(val)"
        }
        return "\(i) - \(label)"
    }
}

#Preview {
    PatientReports(patientId: "dummy_123")
}
