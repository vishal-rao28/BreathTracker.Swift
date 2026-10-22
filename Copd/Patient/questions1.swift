import SwiftUI

struct COPDQuestion: Identifiable, Hashable {
    let id = UUID()
    let index: Int
    let titleEN: String
    let titleTA: String
    let footerEN: String
    let footerTA: String
    var answer: Int? = nil // 0...5
}

struct QuestionsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var session: PatientSession
    @Binding var isPresented: Bool
    
    @State private var questions: [COPDQuestion] = [
        COPDQuestion(index: 1, titleEN: "I never Cough", titleTA: "எனக்கு ஒரு போதும் இருமல் வராது", footerEN: "I Cough all times", footerTA: "எனக்கு எப்போதும் இருமல் வருகிறது"),
        COPDQuestion(index: 2, titleEN: "I have no phlegm (mucus) in my chest at all", titleTA: "எனக்கு மார்பில் சளி எதுவும் இல்லை", footerEN: "My Chest is completely full of phlegm (mucus)", footerTA: "என் மார்பு முழுவதும் சளியால் நிரம்புள்ளது"),
        COPDQuestion(index: 3, titleEN: "My Chest does not feel tight at all", titleTA: "என் மார்பு ஒருபோதும் இறுக்கமாக உணரவில்லை", footerEN: "My Chest feels very tight", footerTA: "என் மார்பு மிகவும் இறுக்கமாக உணரப்படுகிறது"),
        COPDQuestion(index: 4, titleEN: "I have lots of energy", titleTA: "எனக்கு மிகவும் அதிக சக்தி உள்ளது", footerEN: "I have no energy at all", footerTA: "எனக்கு ஒருபோதும் சக்தி இல்லை"),
        COPDQuestion(index: 5, titleEN: "I sleep soundly", titleTA: "நான் நிம்மதியாக தூங்குகிறேன்", footerEN: "I do not sleep well at all", footerTA: "நான் ஒருபோதும் நிம்மதியாக தூங்கவில்லை"),
        COPDQuestion(index: 6, titleEN: "I am confident leaving my home despite my lung condition", titleTA: "என் நுரையீரல் நிலைமை இருந்தாலும், நான் வீட்டை விட்டு வெளியே செல்ல நம்பிக்கையுடன் இருக்கிறேன்", footerEN: "I am not at all confident leaving my home because of my lung condition", footerTA: "என் நுரையீரல் நிலைமையால் வீட்டை விட்டு வெளியே செல்ல நான் ஒருபோதும் நம்பிக்கையுடன் இல்லை"),
        COPDQuestion(index: 7, titleEN: "I feel comfortable doing outdoor activities", titleTA: "எனக்கு வெளிப்புற செயல்பாடுகள் செய்ய வசதியாக உள்ளது", footerEN: "I am not at all comfortable doing outdoor activities", footerTA: "வெளிப்புற செயல்பாடுகள் எனக்கு வசதியாக இல்லை"),
        COPDQuestion(index: 8, titleEN: "I can climb stairs without difficulty", titleTA: "நான் படிக்கட்டுகளை சிரமமின்றி ஏற முடியும்", footerEN: "I cannot climb stairs at all", footerTA: "நான் படிக்கட்டுகளை ஏற முடியாது")
    ]
    
    @State private var navigateNext = false
    @State private var isSubmitting: Bool = false
    @State private var appeared = false
    @State private var showSuccessAlert = false
    
    var allAnswered: Bool {
        questions.allSatisfy { $0.answer != nil }
    }
    
    var progress: Double {
        let answered = Double(questions.filter { $0.answer != nil }.count)
        return answered / Double(questions.count)
    }
    
    var body: some View {
        ZStack {
            Color.btBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                QuestionnaireHeader(
                    title: "COPD Assessment",
                    progress: progress,
                    onBack: { dismiss() }
                )
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: Spacing.xl) {
                        
                        // Section Instruction
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Health Questionnaire")
                                .font(.btTitle)
                                .foregroundColor(.btTextPrimary)
                            
                            Text("This helps us understand how COPD is affecting your daily life. Please answer as honestly as possible.")
                                .font(.btBodyMedium)
                                .foregroundColor(.btTextSecond)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.lg)
                        .opacity(appeared ? 1 : 0)
                        
                        VStack(spacing: Spacing.lg) {
                            ForEach(questions.indices, id: \.self) { idx in
                                ModernQuestionCard(
                                    number: questions[idx].index,
                                    titleEN: questions[idx].titleEN,
                                    titleTA: questions[idx].titleTA,
                                    footerEN: questions[idx].footerEN,
                                    footerTA: questions[idx].footerTA,
                                    selected: questions[idx].answer,
                                    onSelect: { value in
                                        withAnimation(.spring()) {
                                            questions[idx].answer = value
                                        }
                                    }
                                )
                                .padding(.horizontal, Spacing.lg)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 20)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1 + Double(idx) * 0.05), value: appeared)
                            }
                        }
                        
                        // Submit Button
                        BTPrimaryButton(
                            title: "Submit Assessment",
                            icon: "checkmark.seal.fill",
                            isLoading: isSubmitting,
                            isDisabled: !allAnswered
                        ) {
                            handleSubmit()
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.md)
                        .padding(.bottom, 60)
                        .opacity(appeared ? 1 : 0)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                appeared = true
            }
        }
        .alert("Success", isPresented: $showSuccessAlert) {
            Button("OK") {
                isPresented = false
            }
        } message: {
            Text("Assessment submitted successfully!")
        }
    }
    
    private func handleSubmit() {
        guard let url = APIConfig.getURL(for: "submit_questionnaires.php") else { return }
        
        withAnimation { isSubmitting = true }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let allAnswers = questions.compactMap { $0.answer }
        
        let body: [String: Any] = [
            "patient_id": session.current?.patient_id ?? "guest",
            "date_pneumococcal": session.current?.date_pneumococcal ?? "N/A",
            "date_flu": session.current?.date_flu ?? "N/A",
            "date_pertussis": session.current?.date_pertussis ?? "N/A",
            "date_shingles1": session.current?.date_shingles1 ?? "N/A",
            "date_shingles2": session.current?.date_shingles2 ?? "N/A",
            "q1_cough": allAnswers.indices.contains(0) ? allAnswers[0] : 0,
            "q2_phlegm": allAnswers.indices.contains(1) ? allAnswers[1] : 0,
            "q3_chest_tightness": allAnswers.indices.contains(2) ? allAnswers[2] : 0,
            "q4_breathlessness": allAnswers.indices.contains(3) ? allAnswers[3] : 0,
            "q5_activity_limitation": allAnswers.indices.contains(4) ? allAnswers[4] : 0,
            "q6_confidence_leaving_home": allAnswers.indices.contains(5) ? allAnswers[5] : 0,
            "q7_sleep_quality": allAnswers.indices.contains(6) ? allAnswers[6] : 0,
            "q8_energy_level": allAnswers.indices.contains(7) ? allAnswers[7] : 0
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                withAnimation { isSubmitting = false }
                if let error = error { print("Error: \(error)") }
                showSuccessAlert = true
            }
        }.resume()
    }
}

#Preview {
    NavigationStack {
        QuestionsView(isPresented: .constant(true))
            .environmentObject(PatientSession())
    }
}
