import Foundation

class InhalerAPI {
    // Shared method to mark inhaler as taken
    static func markAsTaken(patientId: String) {
        guard !patientId.isEmpty, patientId != "unknown" else { return }
        
        guard let url = APIConfig.getURL(for: "mark_inhaler_taken.php") else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: Date())
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "patient_id": patientId,
            "date_taken": dateString
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to mark inhaler: \(error.localizedDescription)")
            } else {
                print("Successfully marked inhaler taken on server for \(dateString)")
            }
        }.resume()
    }
}
