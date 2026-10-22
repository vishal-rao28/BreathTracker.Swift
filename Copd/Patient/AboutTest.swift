import SwiftUI
struct AboutTest: View {
    @State private var selectedRole = 0
    var body: some View {
        ZStack(alignment: .top) {
            if selectedRole == 0 {
                patientlogin()
            } else {
                doctorlogin()
            }
            
            // Picker overlay
            Picker("Role", selection: $selectedRole) {
                Text("Patient").tag(0)
                Text("Doctor").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .padding(.top, 40)
        }
    }
}
