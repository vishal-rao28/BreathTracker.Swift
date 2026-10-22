
import SwiftUI

enum ReportType {
    case pft
    case abg
    case walkTest
}

struct UnifiedReport: Identifiable {
    let id: String
    let type: ReportType
    let condition: String
    let comments: String
    let walkDescription: String   // For walk test
    let imageURL: URL?
    let createdAt: String
    let dateObj: Date?
    let dateString: String
    let timeString: String
}

struct ReportGroup: Identifiable {
    let id = UUID()
    let dateObject: Date
    let dateTitle: String
    let reports: [UnifiedReport]
}

struct SearchPatientReportsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
    @State private var searchError: String? = nil
    
    @State private var reportGroups: [ReportGroup] = []
    @State private var totalReports: Int = 0
    @State private var fullScreenImageURL: URL? = nil
    
    var body: some View {
        ZStack {
            Color.btBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    BTBackButton(action: { dismiss() })
                    Spacer()
                    Text("Report Search")
                        .font(.btHeadline)
                        .foregroundColor(.btTextPrimary)
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.md)
                
                // Search Bar
                HStack(spacing: Spacing.sm) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.btTextTertiary)
                        TextField("Enter Patient ID...", text: $searchText)
                            .font(.btBodyMedium)
                            .disableAutocorrection(true)
                            .textInputAutocapitalization(.never)
                            .submitLabel(.search)
                            .onSubmit {
                                performSearch()
                            }
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.btTextTertiary)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.btSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.btBorder, lineWidth: 1)
                    )
                    
                    Button(action: performSearch) {
                        Text("Search")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                            .background(Color.btDoctorPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color.btDoctorPrimary.opacity(0.3), radius: 6, y: 3)
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.md)

                // Main Content Area
                if isSearching {
                    Spacer()
                    ProgressView("Searching Reports...")
                        .tint(.btDoctorPrimary)
                    Spacer()
                } else if let err = searchError {
                    Spacer()
                    VStack(spacing: Spacing.sm) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.btAccentOrange)
                        Text(err)
                            .font(.btBody)
                            .foregroundColor(.btTextSecond)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    Spacer()
                } else if reportGroups.isEmpty {
                    Spacer()
                    VStack(spacing: Spacing.sm) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.btTextTertiary.opacity(0.5))
                        Text("Search for a Patient ID to view their medical report history.")
                            .font(.btBody)
                            .foregroundColor(.btTextSecond)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: Spacing.xl) {
                            
                            // Top Overview Banner
                            HStack {
                                Image(systemName: "folder.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.btDoctorPrimary)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Timeline Overview")
                                        .font(.btHeadline)
                                        .foregroundColor(.btTextPrimary)
                                    Text("Found \(totalReports) uploaded \(totalReports == 1 ? "report" : "reports")")
                                        .font(.btCaption)
                                        .foregroundColor(.btTextSecond)
                                }
                                Spacer()
                            }
                            .padding(Spacing.md)
                            .background(Color.btDoctorPrimary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal, Spacing.lg)
                            .padding(.top, Spacing.xs)

                            // Unified Chronological Groups
                            ForEach(reportGroups) { group in
                                VStack(alignment: .leading, spacing: Spacing.md) {
                                    
                                    // Chronological Group header
                                    HStack {
                                        Image(systemName: "calendar")
                                            .foregroundColor(.btAccent)
                                        Text("Reports uploaded on \(group.dateTitle)")
                                            .font(.btTitle3)
                                            .foregroundColor(.btTextPrimary)
                                    }
                                    .padding(.horizontal, Spacing.lg)
                                    .padding(.top, Spacing.sm)
                                    
                                    ForEach(group.reports) { report in
                                        UnifiedReportCard(report: report) { url in
                                            withAnimation(.easeInOut(duration: 0.25)) {
                                                fullScreenImageURL = url
                                            }
                                        }
                                        .padding(.horizontal, Spacing.lg)
                                    }
                                }
                            }
                            Spacer(minLength: 40)
                        }
                        .padding(.vertical, Spacing.sm)
                    }
                }
            }
            
            // Full Screen Image Overlay
            if let fullURL = fullScreenImageURL {
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    AsyncImage(url: fullURL) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ProgressView().tint(.white)
                        }
                    }
                    
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    fullScreenImageURL = nil
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.white.opacity(0.8))
                                    .background(Circle().fill(Color.black.opacity(0.5)))
                            }
                            .padding(.trailing, 20)
                            .padding(.top, 40)
                        }
                        Spacer()
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .zIndex(100)
            }
        }
    }
    
    private func performSearch() {
        let sid = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !sid.isEmpty else { return }
        
        isSearching = true
        searchError = nil
        reportGroups = []
        totalReports = 0
        
        guard let url = APIConfig.getURL(for: "get_medical_reports.php") else {
            self.searchError = "Invalid API URL."
            self.isSearching = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["patient_id": sid])
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                self.isSearching = false
                
                if let error = error {
                    self.searchError = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    self.searchError = "Invalid server response."
                    return
                }
                
                if let status = json["status"] as? String, status == "error" {
                    self.searchError = json["message"] as? String ?? "An error occurred."
                    return
                }
                
                let baseURL = APIConfig.baseURL + "/" 
                
                var allReports: [UnifiedReport] = []
                
                if let pftArr = json["pft_history"] as? [[String: Any]] {
                    allReports.append(contentsOf: pftArr.compactMap { parseRecord($0, type: .pft, baseURL: baseURL) })
                }
                if let abgArr = json["abg_history"] as? [[String: Any]] {
                    allReports.append(contentsOf: abgArr.compactMap { parseRecord($0, type: .abg, baseURL: baseURL) })
                }
                if let walkArr = json["walk_test_history"] as? [[String: Any]] {
                    allReports.append(contentsOf: walkArr.compactMap { parseWalkRecord($0) })
                }
                
                if allReports.isEmpty {
                    self.searchError = "No history found for Patient ID: \(sid)"
                    return
                }
                
                self.totalReports = allReports.count
                
                // Group by dateString
                let grouped = Dictionary(grouping: allReports) { $0.dateString }
                
                let keyFormatter = DateFormatter()
                keyFormatter.dateFormat = "MMMM d, yyyy"
                
                self.reportGroups = grouped.map { key, reports in
                    let sortedReports = reports.sorted { ($0.dateObj ?? Date.distantPast) > ($1.dateObj ?? Date.distantPast) }
                    let date = keyFormatter.date(from: key) ?? Date.distantPast
                    return ReportGroup(dateObject: date, dateTitle: key, reports: sortedReports)
                }.sorted { $0.dateObject > $1.dateObject } // Sort groups descending (newest groups first)
                
            }
        }.resume()
    }
    
    private func parseRecord(_ dict: [String: Any], type: ReportType, baseURL: String) -> UnifiedReport? {
        let rawId = dict["id"]
        let idString: String
        if let intVal = rawId as? Int {
            idString = String(intVal)
        } else if let strVal = rawId as? String {
            idString = strVal
        } else {
            return nil
        }

        guard let condition = dict["condition"] as? String,
              let created = dict["created_at"] as? String else { return nil }
        
        var imgUrl: URL? = nil
        if let path = dict["image_path"] as? String, !path.isEmpty && path != "null" {
            imgUrl = URL(string: baseURL + path)
        }
        let comments = dict["comments"] as? String ?? ""
        
        let dbFormatter = DateFormatter()
        dbFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        var dateObj: Date? = nil
        var dateStr = created
        var timeStr = ""
        
        if let date = dbFormatter.date(from: created) {
            dateObj = date
            
            let dFormatter = DateFormatter()
            dFormatter.dateFormat = "MMMM d, yyyy"
            dateStr = dFormatter.string(from: date)
            
            let tFormatter = DateFormatter()
            tFormatter.timeStyle = .short
            timeStr = tFormatter.string(from: date)
        }
        
        return UnifiedReport(id: "\(type)-\(idString)", type: type, condition: condition, comments: comments, walkDescription: "", imageURL: imgUrl, createdAt: created, dateObj: dateObj, dateString: dateStr, timeString: timeStr)
    }
    
    private func parseWalkRecord(_ dict: [String: Any]) -> UnifiedReport? {
        let rawId = dict["id"]
        let idString: String
        if let intVal = rawId as? Int {
            idString = String(intVal)
        } else if let strVal = rawId as? String {
            idString = strVal
        } else {
            return nil
        }

        guard let description = dict["description"] as? String,
              let created = dict["created_at"] as? String else { return nil }
        
        let dbFormatter = DateFormatter()
        dbFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        var dateObj: Date? = nil
        var dateStr = created
        var timeStr = ""
        
        if let date = dbFormatter.date(from: created) {
            dateObj = date
            let dFormatter = DateFormatter()
            dFormatter.dateFormat = "MMMM d, yyyy"
            dateStr = dFormatter.string(from: date)
            let tFormatter = DateFormatter()
            tFormatter.timeStyle = .short
            timeStr = tFormatter.string(from: date)
        }
        
        return UnifiedReport(id: "walk-\(idString)", type: .walkTest, condition: "", comments: "", walkDescription: description, imageURL: nil, createdAt: created, dateObj: dateObj, dateString: dateStr, timeString: timeStr)
    }
}

private struct UnifiedReportCard: View {
    let report: UnifiedReport
    var onImageTap: ((URL) -> Void)? = nil
    
    var body: some View {
        if report.type == .walkTest {
            walkTestCard
        } else {
            clinicalCard
        }
    }
    
    private var walkTestCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(alignment: .top) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.btPrimary.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: "figure.walk")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.btPrimary)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("6 Min Walk Test")
                        .font(.btHeadline)
                        .foregroundColor(.btTextPrimary)
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                        Text(report.timeString)
                    }
                    .font(.btCaption)
                    .foregroundColor(.btTextSecond)
                }
                Spacer()
            }
            if !report.walkDescription.isEmpty {
                Text(report.walkDescription)
                    .font(.btBodyMedium)
                    .foregroundColor(.btTextPrimary)
                    .padding(.top, 4)
            }
        }
        .padding(Spacing.md)
        .background(Color.btSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .btCardShadow()
    }
    
    private var clinicalCard: some View {
        let isPFT = report.type == .pft
        let icon = isPFT ? "lungs.fill" : "drop.fill"
        let color: Color = isPFT ? .btAccentGreen : .btAccent
        let title = isPFT ? "PFT Analysis Report" : "ABG Blood Gas Report"
        
        return VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(alignment: .top) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.btHeadline)
                        .foregroundColor(.btTextPrimary)
                    
                    HStack(spacing: 4) {
                        Text("Severity: \(report.condition)")
                            .foregroundColor(conditionColor(report.condition))
                            .fontWeight(.semibold)
                        
                        Text("•")
                            .foregroundColor(.btTextTertiary)
                        
                        Image(systemName: "clock")
                        Text(report.timeString)
                    }
                    .font(.btCaption)
                    .foregroundColor(.btTextSecond)
                }
                Spacer()
            }
            
            if !report.comments.isEmpty {
                Text(report.comments)
                    .font(.btBodyMedium)
                    .foregroundColor(.btTextPrimary)
                    .padding(.top, 4)
            }
            
            // Image Preview Handler
            if let img = report.imageURL {
                AsyncImage(url: img) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.btBorder.opacity(0.5))
                            .frame(height: 150)
                            .overlay(ProgressView())
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    case .success(let image):
                        Color.clear
                            .overlay(
                                image.resizable()
                                    .scaledToFill()
                            )
                            .frame(height: 200)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                onImageTap?(img)
                            }
                    case .failure(_):
                        Rectangle()
                            .fill(Color.btAccentOrange.opacity(0.1))
                            .frame(height: 100)
                            .overlay(
                                VStack(spacing: 4) {
                                    Image(systemName: "photo.badge.exclamationmark")
                                    Text("Image unavailable")
                                }
                                .font(.btCaption)
                                .foregroundColor(.btAccentOrange)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    @unknown default:
                        EmptyView()
                    }
                }
                .padding(.top, Spacing.xs)
            }
        }
        .padding(Spacing.md)
        .background(Color.btSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
    }
    
    private func conditionColor(_ cond: String) -> Color {
        switch cond.lowercased() {
        case "normal": return .btAccentGreen
        case "mild": return .btDoctorPrimary
        case "moderate": return .btAccentOrange
        case "severe": return .btAccent
        default: return .btTextPrimary
        }
    }
}
