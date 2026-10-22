import SwiftUI

struct Medication: View {
    
    struct Medicine: Identifiable {
        let id = UUID()
        let name: String
        var isSelected: Bool = false
    }
    
    @State private var medicines: [Medicine] = [
        Medicine(name: "MDI Glycohale FB (LABA + LAMA + ICS) - Formoterol fumarate 6 mcg, Glycopyrronium 12.5 mcg and budesonide 200 mcg"),
        Medicine(name: "MDI Budamate (LABA + ICS) - Formoterol fumarate 6 mcg and budesonide 200/400 mcg"),
        Medicine(name: "MDI Duolin (SABA + SAMA) - Levosalbutamol 50 mcg and ipratropium bromide 20 mcg"),
        Medicine(name: "MDI Trimium (LABA + LAMA + ICS) - Formoterol fumarate 6 mcg, tiotropium bromide 9 mcg and cyclosonide 200 mcg"),
        Medicine(name: "MDI Tiova (LAMA) - Tiotropium bromide 9 mcg"),
        Medicine(name: "MDI Forglyn (LABA + LAMA) - Formoterol fumarate 4.8 mcg and glycopyrrolate 9 mcg")
    ]
    
    @State private var remarks: String = ""
    @State private var isSubmitting = false
    @State private var appeared = false
    @State private var showSuccessAlert = false
    @Environment(\.dismiss) private var dismiss
    var patientId: String = ""
    
    var body: some View {
        ZStack {
            Color.btBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header bar
                HStack {
                    BTBackButton(action: { dismiss() })
                    Spacer()
                    Text("Medication Diary")
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
                        
                        // Intro
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Prescribe Medications")
                                .font(.btTitle2)
                                .foregroundColor(.btTextPrimary)
                            Text("Select the appropriate medications and add physician remarks for the patient.")
                                .font(.btCaption)
                                .foregroundColor(.btTextSecond)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.sm)
                        .opacity(appeared ? 1 : 0)

                        // Medicine List
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            BTSectionHeader(title: "Available Prescriptions")
                            
                            VStack(spacing: Spacing.md) {
                                ForEach(medicines.indices, id: \.self) { index in
                                    MedicineSelectionCard(medicine: $medicines[index], color: .btDoctorPrimary, delay: Double(index) * 0.05)
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                        .animation(.spring().delay(0.1), value: appeared)

                        // Remarks Box
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            BTSectionHeader(title: "Physician Remarks")
                            
                            TextEditor(text: $remarks)
                                .font(.btBodyMedium)
                                .padding(Spacing.md)
                                .frame(minHeight: 140)
                                .background(Color.btSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                .btCardShadow()
                                .overlay(
                                    Group {
                                        if remarks.isEmpty {
                                            Text("Enter dosage instructions or clinical notes...")
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
                            title: "Save Medication Plan",
                            icon: "checkmark.seal.fill",
                            gradient: LinearGradient.btDoctorGradient,
                            shadowColor: .btDoctorPrimary,
                            isLoading: isSubmitting
                        ) {
                            if isFormValid {
                                submitAndClose()
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
        .alert("Success", isPresented: $showSuccessAlert) {
            Button("OK") { dismiss() }
        } message: {
            Text("Medication Plan Saved Successfully!")
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }
    
    private var isFormValid: Bool {
        medicines.contains(where: { $0.isSelected }) || !remarks.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func submitAndClose() {
        let selectedMedicines = medicines.filter { $0.isSelected }.map { $0.name }
        guard let url = APIConfig.getURL(for: "save_medication_diary.php") else { dismiss(); return }
        
        withAnimation { isSubmitting = true }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "patient_id": patientId,
            "medicines": selectedMedicines,
            "remarks": remarks
        ])
        
        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                withAnimation { isSubmitting = false }
                showSuccessAlert = true
            }
        }.resume()
    }
}

// MARK: - Medicine Selection Card
private struct MedicineSelectionCard: View {
    @Binding var medicine: Medication.Medicine
    let color: Color
    let delay: Double
    @State private var showed = false

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                medicine.isSelected.toggle()
            }
        } label: {
            HStack(spacing: Spacing.md) {
                ZStack {
                    Circle()
                        .fill(medicine.isSelected ? color : Color.btBackground)
                        .frame(width: 24, height: 24)
                    
                    if medicine.isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .overlay(Circle().stroke(medicine.isSelected ? color : Color.btBorder, lineWidth: 2))
                
                Text(medicine.name)
                    .font(.btLabel)
                    .foregroundColor(medicine.isSelected ? .btTextPrimary : .btTextSecond)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }
            .padding(Spacing.md)
            .background(medicine.isSelected ? color.opacity(0.06) : Color.btSurface)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .btCardShadow(color: medicine.isSelected ? color.opacity(0.1) : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(medicine.isSelected ? color.opacity(0.4) : Color.clear, lineWidth: 1.5)
            )
            .opacity(showed ? 1 : 0)
            .offset(y: showed ? 0 : 10)
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.spring().delay(delay)) { showed = true }
        }
    }
}

#Preview {
    Medication()
}
