import SwiftUI
import SafariServices

struct VideoItem: Identifiable, Decodable {
    let id: Int
    let title: String
    let video_url: String
    let video_type: String
    let file_size: Int?
    let upload_date: String?
}

struct UploadVideos: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToVideosUploading = false
    @State private var appeared = false
    @State private var videos: [VideoItem] = []
    @State private var isLoading = true
    
    @State private var activeURL: URL? = nil
    @State private var showSafari = false
    
    private func fetchVideos() {
        guard let url = APIConfig.getURL(for: "upload_video.php") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async { self.isLoading = false }
            guard let data = data else { return }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let videosList = json["videos"] as? [[String: Any]] {
                    
                    let fetchedVideos = videosList.compactMap { dict -> VideoItem? in
                        guard let idRaw = dict["id"],
                              let title = dict["title"] as? String,
                              let videoUrl = dict["video_url"] as? String else { return nil }
                        
                        let id: Int
                        if let intVal = idRaw as? Int {
                            id = intVal
                        } else if let strVal = idRaw as? String, let intParsed = Int(strVal) {
                            id = intParsed
                        } else {
                            return nil
                        }
                        
                        let videoType = dict["video_type"] as? String ?? "external"
                        let fileSize = dict["file_size"] as? Int
                        let uploadDate = dict["upload_date"] as? String
                        
                        return VideoItem(id: id, title: title, video_url: videoUrl, video_type: videoType, file_size: fileSize, upload_date: uploadDate)
                    }
                    
                    DispatchQueue.main.async {
                        self.videos = fetchedVideos
                    }
                }
            } catch {
                print("Error parsing videos: \(error)")
            }
        }.resume()
    }
    
    private func deleteVideo(id: Int) {
        guard let url = APIConfig.getURL(for: "upload_video.php") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "action=delete&video_id=\(id)".data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Delete failed:", error)
                return
            }
            DispatchQueue.main.async {
                withAnimation(.spring()) {
                    self.videos.removeAll { $0.id == id }
                }
            }
        }.resume()
    }
    
    private func getYouTubeId(from urlStr: String) -> String? {
        guard urlStr.contains("youtube.com") || urlStr.contains("youtu.be") else { return nil }
        if let url = URL(string: urlStr) {
            if let v = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?.first(where: { $0.name == "v" })?.value { return v }
            return url.pathComponents.last
        }
        return nil
    }
    
    private func formatFileSize(_ bytes: Int?) -> String {
        guard let bytes = bytes else { return "" }
        if bytes < 1024 * 1024 { return "\(String(format: "%.1f", Double(bytes) / 1024.0)) KB" }
        return "\(String(format: "%.1f", Double(bytes) / (1024.0 * 1024.0))) MB"
    }

    var body: some View {
        ZStack {
            Color.btBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Top Nav Bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.btTextPrimary)
                            .frame(width: 40, height: 40)
                            .background(Color.btSurface)
                            .clipShape(Circle())
                            .btCardShadow()
                    }
                    
                    Spacer()
                    
                    Text("Manage Videos")
                        .font(.btHeadline)
                        .foregroundColor(.btTextPrimary)
                    
                    Spacer()
                    
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.sm)
                .background(Color.btBackground)
                
                // MARK: - Video Library Overview Card
                headerCard
                
                // MARK: - Scrollable Card List
                if isLoading {
                    Spacer()
                    ProgressView("Analyzing resources...")
                        .tint(.btDoctorPrimary)
                    Spacer()
                } else if videos.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.btDoctorPrimary.opacity(0.08))
                                .frame(width: 80, height: 80)
                            Image(systemName: "video.slash.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.btDoctorPrimary)
                        }
                        Text("No Videos Published Yet")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.btTextPrimary)
                        Text("Post learning guides or upload exercise clips\nto make them available to your patients.")
                            .font(.system(size: 13))
                            .foregroundColor(.btTextSecond)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            ForEach(videos) { video in
                                videoCard(for: video)
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $navigateToVideosUploading) {
            VideosUploading()
                .presentationBackground(.clear)
        }
        .onChange(of: navigateToVideosUploading) { _, newValue in
            if !newValue {
                fetchVideos()
            }
        }
        .sheet(isPresented: $showSafari) {
            if let url = activeURL {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
        .onAppear {
            fetchVideos()
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }
    
    // MARK: - Header Overview Card
    private var headerCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                // Header Icon
                ZStack {
                    Circle()
                        .fill(Color.btDoctorPrimary.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.btDoctorPrimary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Video Library")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.btTextPrimary)
                    Text("Share instructional content with your patients")
                        .font(.system(size: 12))
                        .foregroundColor(.btTextSecond)
                }
                Spacer()
            }
            
            HStack {
                // Stats Counter
                HStack(spacing: 6) {
                    Text("\(videos.count)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.btDoctorPrimary)
                    Text("VIDEOS")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.btTextSecond)
                        .tracking(0.5)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.btBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Spacer()
                
                // Add New button
                Button(action: {
                    navigateToVideosUploading = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .bold))
                        Text("Post New Video")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(LinearGradient.btDoctorGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: Color.btDoctorPrimary.opacity(0.3), radius: 6, x: 0, y: 3)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .background(Color.btSurface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
    }

    // MARK: - Individual Video Card
    private func videoCard(for video: VideoItem) -> some View {
        let isYT = video.video_type == "youtube"
        let ytID = isYT ? getYouTubeId(from: video.video_url) : nil
        
        return VStack(alignment: .leading, spacing: 0) {
            // Thumbnail / Play Preview Box
            ZStack {
                if isYT, let ytID = ytID {
                    AsyncImage(url: URL(string: "https://img.youtube.com/vi/\(ytID)/mqdefault.jpg")) { phase in
                        if let img = phase.image {
                            img.resizable().scaledToFill()
                        } else {
                            Color.btBackground
                        }
                    }
                } else {
                    // Local placeholder layout
                    LinearGradient(gradient: Gradient(colors: [Color.btDoctorPrimary.opacity(0.8), Color.btPrimary.opacity(1.0)]),
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "film")
                                .font(.system(size: 32))
                                .foregroundColor(.white.opacity(0.7))
                            Text("Local Video File")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    )
                }
                
                // play circle overlay
                Button(action: {
                    if let url = URL(string: video.video_url) {
                        activeURL = url; showSafari = true
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.9))
                            .frame(width: 44, height: 44)
                            .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
                        Image(systemName: "play.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.btDoctorPrimary)
                            .offset(x: 1.5)
                    }
                }
                .buttonStyle(.plain)
            }
            .frame(height: 160)
            .clipped()
            
            // Details Area
            VStack(alignment: .leading, spacing: 12) {
                Text(video.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.btTextPrimary)
                    .lineLimit(1)
                
                // Badges
                HStack(spacing: 8) {
                    // Public badge
                    HStack(spacing: 4) {
                        Image(systemName: "globe")
                            .font(.system(size: 10, weight: .bold))
                        Text("PUBLIC")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(Color(red: 0.20, green: 0.78, blue: 0.54))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(red: 0.20, green: 0.78, blue: 0.54).opacity(0.12))
                    .clipShape(Capsule())
                    
                    // Video Type badge
                    if isYT {
                        HStack(spacing: 4) {
                            Image(systemName: "link")
                                .font(.system(size: 10, weight: .bold))
                            Text("YOUTUBE")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(Color(red: 0.99, green: 0.45, blue: 0.45))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(red: 0.99, green: 0.45, blue: 0.45).opacity(0.12))
                        .clipShape(Capsule())
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "harddrive.fill")
                                .font(.system(size: 10, weight: .bold))
                            Text("LOCAL")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(.btDoctorPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.btDoctorPrimary.opacity(0.12))
                        .clipShape(Capsule())
                    }
                    
                    if let size = video.file_size, size > 0 {
                        Text(formatFileSize(size))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.btTextSecond)
                    }
                }
                
                // Action Buttons
                HStack(spacing: 10) {
                    Button(action: {
                        if let url = URL(string: video.video_url) {
                            activeURL = url; showSafari = true
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.up.right.square")
                                .font(.system(size: 13, weight: .bold))
                            Text("Open Video")
                                .font(.system(size: 13, weight: .bold))
                        }
                        .foregroundColor(.btDoctorPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(Color.btDoctorPrimary.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        deleteVideo(id: video.id)
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.red.opacity(0.08))
                                .frame(width: 42, height: 42)
                            Image(systemName: "trash.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
        .background(Color.btSurface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }
}

// MARK: - Safari Wrapper
private struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        let vc = SFSafariViewController(url: url, configuration: config)
        vc.preferredBarTintColor = UIColor.systemBackground
        vc.preferredControlTintColor = UIColor.label
        return vc
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) { }
}

#Preview {
    UploadVideos()
}
