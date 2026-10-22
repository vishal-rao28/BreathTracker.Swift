import Foundation

struct APIConfig {
    // ⚠️ CONFIGURATION IMPORTANT ⚠️
    // Change this to your local machine's IP address (e.g., "http://172.25.86.207/nov%2019")
    // If testing on a physical iOS device, localhost / 127.0.0.1 won't work.
    // Ensure your XAMPP or MAMP is running and `breathtrack` is in the htdocs folder.
//    static let baseURL = "http://14.139.187.229:8081/breathtrack"

    static let baseURL = "http://103.249.82.251:8080/breathtrack_%20192311084"
    static func getURL(for endpoint: String) -> URL? {
        return URL(string: "\(baseURL)/\(endpoint)")
    }
}
