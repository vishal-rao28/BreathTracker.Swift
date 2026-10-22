import SwiftUI
import SafariServices

struct VideosView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var activeURL: URL? = nil
    @State private var showSafari = false
    @State private var items: [VideoLink] = []
    @State private var appeared = false
    @State private var isLoading = true

    private func fetchVideos() {
        guard let url = APIConfig.getURL(for: "upload_video.php") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async { self.isLoading = false }
            guard let data = data else { return }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let videos = json["videos"] as? [[String: Any]] {
                    
                    let fetchedItems = videos.compactMap { dict -> VideoLink? in
                        guard let title = dict["title"] as? String,
                              let urlString = dict["video_url"] as? String,
                              let url = URL(string: urlString) else { return nil }
                        
                        let videoType = dict["video_type"] as? String ?? "external"
                        if videoType == "youtube" {
                            return .youtube(title: title, url: url)
                        } else {
                            return .external(title: title, url: url)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.items = fetchedItems
                    }
                }
            } catch {
                print("Error fetching videos: \(error)")
            }
        }.resume()
    }

    var body: some View {
        ZStack {
            Color.btBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
                HStack {
                    BTBackButton(action: { dismiss() })
                    Spacer()
                    Text("Educational Resources")
                        .font(.btHeadline)
                        .foregroundColor(.btTextPrimary)
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.sm)
                .background(Color.btBackground)
                
                if isLoading {
                    Spacer()
                    ProgressView().scaleEffect(1.5).tint(.btPrimary)
                    Spacer()
                } else if items.isEmpty {
                    Spacer()
                    VStack(spacing: Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(Color.btPrimary.opacity(0.1))
                                .frame(width: 80, height: 80)
                            Image(systemName: "video.slash")
                                .font(.system(size: 30))
                                .foregroundColor(.btPrimary.opacity(0.6))
                        }
                        Text("No Videos Available")
                            .font(.btHeadline)
                            .foregroundColor(.btTextSecond)
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            
                            // Intro
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text("Suggested Material")
                                    .font(.btTitle2)
                                    .foregroundColor(.btTextPrimary)
                                Text("Handpicked resources for your respiratory care.")
                                    .font(.btBodyMedium)
                                    .foregroundColor(.btTextSecond)
                            }
                            .padding(.top, Spacing.sm)
                            .padding(.horizontal, Spacing.lg)
                            .padding(.bottom, Spacing.sm)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 10)
                            
                            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                                PatientVideoCard(item: item, delay: Double(index) * 0.05) {
                                    open(item)
                                }
                            }
                        }
                        .padding(.top, Spacing.xs)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            fetchVideos()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
        }
        .sheet(isPresented: $showSafari) {
            if let url = activeURL {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
    }

    private func open(_ item: VideoLink) {
        activeURL = item.url
        showSafari = true
    }
}

// MARK: - Patient Video Card

private struct PatientVideoCard: View {
    let item: VideoLink
    let delay: Double
    let action: () -> Void
    
    @State private var appeared = false
    @State private var pressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LinearGradient.btPrimaryGradient)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "play.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .bold))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .font(.btHeadline)
                        .foregroundColor(.btTextPrimary)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "link.circle.fill")
                            .font(.system(size: 14))
                        Text(item.kind == .youtube ? "YouTube" : "External")
                            .font(.btCaption2)
                    }
                    .foregroundColor(.btPrimary)
                }
                Spacer()
            }
            .padding(Spacing.md)
            .background(Color.btSurface)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .btCardShadow()
            .scaleEffect(pressed ? 0.96 : (appeared ? 1.0 : 0.9))
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, Spacing.lg)
        .simultaneousGesture(DragGesture(minimumDistance: 0)
            .onChanged { _ in withAnimation(.easeInOut(duration: 0.1)) { pressed = true } }
            .onEnded   { _ in withAnimation(.spring()) { pressed = false } }
        )
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay)) {
                appeared = true
            }
        }
    }
}


// MARK: - Model

private struct VideoLink: Identifiable {
    enum Kind { case youtube, external }
    let id = UUID()
    let title: String
    let url: URL
    let kind: Kind

    static func youtube(title: String, url: URL) -> VideoLink {
        VideoLink(title: title, url: url, kind: .youtube)
    }
    static func external(title: String, url: URL) -> VideoLink {
        VideoLink(title: title, url: url, kind: .external)
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
    NavigationStack {
        VideosView()
    }
}
