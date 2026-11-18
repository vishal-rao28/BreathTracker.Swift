<div align="center">
  <img src="https://raw.githubusercontent.com/vishal-rao28/Vishal-s-portfolio/main/src/assets/breathtrack/app_icon.jpg" width="96" height="96" alt="BreathTrack Icon" />

  <h1>BreathTrack — COPD & Respiratory Care</h1>

  <p><b>Native iOS MedTech & telehealth respiratory companion built with SwiftUI featuring dual Doctor/Patient portals, ABG & PFT diagnostics, 6-Minute Walk Test tracking, and inhaler adherence workflows.</b></p>

  <a href="https://apps.apple.com/in/app/breathtrack/id6804558579">
    <img src="https://img.shields.io/badge/Apple_App_Store-Live-E11D48?style=for-the-badge&logo=apple&logoColor=white" alt="App Store Live" />
  </a>
  <img src="https://img.shields.io/badge/Swift-SwiftUI-F05138?style=for-the-badge&logo=swift&logoColor=white" alt="SwiftUI" />
  <img src="https://img.shields.io/badge/Domain-MedTech_%26_Telehealth-0EA5E9?style=for-the-badge" alt="MedTech" />
  <img src="https://img.shields.io/badge/Platform-iOS-0A84FF?style=for-the-badge&logo=ios&logoColor=white" alt="iOS" />
</div>

---

## 📱 App Preview

<div align="center">
  <table>
    <tr>
      <td><img src="https://raw.githubusercontent.com/vishal-rao28/Vishal-s-portfolio/main/src/assets/breathtrack/screen1.webp" width="190" alt="Screen 1" /></td>
      <td><img src="https://raw.githubusercontent.com/vishal-rao28/Vishal-s-portfolio/main/src/assets/breathtrack/screen2.webp" width="190" alt="Screen 2" /></td>
      <td><img src="https://raw.githubusercontent.com/vishal-rao28/Vishal-s-portfolio/main/src/assets/breathtrack/screen3.webp" width="190" alt="Screen 3" /></td>
      <td><img src="https://raw.githubusercontent.com/vishal-rao28/Vishal-s-portfolio/main/src/assets/breathtrack/screen4.webp" width="190" alt="Screen 4" /></td>
    </tr>
  </table>
</div>

---

## ✨ Key Capabilities

- **🩺 Clinical Respiratory Diagnostics**: Structured logging & review for **ABG Reports** (`ABGReport.swift`), **PFT Values** (`PftValues.swift`), and the **6-Minute Walk Test** (`SixMinWalkTestView.swift`).
- **💨 Inhaler & Medication Adherence**: Daily inhaler tracking (`InhalerAdherenceView.swift`), medication schedules (`Medication.swift`), and local reminders (`UserNotifications`).
- **👨‍⚕️ Dual Doctor & Patient Workflows**: Dedicated clinician dashboards (`Patientlist.swift`, `SearchPatientReportsView.swift`, `DoctorProfile.swift`) and patient appointment booking (`Appointmentform.swift`, `PatientAppointments.swift`).
- **🎥 Rehab Video & Media Uploads**: Integrated `PhotosUI` and `SafariServices` support for pulmonary rehabilitation content (`UploadVideos.swift`).
- **🎨 Unified Design System**: Modular tokens and reusable clinical cards defined in `DesignSystem.swift` across 47 Swift source files.

---

## 🏗️ Architecture

```mermaid
flowchart LR
    A["CopdApp (SwiftUI Entry)"] --> B["Patient Portal"]
    A --> C["Clinician Portal"]
    B --> D["ABG / PFT / 6-Min Walk Test"]
    B --> E["Inhaler Adherence & Reminders"]
    C --> F["Patient List & Report Search"]
    D & E & F --> G["APIConfig Networking Layer"]
```

---

## 🛠️ Frameworks & Tech Stack

| Layer | Technologies |
| :--- | :--- |
| **UI & Design System** | `SwiftUI`, `UIKit`, `DesignSystem.swift` |
| **Media & Web** | `PhotosUI`, `SafariServices` |
| **Engagement** | `UserNotifications` (`Notifications.swift`) |
| **Networking** | `Foundation`, `APIConfig.swift` |

---

## 🚀 Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/vishal-rao28/BreathTracker.Swift.git
   cd BreathTracker.Swift
   ```
2. Open the Xcode project:
   ```bash
   open Copd.xcodeproj
   ```
3. Select an iOS Simulator or physical iPhone and press **`Cmd + R`**.

---

## 👤 Author

**Vishal Rao M** — Native iOS & On-Device AI Architect  
[Live Portfolio](https://vishal-rao28.github.io/Vishal-s-portfolio/) · [GitHub](https://github.com/vishal-rao28) · [Vishal iOS Labs](https://github.com/Vishal-iOS-Labs)
