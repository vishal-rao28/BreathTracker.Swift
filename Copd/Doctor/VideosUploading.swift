import SwiftUI
import PhotosUI

struct VideosUploading: View {
    @Environment(\.dismiss) private var dismiss

    enum UploadMode: CaseIterable { case youtube, local }

    @State private var mode: UploadMode = .youtube
    @State private var title = ""
    @State private var youtubeURL = ""
    @State private var selectedVideo: PhotosPickerItem?
    @State private var selectedVideoData: Data?
    @State private var selectedVideoName = ""
    @State private var isUploading = false
    @State private var uploadDone = false
    @State private var uploadProgress: Double = 0
    @State private var errorMessage = ""
    @State private var appeared = false

    // MARK: - Body
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(0.25))
                .ignoresSafeArea()
                .onTapGesture { if !isUploading { dismiss() } }

            VStack {
                Spacer()
                modalCard
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { appeared = true }
        }
    }

    // MARK: - Modal Card
    private var modalCard: some View {
        VStack(spacing: 0) {
            // Top gradient accent bar
            LinearGradient.btDoctorGradient
                .frame(height: 5)

            VStack(spacing: 24) {
                header
                modeTabs
                Divider().opacity(0.3)

                if uploadDone {
                    successView
                } else {
                    formContent
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
            }
            .padding(24)
        }
        .background(Color.btSurface)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.12), radius: 30, x: 0, y: 15)
        .scaleEffect(appeared ? 1 : 0.94)
        .opacity(appeared ? 1 : 0)
    }

    // MARK: - Header
    private var header: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(LinearGradient.btDoctorGradient)
                    .frame(width: 48, height: 48)
                    .shadow(color: Color.btDoctorPrimary.opacity(0.3), radius: 6, x: 0, y: 3)
                Image(systemName: "icloud.and.arrow.up.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Upload Video")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.btTextPrimary)
                Text("Share educational content with patients")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.btTextSecond)
            }

            Spacer()

            Button(action: { if !isUploading { dismiss() } }) {
                ZStack {
                    Circle()
                        .fill(Color.btBackground)
                        .frame(width: 32, height: 32)
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.btTextSecond)
                }
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Mode Tabs (Pill style)
    private var modeTabs: some View {
        HStack(spacing: 0) {
            ForEach(UploadMode.allCases, id: \.self) { tab in
                let isActive = mode == tab
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        mode = tab
                        resetFields()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: tab == .youtube ? "video.badge.plus" : "folder.badge.plus")
                            .font(.system(size: 14, weight: .bold))
                        Text(tab == .youtube ? "Link YouTube" : "Local Video")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(isActive ? .white : .btTextSecond)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(
                        Group {
                            if isActive {
                                LinearGradient.btDoctorGradient
                            } else {
                                Color.clear
                            }
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color.btBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.btBorder.opacity(0.6), lineWidth: 1))
    }

    // MARK: - Form Content Switch
    @ViewBuilder
    private var formContent: some View {
        switch mode {
        case .youtube:
            youtubeForm
        case .local:
            localForm
        }
    }

    // MARK: - YouTube Form
    private var youtubeForm: some View {
        VStack(spacing: 18) {
            iconInputField(
                label: "Video Title",
                placeholder: "e.g. Inhaler Usage Guide",
                icon: "square.and.pencil",
                text: $title
            )
            iconInputField(
                label: "YouTube URL",
                placeholder: "https://youtube.com/watch?v=...",
                icon: "link",
                text: $youtubeURL,
                keyboardType: .URL
            )

            // Live thumbnail preview
            if !youtubeURL.isEmpty, let ytID = extractYouTubeID(from: youtubeURL) {
                thumbnailPreview(ytID: ytID)
            }

            errorLabel
            actionButtons(
                submitLabel: "Publish",
                submitIcon: "checkmark.circle.fill",
                onSubmit: uploadYoutube
            )
        }
    }

    // MARK: - Local Form
    private var localForm: some View {
        VStack(spacing: 18) {
            iconInputField(
                label: "Video Title",
                placeholder: "e.g. Breathing Exercise Demo",
                icon: "square.and.pencil",
                text: $title
            )

            dropZone

            if isUploading { progressBar }

            errorLabel
            actionButtons(
                submitLabel: "Upload Video",
                submitIcon: "icloud.and.arrow.up.fill",
                onSubmit: uploadLocal,
                disabled: selectedVideoData == nil
            )
        }
    }

    // MARK: - Icon Input Field
    private func iconInputField(
        label: String,
        placeholder: String,
        icon: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.btTextSecond)
                .tracking(0.8)

            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(text.wrappedValue.isEmpty ? .btTextSecond : .btDoctorPrimary)
                    .frame(width: 20)
                    .animation(.easeInOut(duration: 0.2), value: text.wrappedValue.isEmpty)

                TextField(placeholder, text: text)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.btTextPrimary)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(Color.btBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(
                        text.wrappedValue.isEmpty ? Color.btBorder : Color.btDoctorPrimary.opacity(0.6),
                        lineWidth: 1.2
                    )
                    .animation(.easeInOut(duration: 0.2), value: text.wrappedValue.isEmpty)
            )
        }
    }

    // MARK: - Thumbnail Preview
    private func thumbnailPreview(ytID: String) -> some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: "https://img.youtube.com/vi/\(ytID)/mqdefault.jpg")) { phase in
                if let img = phase.image {
                    img.resizable().scaledToFill()
                } else {
                    Color.btBackground
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 125)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.btBorder, lineWidth: 1)
            )

            HStack(spacing: 5) {
                Image(systemName: "play.fill")
                    .font(.system(size: 8, weight: .bold))
                Text("YouTube Video Preview")
                    .font(.system(size: 10, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.btDoctorPrimary)
            .clipShape(Capsule())
            .padding(10)
        }
        .transition(.scale(scale: 0.95).combined(with: .opacity))
    }

    // MARK: - Drop Zone
    private var dropZone: some View {
        PhotosPicker(selection: $selectedVideo, matching: .videos) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(selectedVideoData != nil
                          ? Color.btDoctorPrimary.opacity(0.04)
                          : Color.btBackground)
                
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        selectedVideoData != nil ? Color.btDoctorPrimary.opacity(0.4) : Color.btBorder,
                        style: StrokeStyle(lineWidth: 1.5, dash: selectedVideoData != nil ? [] : [5, 4])
                    )

                if selectedVideoData != nil {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.btDoctorPrimary.opacity(0.12))
                                .frame(width: 44, height: 44)
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(LinearGradient.btDoctorGradient)
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Video Selected")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.btDoctorPrimary)
                            Text(selectedVideoName.isEmpty ? "Tap to change file" : selectedVideoName)
                                .font(.system(size: 12))
                                .foregroundColor(.btTextSecond)
                                .lineLimit(1)
                        }
                        Spacer()
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.btDoctorPrimary.opacity(0.5))
                    }
                    .padding(.horizontal, 16)
                } else {
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.btDoctorPrimary.opacity(0.08))
                                .frame(width: 52, height: 52)
                            Image(systemName: "video.badge.plus.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(LinearGradient.btDoctorGradient)
                        }
                        VStack(spacing: 4) {
                            Text("Select Video File")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.btTextPrimary)
                            Text("MP4, MOV  ·  Max 300MB")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.btTextSecond)
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
            .frame(height: 130)
        }
        .onChange(of: selectedVideo) { _, _ in loadSelectedVideo() }
    }

    // MARK: - Progress Bar
    private var progressBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Uploading…")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.btTextSecond)
                Spacer()
                Text("\(Int(uploadProgress * 100))%")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(LinearGradient.btDoctorGradient)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.btDoctorPrimary.opacity(0.12)).frame(height: 6)
                    Capsule()
                        .fill(LinearGradient.btDoctorGradient)
                        .frame(width: geo.size.width * uploadProgress, height: 6)
                        .animation(.linear(duration: 0.15), value: uploadProgress)
                }
            }
            .frame(height: 6)
        }
    }

    // MARK: - Error Label
    @ViewBuilder
    private var errorLabel: some View {
        if !errorMessage.isEmpty {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 13))
                Text(errorMessage)
                    .font(.system(size: 13))
            }
            .foregroundColor(.red)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.red.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    // MARK: - Action Buttons
    private func actionButtons(
        submitLabel: String,
        submitIcon: String,
        onSubmit: @escaping () -> Void,
        disabled: Bool = false
    ) -> some View {
        HStack(spacing: 12) {
            Button(action: { if !isUploading { dismiss() } }) {
                Text("Cancel")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.btTextSecond)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.btBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)

            Button(action: onSubmit) {
                HStack(spacing: 7) {
                    if isUploading {
                        ProgressView().tint(.white).scaleEffect(0.85)
                        Text("Publishing…")
                            .font(.system(size: 15, weight: .bold))
                    } else {
                        Image(systemName: submitIcon)
                            .font(.system(size: 15, weight: .bold))
                        Text(submitLabel)
                            .font(.system(size: 15, weight: .bold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    Group {
                        if disabled || isUploading {
                            AnyView(Color.btTextTertiary.opacity(0.3))
                        } else {
                            AnyView(LinearGradient.btDoctorGradient)
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: disabled || isUploading ? .clear : Color.btDoctorPrimary.opacity(0.25),
                        radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)
            .disabled(disabled || isUploading)
        }
    }

    // MARK: - Success View
    private var successView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.btDoctorPrimary.opacity(0.1))
                    .frame(width: 80, height: 80)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(LinearGradient.btDoctorGradient)
            }
            .scaleEffect(uploadDone ? 1 : 0.5)
            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: uploadDone)

            VStack(spacing: 6) {
                Text("Video Published!")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.btTextPrimary)
                Text("It will now appear in the patient's\nEducational Resources library.")
                    .font(.system(size: 13))
                    .foregroundColor(.btTextSecond)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    // MARK: - Helpers
    private func resetFields() {
        title = ""; youtubeURL = ""; errorMessage = ""
        selectedVideo = nil; selectedVideoData = nil; selectedVideoName = ""
        uploadProgress = 0
    }

    private func extractYouTubeID(from urlStr: String) -> String? {
        guard urlStr.contains("youtube.com") || urlStr.contains("youtu.be") else { return nil }
        if let url = URL(string: urlStr) {
            if let v = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?.first(where: { $0.name == "v" })?.value { return v }
            return url.pathComponents.last
        }
        return nil
    }

    private func loadSelectedVideo() {
        guard let item = selectedVideo else { return }
        selectedVideoName = "Loading…"
        item.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    selectedVideoData = data
                    selectedVideoName = "Video selected (\(data.map { ByteCountFormatter.string(fromByteCount: Int64($0.count), countStyle: .file) } ?? ""))"
                case .failure:
                    errorMessage = "Failed to load selected video."
                    selectedVideoName = ""
                }
            }
        }
    }

    // MARK: - Upload YouTube
    private func uploadYoutube() {
        guard !title.isEmpty else { withAnimation { errorMessage = "Please enter a video title." }; return }
        guard !youtubeURL.isEmpty else { withAnimation { errorMessage = "Please enter a YouTube URL." }; return }
        guard youtubeURL.contains("youtube.com") || youtubeURL.contains("youtu.be") else {
            withAnimation { errorMessage = "Invalid YouTube URL." }; return
        }
        errorMessage = ""; isUploading = true

        guard let url = APIConfig.getURL(for: "upload_video.php") else {
            isUploading = false; errorMessage = "Server error."; return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let body = "action=add_url&video_url=\(youtubeURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&title=\(title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                isUploading = false
                guard error == nil,
                      let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      json["status"] as? String == "success"
                else { withAnimation { errorMessage = "Upload failed. Check the URL and try again." }; return }
                withAnimation(.spring()) { uploadDone = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { dismiss() }
            }
        }.resume()
    }

    // MARK: - Upload Local Video
    private func uploadLocal() {
        guard !title.isEmpty else { withAnimation { errorMessage = "Please enter a video title." }; return }
        guard let videoData = selectedVideoData else { withAnimation { errorMessage = "Please select a video file." }; return }
        errorMessage = ""; isUploading = true; uploadProgress = 0.05

        guard let url = APIConfig.getURL(for: "upload_video.php") else {
            isUploading = false; errorMessage = "Server error."; return
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        func field(_ name: String, _ value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        field("action", "upload"); field("title", title)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"video\"; filename=\"video.mp4\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: video/mp4\r\n\r\n".data(using: .utf8)!)
        body.append(videoData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        // Animate progress
        let timer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { t in
            DispatchQueue.main.async {
                if uploadProgress < 0.85 { uploadProgress += 0.12 }
                else { t.invalidate() }
            }
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            timer.invalidate()
            DispatchQueue.main.async {
                uploadProgress = 1.0; isUploading = false
                guard error == nil,
                      let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      json["status"] as? String == "success"
                else { withAnimation { errorMessage = "Upload failed. Please try again." }; return }
                withAnimation(.spring()) { uploadDone = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { dismiss() }
            }
        }.resume()
    }
}

// MARK: - Rounded specific corners
struct RoundedCornerShape: Shape {
    var corners: UIRectCorner
    var radius: CGFloat
    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath(roundedRect: rect,
                          byRoundingCorners: corners,
                          cornerRadii: CGSize(width: radius, height: radius)).cgPath)
    }
}

#Preview {
    ZStack {
        Color.btBackground.ignoresSafeArea()
        VideosUploading()
    }
}
