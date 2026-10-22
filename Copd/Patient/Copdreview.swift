import SwiftUI

// Optional model you can fill from Sign Up and Questionnaires later
struct CopdReview {
    var name: String?
    var ageYears: Int?
    var gender: String?
    var heightCm: Double?
    var weightKg: Double?
    var diagnosis: String?
    var occupation: String?
    var analysisScore: Double?
}

struct CopdReviewView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var session: PatientSession

    @State private var reviewData: CopdReview? = nil
    @State private var isLoading = true
    @State private var contentVisible = false

    private let columns = [GridItem(.flexible(), spacing: Spacing.md),
                           GridItem(.flexible(), spacing: Spacing.md)]

    var body: some View {
        ZStack {
            // Background
            Color.btBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ── Header bar ──────────────────────────────────────────
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.btTextPrimary)
                            .frame(width: 44, height: 44)
                            .background(Color.btSurface)
                            .clipShape(Circle())
                            .btCardShadow()
                    }
                    
                    Spacer()
                    
                    Text("My COPD Review")
                        .font(.btHeadline)
                        .foregroundColor(.btTextPrimary)
                    
                    Spacer()
                    
                    // Balanced spacer
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.md)
                .background(Color.btBackground)
                
                if isLoading {
                    Spacer()
                    VStack(spacing: Spacing.lg) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(Color.btPrimary)
                        Text("Summarizing your health...")
                            .font(.btBodyMedium)
                            .foregroundColor(.btTextSecond)
                    }
                    Spacer()
                } else if let review = reviewData {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: Spacing.xl) {
                            
                            // ── Minimalist Profile Header ────────────────────
                            HStack(spacing: Spacing.md) {
                                ZStack {
                                    Circle()
                                        .fill(LinearGradient.btPrimaryGradient)
                                        .frame(width: 60, height: 60)
                                        .btDeepShadow(color: Color.btPrimary.opacity(0.5))
                                    Image(systemName: "heart.text.square.fill")
                                        .font(.system(size: 26))
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Health Profile Summary")
                                        .font(.btTitle2)
                                        .foregroundColor(.btTextPrimary)
                                    Text("Personal data & metrics")
                                        .font(.btCaption)
                                        .foregroundColor(.btTextSecond)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, Spacing.lg)
                            .padding(.top, Spacing.md)
                            .opacity(contentVisible ? 1 : 0)
                            .offset(y: contentVisible ? 0 : 20)

                            // ── Comprehensive Details Grid ───────────────────
                            LazyVGrid(columns: columns, spacing: Spacing.md) {
                                ModernTile(icon: "person.fill", title: "Name", value: review.name ?? "—", color: .btPrimary, delay: 0.1)
                                ModernTile(icon: "calendar", title: "Age", value: review.ageYears.map { "\($0) yrs" } ?? "—", color: .btAccentOrange, delay: 0.15)
                                ModernTile(icon: "figure.stand", title: "Gender", value: review.gender ?? "—", color: .btAccentPurple, delay: 0.2)
                                ModernTile(icon: "ruler.fill", title: "Height", value: review.heightCm.map { String(format: "%.0f cm", $0) } ?? "—", color: .btAccentGreen, delay: 0.25)
                                ModernTile(icon: "scalemass.fill", title: "Weight", value: review.weightKg.map { String(format: "%.0f kg", $0) } ?? "—", color: .btAccent, delay: 0.3)
                                ModernTile(icon: "stethoscope", title: "Diagnosis", value: review.diagnosis ?? "—", color: Color(hex: "5A67D8"), delay: 0.35)
                                ModernTile(icon: "briefcase.fill", title: "Occupation", value: review.occupation ?? "—", color: Color(hex: "D69E2E"), delay: 0.4)

                                NavigationLink {
                                    MyAnalysisView()
                                        .navigationBarBackButtonHidden(true)
                                } label: {
                                    ModernTile(icon: "chart.bar.fill", 
                                               title: "My Analysis", 
                                               value: review.analysisScore.map { String(format: "%.2f", $0) } ?? "—", 
                                               color: Color(hex: "E53E3E"),
                                               isInteractive: true,
                                               delay: 0.45)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, Spacing.lg)

                            Spacer(minLength: 120)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .onAppear {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            contentVisible = true
                        }
                    }
                }
                else {
                    Spacer()
                    VStack(spacing: Spacing.md) {
                        Image(systemName: "exclamationmark.square.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.btAccentOrange)
                        Text("Unable to load summaries")
                            .font(.btHeadline)
                            .foregroundColor(.btTextPrimary)
                        
                        BTPrimaryButton(title: "Retry", action: fetchReview)
                            .frame(width: 160)
                            .padding(.top, Spacing.sm)
                    }
                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            fetchReview()
        }
    }

    private func fetchReview() {
        isLoading = true
        guard let patientId = session.current?.patient_id else {
            isLoading = false
            return
        }

        guard let url = APIConfig.getURL(for: "get_patient_details.php") else {
            isLoading = false
            return
        }

        let body: [String: Any] = ["patient_id": patientId]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let status = json["status"] as? String, status == "success",
                           let patient = json["patient"] as? [String: Any] {
                            
                            let q = json["questionnaire"] as? [String: Any]
                            let score = q?["average_score"] as? Double ?? (q?["average_score"] as? String).flatMap(Double.init)

                            self.reviewData = CopdReview(
                                name: patient["name"] as? String,
                                ageYears: Int("\(patient["age"] ?? "0")"),
                                gender: patient["gender"] as? String,
                                heightCm: Double("\(patient["height"] ?? "0")"),
                                weightKg: Double("\(patient["weight"] ?? "0")"),
                                diagnosis: patient["diagnosis"] as? String,
                                occupation: patient["occupation"] as? String,
                                analysisScore: score
                            )
                        }
                    } catch {
                        print("JSON conversion error: \(error.localizedDescription)")
                    }
                }
            }
        }.resume()
    }
}

private struct ModernTile: View {
    var icon: String
    var title: String
    var value: String
    var color: Color
    var isInteractive: Bool = false
    var delay: Double = 0.0

    @State private var appeared = false
    @State private var pressed = false

    var body: some View {
        VStack(spacing: Spacing.sm) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }
            .padding(.top, Spacing.xs)

            VStack(spacing: 4) {
                Text(title)
                    .font(.btCaption2)
                    .foregroundColor(.btTextSecond)
                
                Text(value)
                    .font(.btHeadline)
                    .foregroundColor(.btTextPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            
            if isInteractive {
                HStack(spacing: 4) {
                    Text("View Detail")
                        .font(.system(size: 11, weight: .bold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundColor(color)
                .padding(.top, 6)
                .padding(.bottom, 2)
            } else {
                Spacer().frame(height: 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.md)
        .padding(.horizontal, Spacing.sm)
        .background(Color.btSurface)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .btCardShadow()
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(isInteractive ? color.opacity(0.3) : Color.clear, lineWidth: 1.5)
        )
        // Animations
        .scaleEffect(pressed ? 0.95 : (appeared ? 1.0 : 0.8))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75).delay(delay)) {
                appeared = true
            }
        }
    }
    }


// Simple destination for "My Analysis" (kept in case you still want a lightweight view elsewhere)
struct SimpleAnalysisView: View {
    @Environment(\.dismiss) private var dismiss
    var score: Double?

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                }
                Text("My Analysis")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.black)
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))

            Spacer()

            Text("Analysis Score")
                .font(.title2.weight(.semibold))
            Text(score.map { String(format: "%.2f", $0) } ?? "—")
                .font(.system(size: 48, weight: .bold))
                .padding(.top, 4)

            Spacer()
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        CopdReviewView()
            .navigationBarHidden(true)
    }
}
