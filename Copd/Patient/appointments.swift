import SwiftUI

struct Appointments: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var session: PatientSession
    @Binding var isPresented: Bool
    
    // Patient Details
    @State private var name = ""
    @State private var age = ""
    @State private var gender: String = ""
    @State private var contact = ""
    @State private var email = ""
    @State private var address = ""
    
    // Medical Details
    @State private var copdConfirmed: Bool? = nil
    
    @State private var symptoms: Set<String> = []
    let symptomList = [
        "Shortness of breath",
        "Persistent cough",
        "Wheezing",
        "Chest tightness",
        "Fatigue"
    ]
    
    @State private var symptomOther = ""
    @State private var medications = ""
    @State private var allergies = ""
    
    // Smoking History
    @State private var smokingStatus = ""
    
    // Preferred Appointment
    @State private var preferredDate = Date()
    @State private var preferredTimes = ""
    let timeOptions = ["Morning", "Afternoon", "Evening"]
    
    @State private var isOtherSelected = false
    @State private var modeOfConsultation = ""
    let modes = ["In-Person", "Online / Tele"]
    let doctorNumber = "+91 9663952802" // Updated with doctor's number
    
    // Navigation and Alert state
    @State private var goToDashboard = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isUploading = false
    @State private var appeared = false
    @State private var isAttemptingSubmit = false
    @State private var showSuccessAlert = false
    
    var isFormValid: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAge = age.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedContact = contact.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let isValidEmail = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: trimmedEmail)
        
        let basicInfo = !trimmedName.isEmpty && !trimmedAge.isEmpty && !gender.isEmpty &&
                       !trimmedContact.isEmpty && trimmedContact.count == 10 && trimmedContact.allSatisfy({ $0.isNumber }) &&
                       !trimmedEmail.isEmpty && isValidEmail && !trimmedAddress.isEmpty
        
        let medicalInfo = copdConfirmed != nil && !smokingStatus.isEmpty
        let slotInfo = !preferredTimes.isEmpty && !modeOfConsultation.isEmpty
        
        return basicInfo && medicalInfo && slotInfo
    }
    
    var body: some View {
        ZStack {
            Color.btBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Header
                HStack {
                    BTBackButton(action: { 
                        session.selectedTab = 0
                        dismiss()
                    })
                    Spacer()
                    Text("Book Appointment")
                        .font(.btHeadline)
                        .foregroundColor(.btTextPrimary)
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.sm)
                .background(Color.btBackground)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: Spacing.xl) {
                        
                        // Intro text
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Tell us about yourself")
                                .font(.btTitle)
                                .foregroundColor(.btTextPrimary)
                            Text("Please fill in the details below to schedule your appointment.")
                                .font(.btBodyMedium)
                                .foregroundColor(.btTextPrimary)
                        }
                        .padding(.top, Spacing.sm)
                        .padding(.horizontal, Spacing.lg)
                        .opacity(appeared ? 1 : 0)
                        
                        // MARK: - Patient Details Section
                        ModernSection(title: "Patient Details", icon: "person.fill") {
                            VStack(spacing: Spacing.md) {
                                BTInputField(placeholder: "Full Name", icon: "person", text: $name)
                                    .textInputAutocapitalization(.words)
                                if !name.isEmpty && name.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil {
                                    Text("Name should not contain numbers")
                                        .font(.btCaption2).foregroundColor(.btAccentOrange).padding(.leading, Spacing.md)
                                } else if isAttemptingSubmit && name.isEmpty {
                                    Text("Name is required")
                                        .font(.btCaption2).foregroundColor(.btAccentOrange).padding(.leading, Spacing.md)
                                }
                                
                                BTInputField(placeholder: "Age", icon: "calendar", text: $age)
                                    .keyboardType(.numberPad)
                                if !age.isEmpty && age.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil {
                                    Text("Please enter digits only").font(.btCaption2).foregroundColor(.btAccentOrange).padding(.leading, Spacing.md)
                                } else if isAttemptingSubmit && age.isEmpty {
                                    Text("Age is required").font(.btCaption2).foregroundColor(.btAccentOrange).padding(.leading, Spacing.md)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Gender").font(.btCaption2).foregroundColor(.btTextPrimary).textCase(.uppercase)
                                    HStack(spacing: Spacing.sm) {
                                        SelectableChip(title: "Male", isSelected: gender == "Male") { gender = "Male" }
                                        SelectableChip(title: "Female", isSelected: gender == "Female") { gender = "Female" }
                                        SelectableChip(title: "Other", isSelected: gender == "Others") { gender = "Others" }
                                    }
                                    if isAttemptingSubmit && gender.isEmpty {
                                        Text("Please select gender").font(.btCaption2).foregroundColor(.btAccentOrange)
                                    }
                                }
                                .padding(.top, Spacing.xs)
                                
                                BTInputField(placeholder: "Contact Number", icon: "phone", text: $contact)
                                    .keyboardType(.phonePad)
                                if !contact.isEmpty {
                                    if contact.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil {
                                        Text("Only digits are allowed").font(.btCaption2).foregroundColor(.btAccentOrange).padding(.leading, Spacing.md)
                                    } else if contact.count != 10 {
                                        Text("Exactly 10 digits required").font(.btCaption2).foregroundColor(.btAccentOrange).padding(.leading, Spacing.md)
                                    }
                                } else if isAttemptingSubmit {
                                    Text("Contact number is required").font(.btCaption2).foregroundColor(.btAccentOrange).padding(.leading, Spacing.md)
                                }
                                
                                BTInputField(placeholder: "Email Address", icon: "envelope", text: $email)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                
                                if !email.isEmpty {
                                    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                                    let isEmailValid = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email.trimmingCharacters(in: .whitespacesAndNewlines))
                                    if !isEmailValid {
                                        Text("Please enter a valid email address (e.g. user@domain.com)").font(.btCaption2).foregroundColor(.btAccentOrange).padding(.leading, Spacing.md)
                                    }
                                } else if isAttemptingSubmit && email.isEmpty {
                                    Text("Email is required").font(.btCaption2).foregroundColor(.btAccentOrange).padding(.leading, Spacing.md)
                                }
                                
                                BTInputField(placeholder: "Address", icon: "mappin.and.ellipse", text: $address)
                                if isAttemptingSubmit && address.isEmpty {
                                    Text("Address is required").font(.btCaption2).foregroundColor(.btAccentOrange).padding(.leading, Spacing.md)
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                        .opacity(appeared ? 1 : 0)
                        
                        // MARK: - Medical Details Section
                        ModernSection(title: "Medical Information", icon: "heart.text.square.fill") {
                            VStack(alignment: .leading, spacing: Spacing.lg) {
                                VStack(alignment: .leading, spacing: Spacing.sm) {
                                    Text("Confirmed diagnosis of COPD?").font(.btCaption2).foregroundColor(.btTextPrimary).textCase(.uppercase)
                                    HStack(spacing: Spacing.sm) {
                                        SelectableChip(title: "Yes", isSelected: copdConfirmed == true) { copdConfirmed = true }
                                        SelectableChip(title: "No", isSelected: copdConfirmed == false) { copdConfirmed = false }
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: Spacing.sm) {
                                    Text("Current Symptoms").font(.btCaption2).foregroundColor(.btTextPrimary).textCase(.uppercase)
                                    VStack(alignment: .leading, spacing: Spacing.sm) {
                                        ForEach(symptomList, id: \.self) { symptom in
                                            SelectableCheckboxRow(title: symptom, isSelected: symptoms.contains(symptom)) {
                                                toggleItem(symptom, in: &symptoms)
                                            }
                                        }
                                        
                                        VStack(alignment: .leading, spacing: Spacing.sm) {
                                            SelectableCheckboxRow(title: "Other", isSelected: isOtherSelected) {
                                                isOtherSelected.toggle()
                                                if !isOtherSelected {
                                                    symptomOther = ""
                                                }
                                            }
                                            
                                            if isOtherSelected {
                                                TextField("Specify other symptom...", text: $symptomOther)
                                                    .font(.btBodyMedium)
                                                    .foregroundColor(.btTextPrimary)
                                                    .padding(14)
                                                    .background(Color.btBackground)
                                                    .cornerRadius(12)
                                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.btBorder, lineWidth: 1))
                                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                            }
                                        }
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: Spacing.sm) {
                                    Text("Smoking History").font(.btCaption2).foregroundColor(.btTextPrimary).textCase(.uppercase)
                                    VStack(spacing: Spacing.sm) {
                                        SelectableRow(title: "Current Smoker", isSelected: smokingStatus == "current") { smokingStatus = "current" }
                                        SelectableRow(title: "Former Smoker", isSelected: smokingStatus == "former") { smokingStatus = "former" }
                                        SelectableRow(title: "Never Smoked", isSelected: smokingStatus == "never") { smokingStatus = "never" }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                        .opacity(appeared ? 1 : 0)
                        
                        // MARK: - Appointment Section
                        ModernSection(title: "Preferred Slot", icon: "calendar.badge.clock") {
                            VStack(alignment: .leading, spacing: Spacing.xl) {
                                DatePicker("Preferred Date", selection: $preferredDate, in: Date()..., displayedComponents: .date)
                                    .font(.btHeadline)
                                    .foregroundColor(.btTextPrimary)
                                    .tint(.btPrimary)
                                
                                VStack(alignment: .leading, spacing: Spacing.sm) {
                                    Text("Preferred Time (-s)").font(.btCaption2).foregroundColor(.btTextPrimary).textCase(.uppercase)
                                    HStack(spacing: Spacing.sm) {
                                        ForEach(timeOptions, id: \.self) { time in
                                            SelectableChip(title: time, isSelected: preferredTimes == time) {
                                                preferredTimes = time
                                            }
                                        }
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: Spacing.sm) {
                                    Text("Mode of Consultation (-s)").font(.btCaption2).foregroundColor(.btTextPrimary).textCase(.uppercase)
                                    HStack(spacing: Spacing.sm) {
                                        ForEach(modes, id: \.self) { mode in
                                            SelectableChip(title: mode, isSelected: modeOfConsultation == mode) {
                                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                                    modeOfConsultation = mode
                                                }
                                            }
                                        }
                                    }

                                    if modeOfConsultation == "Online / Tele" {
                                        VStack(alignment: .leading, spacing: Spacing.xs) {
                                            Text("Doctor's Contact Number")
                                                .font(.btCaption2)
                                                .foregroundColor(.btTextSecond)
                                                .padding(.top, Spacing.sm)
                                            
                                            Button(action: {
                                                // Filter to keep only digits and + for the dialer
                                                let cleanNumber = doctorNumber.filter { "0123456789+".contains($0) }
                                                
                                                if let url = URL(string: "tel:\(cleanNumber)") {
                                                    if UIApplication.shared.canOpenURL(url) {
                                                        UIApplication.shared.open(url)
                                                    } else {
                                                        // Fallback for Simulator where tel: is not supported
                                                        alertMessage = "Phone dialer is not available on this device. Please call: \(doctorNumber)"
                                                        showAlert = true
                                                    }
                                                }
                                            }) {
                                                HStack(spacing: Spacing.md) {
                                                    ZStack {
                                                        Circle()
                                                            .fill(Color.btAccentGreen.opacity(0.12))
                                                            .frame(width: 44, height: 44)
                                                        Image(systemName: "phone.fill")
                                                            .foregroundColor(.btAccentGreen)
                                                            .font(.system(size: 18))
                                                    }
                                                    
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text("Dr. Specialist")
                                                            .font(.btCaption2)
                                                            .foregroundColor(.btTextSecond)
                                                        Text(doctorNumber)
                                                            .font(.btHeadline)
                                                            .foregroundColor(.btPrimary)
                                                    }
                                                    
                                                    Spacer()
                                                    
                                                    Image(systemName: "arrow.up.right.circle.fill")
                                                        .foregroundColor(.btPrimary.opacity(0.6))
                                                        .font(.system(size: 22))
                                                }
                                                .padding(Spacing.md)
                                                .background(Color.btSurface2)
                                                .cornerRadius(18)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 18)
                                                        .stroke(Color.btAccentGreen.opacity(0.25), lineWidth: 1)
                                                )
                                            }
                                            .buttonStyle(.plain)
                                            
                                            Text("Tap to call your doctor for consultation details.")
                                                .font(.btCaption2)
                                                .foregroundColor(.btTextTertiary)
                                                .italic()
                                                .padding(.leading, 4)
                                        }
                                        .transition(.asymmetric(
                                            insertion: .opacity.combined(with: .move(edge: .top)).combined(with: .scale(scale: 0.95)),
                                            removal: .opacity.combined(with: .move(edge: .top))
                                        ))
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                        .opacity(appeared ? 1 : 0)
                        
                        // Submit Button
                        BTPrimaryButton(title: "Schedule Appointment", icon: "arrow.right", isLoading: isUploading, isDisabled: !isFormValid) {
                            submitForm()
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.sm)
                        .padding(.bottom, 60)
                        .opacity(appeared ? 1 : 0)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            prefillFromSession()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appeared = true
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Note"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .alert("Success", isPresented: $showSuccessAlert) {
            Button("OK") {
                isPresented = false
                session.selectedTab = 0
            }
        } message: {
            Text("Your appointment has been scheduled successfully!")
        }
    }
    
    // MARK: - Logic
    
    func toggleItem(_ item: String, in set: inout Set<String>) {
        if set.contains(item) { set.remove(item) }
        else { set.insert(item) }
    }
    
    private func prefillFromSession() {
        if let current = session.current {
            if name.isEmpty { name = current.name }
            if age.isEmpty, let a = current.age { age = "\(a)" }
            if gender.isEmpty { gender = current.gender ?? "" }
            if address.isEmpty { /* address is not in profile usually */ }
        }
    }
    
    func submitForm() {
        isAttemptingSubmit = true
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAge = age.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedContact = contact.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let isValidEmail = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: trimmedEmail)
        
        if trimmedName.isEmpty || trimmedAge.isEmpty || gender.isEmpty || 
           trimmedContact.isEmpty || trimmedContact.count != 10 || !trimmedContact.allSatisfy({ $0.isNumber }) ||
           trimmedEmail.isEmpty || !isValidEmail || trimmedAddress.isEmpty ||
           copdConfirmed == nil || smokingStatus.isEmpty ||
           preferredTimes.isEmpty || modeOfConsultation.isEmpty ||
           trimmedName.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil {
            return
        }
        
        guard let url = APIConfig.getURL(for: "submit_appointment.php") else { return }
        
        withAnimation { isUploading = true }
        
        let outFormatter = DateFormatter()
        outFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = outFormatter.string(from: preferredDate)
        
        let finalSymptoms = Array(symptoms) + (symptomOther.isEmpty ? [] : [symptomOther])
        
        let body: [String: Any] = [
            "patient_id": session.current?.patient_id ?? "guest",
            "name": name,
            "age": age,
            "gender": gender,
            "contact": contact,
            "email": email,
            "address": address,
            "copd_confirmed": copdConfirmed == true ? 1 : 0,
            "duration_symptoms": "",
            "symptoms": finalSymptoms,
            "medications": medications,
            "allergies": allergies,
            "smoking_status": smokingStatus,
            "preferred_date": formattedDate,
            "preferred_time": [preferredTimes],
            "consultation_mode": [modeOfConsultation]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            withAnimation { isUploading = false }
            alertMessage = "Data encoding error."
            showAlert = true
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                withAnimation { isUploading = false }
                
                if let error = error {
                    self.alertMessage = "Connection Error: \(error.localizedDescription)"
                    self.showAlert = true
                    return
                }
                
                guard let data = data else {
                    self.alertMessage = "No response from server."
                    self.showAlert = true
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        let status = json["status"] as? String ?? "error"
                        let message = json["message"] as? String ?? "Unknown error"
                        
                        if status == "success" {
                            // After submission, we must ensure it's "Pending" so it shows in Notifications.
                            // The backend UPDATE might keep it as "Accepted" if they were previously booked.
                            self.resetStatusToPending()
                        } else {
                            self.alertMessage = "Booking failed: \(message)"
                            self.showAlert = true
                        }
                    } else {
                        self.alertMessage = "Invalid response format from server."
                        self.showAlert = true
                    }
                } catch {
                    self.alertMessage = "Server error."
                    self.showAlert = true
                }
            }
        }.resume()
    }
    
    /// Resets the status to pending so it appears in Doctor Notifications
    private func resetStatusToPending() {
        guard let patientId = session.current?.patient_id else {
            self.showSuccessAlert = true
            return
        }
        
        // 1. Get the appointment ID for this patient
        guard let getUrl = APIConfig.getURL(for: "get_appointment.php") else {
            self.showSuccessAlert = true
            return
        }
        
        var getRequest = URLRequest(url: getUrl)
        getRequest.httpMethod = "POST"
        getRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        getRequest.httpBody = try? JSONSerialization.data(withJSONObject: ["patient_id": patientId])
        
        URLSession.shared.dataTask(with: getRequest) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let appt = json["appointment"] as? [String: Any],
                  let apptId = appt["appointment_id"] else {
                DispatchQueue.main.async { self.showSuccessAlert = true }
                return
            }
            
            // 2. Set status to pending
            guard let updateUrl = APIConfig.getURL(for: "update_appointment_status.php") else {
                DispatchQueue.main.async { self.showSuccessAlert = true }
                return
            }
            
            var updateRequest = URLRequest(url: updateUrl)
            updateRequest.httpMethod = "POST"
            updateRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let body: [String: Any] = ["appointment_id": apptId, "status": "Pending"]
            updateRequest.httpBody = try? JSONSerialization.data(withJSONObject: body)
            
            URLSession.shared.dataTask(with: updateRequest) { _, _, _ in
                DispatchQueue.main.async {
                    self.showSuccessAlert = true
                }
            }.resume()
        }.resume()
    }
}

// MARK: - Modern UI Components

struct ModernSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(LinearGradient.btPrimaryGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Text(title)
                    .font(.btTitle2)
                    .foregroundColor(.btTextPrimary)
            }
            
            content
                .padding(Spacing.lg)
                .background(Color.btSurface)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .btCardShadow()
        }
    }
}

struct SelectableChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.btLabel)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, 12)
                .background(isSelected ? Color.btPrimary : Color.btSurface2)
                .foregroundColor(isSelected ? .white : .btTextPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(isSelected ? Color.btPrimary : Color.btBorder, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct SelectableRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.btBodyMedium)
                    .foregroundColor(.btTextPrimary)
                Spacer()
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.btPrimary : Color.btBorder, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    if isSelected {
                        Circle()
                            .fill(Color.btPrimary)
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .padding(14)
            .background(isSelected ? Color.btPrimary.opacity(0.08) : Color.btSurface)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.btPrimary.opacity(0.3) : Color.btBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct SelectableCheckboxRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.btPrimary : Color.btBorder, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    if isSelected {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.btPrimary)
                            .frame(width: 24, height: 24)
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                Text(title)
                    .font(.btBodyMedium)
                    .foregroundColor(.btTextPrimary)
                
                Spacer()
            }
            .padding(14)
            .background(isSelected ? Color.btPrimary.opacity(0.08) : Color.btSurface)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.btPrimary.opacity(0.3) : Color.btBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    Appointments(isPresented: .constant(true))
        .environmentObject(PatientSession())
}
