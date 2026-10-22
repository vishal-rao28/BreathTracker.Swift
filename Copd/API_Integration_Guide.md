# API Integration & Configuration Guide

## 1. Local Network Setup (`APIConfig.swift`)
To connect your iOS app with the backend PHP files on your local machine, you need to configure the Base URL.

1. Open `Copd/APIConfig.swift` in Xcode.
2. Find the line:
   ```swift
   static let baseURL = "http://14.139.187.229:8081/breathtrack"
   ```
3. **If testing on a physical iPhone**: Find your Mac's local IP address (e.g., `172.25.86.207`) by going to System Settings > Network. Replace `127.0.0.1` with your actual IP address:
   ```swift
   static let baseURL = "http://14.139.187.229:8081/breathtrack"
   ```
4. Make sure **XAMPP / MAMP** is running and the `nov 19` folder is placed inside your server's document root (e.g., `htdocs`).

## 2. Database Configuration (`config.php`)
Ensure your PHP backend can talk to your MySQL database.

1. Open `nov 19/config.php`.
2. Update the credentials if they are different on your machine:
   ```php
   private $host = "localhost";
   private $db_name = "breathtrack";
   private $username = "root";
   private $password = ""; // Add password if required by XAMPP/MAMP
   ```

## 3. How to use the API in Swift
I have already connected `patientlogin.swift` and `doctorlogin.swift` for you as examples. To add connections for other files (like signups, or dashboards), follow this pattern:

```swift
// 1. Get the URL
guard let url = APIConfig.getURL(for: "your_php_file.php") else { return }

// 2. Create the Request
var request = URLRequest(url: url)
request.httpMethod = "POST"
request.setValue("application/json", forHTTPHeaderField: "Content-Type")

// 3. Prepare JSON Body
let body: [String: Any] = [
    "key_name": "value"
]
request.httpBody = try? JSONEncoder().encode(body)

// 4. Send the Request
URLSession.shared.dataTask(with: request) { data, response, error in
    DispatchQueue.main.async {
        // Handle result natively here...
        // JSON parsing
    }
}.resume()
```

### Next Steps to fully connect:
- Implement the same code pattern in `patientsignup.swift` mapping to `patient_signup.php`.
- Ensure all backend responses are standard JSON with `status` and `message` properties so your iOS app can parse them perfectly.
