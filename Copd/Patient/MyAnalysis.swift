import SwiftUI

struct AnalysisData {
    var name: String
    var ageYears: Int
    var gender: String
    var height: String 
    var weight: String 
    var occupation: String
    var diagnosis: String
    var score: String // e.g., "2.38 (Moderate)"

    // Vitals
    var temperature: String
    var spo2: String
    var lungFunction: String

    // Vaccination
    var pneumococcal: String
    var flu: String
    var pertussis: String
    var shinglesDose1: String
    var shinglesDose2: String

    // Questionnaire rows
    var questionnaire: [(question: String, answer: String)]
}

struct MyAnalysisView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var session: PatientSession

    @State private var analysisData: AnalysisData? = nil
    @State private var isLoading = true
    @State private var appeared = false

    // Pass score if coming from My COPD Review
    var score: Double? = nil

    var body: some View {
        ZStack {
            Color.btBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    BTBackButton(action: { dismiss() })
                    Spacer()
                    Text("My Analysis")
                        .font(.btHeadline)
                        .foregroundColor(.btTextPrimary)
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.sm)
                .background(Color.btBackground)

                if isLoading {
                    Spacer()
                    VStack(spacing: Spacing.md) {
                        ProgressView().tint(.btPrimary).scaleEffect(1.5)
                        Text("Analyzing your records...")
                            .font(.btBodyMedium)
                            .foregroundColor(.btTextSecond)
                    }
                    Spacer()
                } else if let data = analysisData {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: Spacing.xl) {
                            
                            // Analysis Summary Card (Large)
                            AnalysisSummaryCard(data: data)
                                .padding(.horizontal, Spacing.lg)
                                .padding(.top, Spacing.sm)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 20)

                            // Vitals Section
                            VStack(alignment: .leading, spacing: Spacing.md) {
                                BTSectionHeader(title: "Vital Signs")
                                    .padding(.horizontal, Spacing.lg)
                                
                                HStack(spacing: Spacing.md) {
                                    vitalCardWrapper(icon: "thermometer", title: "Temp", value: data.temperature, suffix: "°F", color: .btAccentOrange, delay: 0.1)
                                    vitalCardWrapper(icon: "lungs.fill", title: "SpO₂", value: data.spo2, suffix: "%", color: .btPrimary, delay: 0.2)
                                    vitalCardWrapper(icon: "wind", title: "Lung", value: data.lungFunction, suffix: "%", color: .btAccentPurple, delay: 0.3)
                                }
                                .padding(.horizontal, Spacing.lg)
                            }
                            .opacity(appeared ? 1 : 0)

                            // Vaccination Section
                            VStack(alignment: .leading, spacing: Spacing.md) {
                                BTSectionHeader(title: "Vaccination Details")
                                    .padding(.horizontal, Spacing.lg)
                                
                                VStack(spacing: Spacing.sm) {
                                    VaccineMiniRow(title: "Pneumococcal", date: data.pneumococcal)
                                    VaccineMiniRow(title: "Flu Vaccine", date: data.flu)
                                    VaccineMiniRow(title: "Pertussis", date: data.pertussis)
                                    VaccineMiniRow(title: "Shingles - Dose 1", date: data.shinglesDose1)
                                    VaccineMiniRow(title: "Shingles - Dose 2", date: data.shinglesDose2)
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

                            // Questionnaire Section
                            VStack(alignment: .leading, spacing: Spacing.md) {
                                BTSectionHeader(title: "Questionnaire Answers")
                                    .padding(.horizontal, Spacing.lg)
                                
                                VStack(spacing: 0) {
                                    // Table Headers
                                    HStack {
                                        Text("Question")
                                            .font(.btLabel)
                                            .foregroundColor(.btTextPrimary)
                                        Spacer()
                                        Text("Answer")
                                            .font(.btLabel)
                                            .foregroundColor(.btTextPrimary)
                                            .frame(width: 135, alignment: .leading)
                                    }
                                    .padding(.vertical, 8)
                                    
                                    Divider().background(Color.btBorder)
                                    
                                    ForEach(data.questionnaire.indices, id: \.self) { idx in
                                        QuestionSummaryRow(
                                            question: data.questionnaire[idx].question,
                                            answer: data.questionnaire[idx].answer,
                                            isLast: idx == data.questionnaire.count - 1
                                        )
                                    }
                                }
                                .padding(Spacing.md)
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
                } else {
                    Spacer()
                    VStack(spacing: Spacing.md) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.btTextTertiary)
                        Text("No analysis data found.")
                            .font(.btHeadline)
                            .foregroundColor(.btTextSecond)
                        BTPrimaryButton(title: "Try Again", action: fetchAnalysis)
                            .frame(width: 160)
                    }
                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            fetchAnalysis()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }

    private func fetchAnalysis() {
        guard let patientId = session.current?.patient_id else { isLoading = false; return }
        guard let url = APIConfig.getURL(for: "get_patient_details.php") else { isLoading = false; return }

        let body: [String: Any] = ["patient_id": patientId]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let status = json["status"] as? String, status == "success" else {
                DispatchQueue.main.async { self.isLoading = false }
                return
            }

            DispatchQueue.main.async {
                let patient = json["patient"] as? [String: Any] ?? [:]
                let checkup = json["checkup"] as? [String: Any] ?? [:]
                let questionnaire = json["questionnaire"] as? [String: Any] ?? [:]
                
                let scoreValue = questionnaire["average_score"]
                let score = (scoreValue as? Double) ?? (Double(String(describing: scoreValue ?? "0.0"))) ?? 0.0
                let scoreLabel = MyAnalysisView.getScoreCategory(score)
                
                self.analysisData = AnalysisData(
                    name: patient["name"] as? String ?? "Patient",
                    ageYears: Int("\(patient["age"] ?? "0")") ?? 0,
                    gender: patient["gender"] as? String ?? "N/A",
                    height: "\(patient["height"] ?? "—")",
                    weight: "\(patient["weight"] ?? "—")",
                    occupation: patient["occupation"] as? String ?? "—",
                    diagnosis: patient["diagnosis"] as? String ?? "Chronic Respiratory Condition",
                    score: String(format: "%.2f (%@)", score, scoreLabel),
                    temperature: "\(checkup["temperature"] ?? "")",
                    spo2: "\(checkup["oxygen_level"] ?? "")",
                    lungFunction: "\(checkup["lung_function"] ?? "")",
                    pneumococcal: questionnaire["date_pneumococcal"] as? String ?? (questionnaire["pneumococcal"] as? String ?? "N/A"),
                    flu: questionnaire["date_flu"] as? String ?? (questionnaire["flu"] as? String ?? "N/A"),
                    pertussis: questionnaire["date_pertussis"] as? String ?? (questionnaire["pertussis"] as? String ?? "N/A"),
                    shinglesDose1: questionnaire["date_shingles1"] as? String ?? (questionnaire["shingles1"] as? String ?? "N/A"),
                    shinglesDose2: questionnaire["date_shingles2"] as? String ?? (questionnaire["shingles2"] as? String ?? "N/A"),
                    questionnaire: [
                        ("Q1. Cough", "\(questionnaire["q1_cough"] ?? questionnaire["cough"] ?? "")"),
                        ("Q2. Phlegm", "\(questionnaire["q2_phlegm"] ?? questionnaire["phlegm"] ?? "")"),
                        ("Q3. Chest tightness", "\(questionnaire["q3_chest_tightness"] ?? questionnaire["chest_tightness"] ?? "")"),
                        ("Q4. Energy level", "\(questionnaire["q4_breathlessness"] ?? questionnaire["breathlessness"] ?? "")"),
                        ("Q5. Sleep quality", "\(questionnaire["q5_activity_limitation"] ?? questionnaire["activity_limitation"] ?? "")"),
                        ("Q6. Confidence leaving home", "\(questionnaire["q6_confidence_leaving_home"] ?? questionnaire["confidence_leaving_home"] ?? "")"),
                        ("Q7. Outdoor activities", "\(questionnaire["q7_sleep_quality"] ?? questionnaire["sleep_quality"] ?? "")"),
                        ("Q8. Climbing stairs", "\(questionnaire["q8_energy_level"] ?? questionnaire["energy_level"] ?? "")")
                    ]
                )
                self.isLoading = false
            }
        }.resume()
    }

    private func vitalCardWrapper(icon: String, title: String, value: String, suffix: String, color: Color, delay: Double) -> some View {
        let cleanValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let displayValue: String
        if cleanValue.isEmpty || cleanValue == "—" {
            displayValue = "N/A"
        } else if let d = Double(cleanValue) {
            displayValue = String(format: "%.2f%@", d, suffix)
        } else {
            displayValue = cleanValue + suffix
        }
        
        return AnalysisVitalCard(icon: icon, title: title, value: displayValue, color: color, delay: delay)
    }

    private static func getScoreCategory(_ score: Double) -> String {
        if score < 1.0 { return "Low" }
        if score < 3.0 { return "Moderate" }
        return "High"
    }
}

// MARK: - Subviews

private struct AnalysisSummaryCard: View {
    let data: AnalysisData

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(data.name)
                        .font(.btTitle2)
                        .foregroundColor(.btTextPrimary)
                    Text("\(data.ageYears) yrs • \(data.gender)")
                        .font(.btBodyMedium)
                        .foregroundColor(.btTextSecond)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(data.score.components(separatedBy: " ").first ?? "—")
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundColor(.btPrimary)
                    
                    let cat = data.score.contains("Moderate") ? "Moderate" : (data.score.contains("Low") ? "Low" : "High")
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
                detailBlock(label: "Height", value: "\(data.height) cm")
                detailBlock(label: "Weight", value: "\(data.weight) kg")
                detailBlock(label: "Occupation", value: data.occupation)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Primary Diagnosis")
                    .font(.btCaption2)
                    .foregroundColor(.btTextSecond)
                Text(data.diagnosis)
                    .font(.btHeadline)
                    .foregroundColor(.btTextPrimary)
            }
        }
        .padding(Spacing.lg)
        .background(Color.btSurface)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .btCardShadow()
    }
    
    private func detailBlock(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.btCaption2)
                .foregroundColor(.btTextSecond)
            Text(value)
                .font(.btLabel)
                .foregroundColor(.btTextPrimary)
        }
    }
    
    private func catColor(_ cat: String) -> Color {
        switch cat {
        case "Low": return .btAccentGreen
        case "Moderate": return .btAccentOrange
        default: return .btAccent
        }
    }
}

private struct AnalysisVitalCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let delay: Double
    @State private var showed = false

    var body: some View {
        VStack(spacing: Spacing.sm) {
            ZStack {
                Circle().fill(color.opacity(0.12)).frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            VStack(spacing: 2) {
                Text(value)
                    .font(.btHeadline)
                    .foregroundColor(.btTextPrimary)
                Text(title)
                    .font(.btCaption2)
                    .foregroundColor(.btTextSecond)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.md)
        .background(Color.btSurface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .btCardShadow()
        .opacity(showed ? 1 : 0)
        .scaleEffect(showed ? 1 : 0.8)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(delay)) {
                showed = true
            }
        }
    }
}

private struct VaccineMiniRow: View {
    let title: String
    let date: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.btBodyMedium)
                .foregroundColor(.btTextPrimary)
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: date == "N/A" ? "xmark.circle.fill" : "checkmark.circle.fill")
                    .font(.caption2)
                Text(date)
                    .font(.btLabel)
            }
            .foregroundColor(date == "N/A" ? .btTextTertiary : .btAccentGreen)
        }
        .padding(.vertical, 4)
    }
}

private struct QuestionSummaryRow: View {
    let question: String
    let answer: String
    let isLast: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                Text(question)
                    .font(.btBodyMedium)
                    .foregroundColor(.btTextSecond)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer(minLength: 24)
                
                Text(answerLabel(answer))
                    .font(.btLabel)
                    .foregroundColor(.btTextPrimary)
                    .frame(width: 135, alignment: .leading)
            }
            .padding(.vertical, 12)
            
            if !isLast {
                Divider().background(Color.btBorder)
            }
        }
    }
    
    private func answerLabel(_ val: String) -> String {
        guard let i = Int(val) else { return val }
        switch i {
        case 0: return "0 - No symptom"
        case 1: return "1 - Very mild"
        case 2: return "2 - Mild"
        case 3: return "3 - Moderate"
        case 4: return "4 - Severe"
        case 5: return "5 - Very severe"
        default: return "\(i)"
        }
    }
}

#Preview {
    NavigationStack {
        MyAnalysisView()
            .environmentObject(PatientSession())
    }
}
