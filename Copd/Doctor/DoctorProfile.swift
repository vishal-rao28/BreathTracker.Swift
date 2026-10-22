import SwiftUI

struct DoctorProfile: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var session: PatientSession

    @State private var name        = ""
    @State private var age         = ""
    @State private var email       = ""
    @State private var phone       = ""
    @State private var contentVisible = false
    @State private var isFetching  = true

    // Inline editing states
    @State private var isEditing   = false
    @State private var editName    = ""
    @State private var editAge     = ""
    @State private var editEmail   = ""
    @State private var editPhone   = ""
    @State private var isUpdating  = false

    var body: some View {
        ZStack {
            Color.btBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Header ──────────────────────────────────────────────
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
                    Text("My Profile")
                        .font(.btHeadline)
                        .foregroundColor(.btTextPrimary)
                    Spacer()
                    
                    if isEditing {
                        Button(action: { saveProfile() }) {
                            if isUpdating {
                                ProgressView().scaleEffect(0.9)
                                    .frame(width: 44, height: 44)
                            } else {
                                Text("Save")
                                    .font(.btHeadline)
                                    .foregroundColor(.btDoctorPrimary)
                                    .frame(width: 44, height: 44)
                            }
                        }
                    } else {
                        Button(action: {
                            editName = name
                            editAge = age
                            editEmail = email
                            editPhone = phone
                            isEditing = true
                        }) {
                            Text("Edit")
                                .font(.btHeadline)
                                .foregroundColor(.btDoctorPrimary)
                                .frame(width: 44, height: 44)
                        }
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.md)
                .background(Color.btBackground)

                if isFetching {
                    Spacer()
                    ProgressView().scaleEffect(1.4).tint(.btDoctorPrimary)
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: Spacing.lg) {

                            // ── Doctor Avatar ──────────────────────────────────
                            VStack(spacing: Spacing.sm) {
                                ZStack {
                                    Circle()
                                        .fill(Color.btDoctorPrimary.opacity(0.1))
                                        .frame(width: 90, height: 90)
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .frame(width: 80, height: 80)
                                        .foregroundColor(.btDoctorPrimary)
                                }
                                Text("Primary Consultant")
                                    .font(.btLabel)
                                    .foregroundColor(.btTextSecond)
                            }
                            .padding(.top, Spacing.md)

                            // ── Info Rows ──────────────────────────────────────
                            VStack(spacing: Spacing.md) {
                                if isEditing {
                                    DoctorProfileInputRow(icon: "person.text.rectangle", title: "Name",   text: $editName)
                                    DoctorProfileInputRow(icon: "calendar",              title: "Age",    text: $editAge, keyboardType: .numberPad)
                                    DoctorProfileInputRow(icon: "envelope.fill",         title: "Email",  text: $editEmail, keyboardType: .emailAddress)
                                    DoctorProfileInputRow(icon: "phone.fill",            title: "Phone",  text: $editPhone, keyboardType: .phonePad)
                                } else {
                                    DoctorProfileDetailRow(icon: "person.text.rectangle", title: "Name",   value: name,  delay: 0.10)
                                    DoctorProfileDetailRow(icon: "calendar",              title: "Age",    value: age.isEmpty ? "—" : "\(age) years",   delay: 0.15)
                                    DoctorProfileDetailRow(icon: "envelope.fill",         title: "Email",  value: email, delay: 0.20)
                                    DoctorProfileDetailRow(icon: "phone.fill",            title: "Phone",  value: phone, delay: 0.25)
                                }
                                DoctorProfileDetailRow(icon: "cross.case.fill",       title: "Specialization", value: "Pulmonologist", delay: 0.30)
                            }
                            .padding(.horizontal, Spacing.lg)
                        }
                        .opacity(contentVisible ? 1 : 0)
                        .offset(y: contentVisible ? 0 : 20)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadProfile()
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                contentVisible = true
            }
        }
    }

    // MARK: - Fetch doctor details from backend
    private func loadProfile() {
        isFetching = true
        let storedId = UserDefaults.standard.string(forKey: "loggedInDoctorId") ?? ""
        print("DEBUG: Loading doctor profile for ID: '\(storedId)'")
        guard !storedId.isEmpty,
              let url = APIConfig.getURL(for: "get_doctor_profile.php") else {
            print("DEBUG: Cannot load profile. loggedInDoctorId is empty or base URL is invalid.")
            isFetching = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["doctor_id": storedId])

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                isFetching = false
                if let error = error {
                    print("DEBUG: Doctor profile fetch failed: \(error.localizedDescription)")
                    return
                }
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("DEBUG: Doctor profile invalid data or JSON format")
                    return
                }
                
                if let status = json["status"] as? String, status == "error" {
                    print("DEBUG: Doctor profile error response: \(json["message"] ?? "")")
                }
                
                guard let doc = json["data"] as? [String: Any] else {
                    print("DEBUG: Doctor profile missing or invalid 'data' key")
                    return
                }

                name  = (doc["name"] as? String) ?? ""
                email = (doc["email"] as? String) ?? ""
                
                if let phoneVal = doc["phone"], !(phoneVal is NSNull) {
                    phone = "\(phoneVal)"
                } else {
                    phone = ""
                }
                
                if let ageVal = doc["age"], !(ageVal is NSNull) {
                    age = "\(ageVal)"
                } else {
                    age = ""
                }
                print("DEBUG: Successfully parsed doctor profile details: \(name), \(email)")
            }
        }.resume()
    }

    // MARK: - Save doctor details to backend
    private func saveProfile() {
        guard !editName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isUpdating = true
        let storedId = UserDefaults.standard.string(forKey: "loggedInDoctorId") ?? ""
        guard !storedId.isEmpty,
              let url = APIConfig.getURL(for: "update_doctor_profile.php") else {
            isUpdating = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let ageInt = Int(editAge)
        let body: [String: Any] = [
            "doctor_id": storedId,
            "name": editName,
            "age": ageInt as Any,
            "email": editEmail,
            "phone": editPhone
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                isUpdating = false
                if let error = error {
                    print("DEBUG: Profile update failed: \(error.localizedDescription)")
                    return
                }
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let status = json["status"] as? String,
                      status == "success" else {
                    print("DEBUG: Server returned update error")
                    return
                }
                
                name = editName
                age = editAge
                email = editEmail
                phone = editPhone
                isEditing = false
                print("DEBUG: Profile updated successfully")
            }
        }.resume()
    }
}

// MARK: - Custom input field row
private struct DoctorProfileInputRow: View {
    let icon:  String
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.btDoctorPrimary.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.btDoctorPrimary)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.btCaption2)
                    .foregroundColor(.btTextSecond)
                TextField("Enter \(title.lowercased())", text: $text)
                    .keyboardType(keyboardType)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .font(.btHeadline)
                    .foregroundColor(.btTextPrimary)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            Spacer()
        }
        .padding(Spacing.md)
        .background(Color.btSurface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .btCardShadow()
    }
}

// MARK: - Read-only row
private struct DoctorProfileDetailRow: View {
    let icon:  String
    let title: String
    let value: String
    let delay: Double

    @State private var appeared = false

    var body: some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.btDoctorPrimary.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.btDoctorPrimary)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.btCaption2)
                    .foregroundColor(.btTextSecond)
                Text(value.isEmpty ? "—" : value)
                    .font(.btHeadline)
                    .foregroundColor(.btTextPrimary)
            }
            Spacer()
        }
        .padding(Spacing.md)
        .background(Color.btSurface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .btCardShadow()
        .opacity(appeared ? 1 : 0)
        .offset(x: appeared ? 0 : -20)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                appeared = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        DoctorProfile().environmentObject(PatientSession())
    }
}
