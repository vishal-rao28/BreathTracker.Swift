import SwiftUI
import PhotosUI
import UIKit

struct ABGReportView: View {
    @Environment(\.dismiss) private var dismiss
    var patientId: String = "dummy_pat_123"

    @State private var selectedImage: UIImage? = nil
    @State private var showPhotoPicker = false
    @State private var selectedSeverity: String = "Normal"
    @State private var comments: String = ""
    @State private var appeared = false
    @State private var isSubmitting = false
    @State private var showSuccessAlert = false

    var body: some View {
        ZStack {
            Color.btBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    BTBackButton(action: { dismiss() })
                    Spacer()
                    Text("ABG Report Entry")
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
                            BTSectionHeader(title: "Medical Report Document")
                            
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
                                                Image(systemName: "doc.viewfinder.fill")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(.btDoctorPrimary)
                                            }
                                            Text("Upload Report Image")
                                                .font(.btLabel)
                                                .foregroundColor(.btDoctorPrimary)
                                            Text("Capture or select from gallery")
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

                        // ABG Severity Section
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            BTSectionHeader(title: "ABG Severity Level")
                            
                            HStack(spacing: 8) {
                                ForEach(["Normal", "Mild", "Moderate", "Severe"], id: \.self) { level in
                                    Button(action: { selectedSeverity = level }) {
                                        Text(level)
                                            .font(.btBodyMedium)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(selectedSeverity == level ? Color.btDoctorPrimary : Color.btSurface)
                                            .foregroundColor(selectedSeverity == level ? .white : .btTextPrimary)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .strokeBorder(selectedSeverity == level ? Color.clear : Color.btDoctorPrimary.opacity(0.3), lineWidth: 1)
                                            )
                                            .animation(.easeInOut, value: selectedSeverity)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                        .animation(.spring().delay(0.1), value: appeared)



                        // Comments Card
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            BTSectionHeader(title: "Physician Remarks")

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
                                            Text("Enter additional clinical observations...")
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
                        .animation(.spring().delay(0.3), value: appeared)

                        // Submit Button
                        BTPrimaryButton(
                            title: "Submit ABG Report",
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
            Text("ABG Report Submitted Successfully!")
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }

    private var isFormValid: Bool {
        true // Severity always has a default, so we can always submit. (Or add image/comment requirement if you prefer).
    }

    private func handleSubmit() {
        guard let url = APIConfig.getURL(for: "submit_abg.php") else { return }
        withAnimation { isSubmitting = true }
        
        var base64Image = ""
        if let img = selectedImage, let data = img.jpegData(compressionQuality: 0.5) {
            base64Image = data.base64EncodedString()
        }
        
        let payload: [String: Any] = [
            "patient_id": patientId,
            "image": base64Image,
            "comments": comments,
            "normal": selectedSeverity == "Normal" ? "Yes" : "No",
            "mild": selectedSeverity == "Mild" ? "Yes" : "No",
            "moderate": selectedSeverity == "Moderate" ? "Yes" : "No",
            "severe": selectedSeverity == "Severe" ? "Yes" : "No"
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

// MARK: - Photo Picker (Unified)
struct BTPhotoPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images; config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ ui: PHPickerViewController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        private let p: BTPhotoPicker
        init(_ p: BTPhotoPicker) { self.p = p }
        func picker(_ picker: PHPickerViewController, didFinishPicking res: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let prov = res.first?.itemProvider, prov.canLoadObject(ofClass: UIImage.self) else { return }
            prov.loadObject(ofClass: UIImage.self) { obj, _ in
                DispatchQueue.main.async { self.p.image = obj as? UIImage }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ABGReportView()
    }
}
