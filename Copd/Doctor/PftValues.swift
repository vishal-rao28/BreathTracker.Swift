import SwiftUI
import PhotosUI
import UIKit

struct PftValuesView: View {
    @Environment(\.dismiss) private var dismiss
    var patientId: String = "dummy_pat_123"

    @State private var selectedImage: UIImage? = nil
    @State private var showPhotoPicker = false
    @State private var normal: Choice? = nil
    @State private var mild: Choice? = nil
    @State private var moderate: Choice? = nil
    @State private var severe: Choice? = nil
    @State private var comments: String = ""
    @State private var isSubmitting = false
    @State private var appeared = false
    @State private var showSuccessAlert = false

    enum Choice: String { case yes, no }

    var body: some View {
        ZStack {
            Color.btBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    BTBackButton(action: { dismiss() })
                    Spacer()
                    Text("PFT Report Entry")
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
                        
                        // Picture Upload Card
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            BTSectionHeader(title: "PFT Lab Results")
                            
                            Button { showPhotoPicker = true } label: {
                                ZStack {
                                    if let img = selectedImage {
                                        Image(uiImage: img)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(maxWidth: .infinity, maxHeight: 180)
                                            .clipShape(RoundedRectangle(cornerRadius: 22))
                                            .btCardShadow()
                                    } else {
                                        VStack(spacing: 12) {
                                            ZStack {
                                                Circle().fill(Color.btDoctorPrimary.opacity(0.1)).frame(width: 56, height: 56)
                                                Image(systemName: "camera.viewfinder")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(.btDoctorPrimary)
                                            }
                                            Text("Upload Report Image")
                                                .font(.btLabel)
                                                .foregroundColor(.btDoctorPrimary)
                                            Text("Document capture or upload")
                                                .font(.btCaption2)
                                                .foregroundColor(.btTextSecond)
                                        }
                                        .frame(maxWidth: .infinity, minHeight: 160)
                                        .background(Color.btSurface)
                                        .clipShape(RoundedRectangle(cornerRadius: 22))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 22)
                                                .strokeBorder(Color.btDoctorPrimary.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [6]))
                                        )
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.sm)
                        .opacity(appeared ? 1 : 0)

                        // Severity Card
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            BTSectionHeader(title: "Clinical Severity Assessment")
                            
                            VStack(spacing: 0) {
                                SeverityChoiceRow(title: "Normal", icon: "checkmark.circle", selection: $normal, activeColor: .btAccentGreen) { updateSelection(to: .normal) }
                                Divider().background(Color.btBorder).padding(.horizontal, Spacing.md)
                                SeverityChoiceRow(title: "Mild", icon: "exclamationmark.circle", selection: $mild, activeColor: .btAccentPurple) { updateSelection(to: .mild) }
                                Divider().background(Color.btBorder).padding(.horizontal, Spacing.md)
                                SeverityChoiceRow(title: "Moderate", icon: "exclamationmark.triangle", selection: $moderate, activeColor: .btAccentOrange) { updateSelection(to: .moderate) }
                                Divider().background(Color.btBorder).padding(.horizontal, Spacing.md)
                                SeverityChoiceRow(title: "Severe", icon: "xmark.octagon", selection: $severe, activeColor: .btAccent) { updateSelection(to: .severe) }
                            }
                            .background(Color.btSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                            .btCardShadow()
                        }
                        .padding(.horizontal, Spacing.lg)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                        .animation(.spring().delay(0.1), value: appeared)

                        // Comments Card
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            BTSectionHeader(title: "Additional Notes")

                            TextEditor(text: $comments)
                                .font(.btBodyMedium)
                                .padding(Spacing.md)
                                .frame(minHeight: 120)
                                .background(Color.btSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                .btCardShadow()
                                .overlay(
                                    Group {
                                        if comments.isEmpty {
                                            Text("Enter details regarding PFT findings...")
                                                .font(.btBodyMedium)
                                                .foregroundColor(.btTextTertiary)
                                                .padding(.leading, Spacing.md + 4)
                                                .padding(.top, Spacing.md + 8)
                                        }
                                    }, alignment: .topLeading
                                )
                        }
                        .padding(.horizontal, Spacing.lg)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                        .animation(.spring().delay(0.2), value: appeared)

                        // Submit Button
                        BTPrimaryButton(
                            title: "Submit PFT Report",
                            icon: "checkmark.circle.fill",
                            gradient: LinearGradient.btDoctorGradient,
                            shadowColor: .btDoctorPrimary,
                            isLoading: isSubmitting
                        ) {
                            if isFormValid {
                                handleSubmit()
                            }
                        }
                        .disabled(!isFormValid)
                        .opacity(!isFormValid ? 0.6 : 1.0)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.md)
                        .padding(.bottom, 60)
                        .opacity(appeared ? 1 : 0)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showPhotoPicker) {
            BTPhotoPicker(image: $selectedImage)
        }
        .alert("Success", isPresented: $showSuccessAlert) {
            Button("OK") { dismiss() }
        } message: {
            Text("PFT Report Submitted Successfully!")
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }

    private var isFormValid: Bool {
        normal == .yes || mild == .yes || moderate == .yes || severe == .yes
    }
    
    private enum SeverityType { case normal, mild, moderate, severe }
    
    private func updateSelection(to type: SeverityType) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            normal = (type == .normal ? .yes : .no)
            mild = (type == .mild ? .yes : .no)
            moderate = (type == .moderate ? .yes : .no)
            severe = (type == .severe ? .yes : .no)
        }
    }

    private func handleSubmit() {
        guard let url = APIConfig.getURL(for: "submit_pft.php") else { return }
        withAnimation { isSubmitting = true }
        
        var base64Image = ""
        if let img = selectedImage, let data = img.jpegData(compressionQuality: 0.5) {
            base64Image = data.base64EncodedString()
        }
        
        let payload: [String: Any] = [
            "patient_id": patientId,
            "normal": normal == .yes ? "Yes" : "No",
            "mild": mild == .yes ? "Yes" : "No",
            "moderate": moderate == .yes ? "Yes" : "No",
            "severe": severe == .yes ? "Yes" : "No",
            "comments": comments,
            "image": base64Image
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                withAnimation { isSubmitting = false }
                showSuccessAlert = true
            }
        }.resume()
    }
}

// MARK: - Severity Choice Row

private struct SeverityChoiceRow: View {
    let title: String
    let icon: String
    @Binding var selection: PftValuesView.Choice?
    let activeColor: Color
    let onYes: () -> Void

    var body: some View {
        HStack(spacing: Spacing.md) {
            Label {
                Text(title)
                    .font(.btHeadline)
                    .foregroundColor(.btTextPrimary)
            } icon: {
                Image(systemName: icon)
                    .foregroundColor(activeColor)
            }
            
            Spacer()

            HStack(spacing: Spacing.sm) {
                ChoiceChip(label: "Yes", isSelected: selection == .yes, color: activeColor, action: onYes)
                
                ChoiceChip(label: "No", isSelected: selection == .no, color: .btTextTertiary) {
                    selection = (selection == .no ? nil : .no)
                }
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.md)
    }
}

private struct ChoiceChip: View {
    let label: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    @State private var pressed = false

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.btLabel)
                .foregroundColor(isSelected ? .white : .btTextSecond)
                .frame(width: 60, height: 38)
                .background(isSelected ? color : Color.btBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .btCardShadow(color: isSelected ? color : Color.clear)
                .scaleEffect(pressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(DragGesture(minimumDistance: 0)
            .onChanged { _ in withAnimation(.easeInOut(duration: 0.1)) { pressed = true } }
            .onEnded { _ in withAnimation(.spring()) { pressed = false } }
        )
    }
}

#Preview {
    NavigationStack {
        PftValuesView()
    }
}
