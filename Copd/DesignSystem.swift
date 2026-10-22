import SwiftUI

// MARK: - BreathTrack Design System 2026

// ─────────────────────────────────────────────
// MARK: Color Palette
// ─────────────────────────────────────────────
extension Color {
    // Primary brand — deep medical teal-blue
    static let btPrimary      = Color(hex: "1A6B8A")   // main teal
    static let btPrimaryLight = Color(hex: "2E9BBF")   // lighter shade
    static let btPrimaryDark  = Color(hex: "0F4A62")   // deeper shade

    // Accent
    static let btAccent       = Color(hex: "FF6B6B")   // soft coral
    static let btAccentGreen  = Color(hex: "34C98A")   // success green
    static let btAccentOrange = Color(hex: "FF9B42")   // warm orange
    static let btAccentPurple = Color(hex: "7B6CF6")   // muted violet

    // Neutrals
    static let btBackground   = Color(hex: "F4F8FB")   // light blue-grey bg
    static let btSurface      = Color(hex: "FFFFFF")   // card surface
    static let btSurface2     = Color(hex: "EFF4F8")   // secondary surface
    static let btBorder       = Color(hex: "DDE8F0")   // subtle border

    // Text
    static let btTextPrimary  = Color(hex: "18243A")   // dark navy
    static let btTextSecond   = Color(hex: "5F7385")   // mid grey-blue
    static let btTextTertiary = Color(hex: "9BAEBE")   // light placeholder

    // Doctor purple theme
    static let btDoctorPrimary = Color(hex: "5B4CF5")
    static let btDoctorLight   = Color(hex: "EDE9FF")
}

// ─────────────────────────────────────────────
// MARK: Gradient Presets
// ─────────────────────────────────────────────
extension LinearGradient {
    static let btPrimaryGradient = LinearGradient(
        colors: [Color.btPrimary, Color.btPrimaryLight],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let btDoctorGradient = LinearGradient(
        colors: [Color.btDoctorPrimary, Color(hex: "8B78FF")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let btHeroGradient = LinearGradient(
        colors: [Color.btPrimary, Color.btPrimaryLight, Color(hex: "56CCF2")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let btBackgroundGradient = LinearGradient(
        colors: [Color.btBackground, Color.btSurface],
        startPoint: .top, endPoint: .bottom
    )
}

// ─────────────────────────────────────────────
// MARK: Typography
// ─────────────────────────────────────────────
extension Font {
    static let btLargeTitle  = Font.system(size: 34, weight: .bold, design: .rounded)
    static let btTitle       = Font.system(size: 28, weight: .bold, design: .rounded)
    static let btTitle2      = Font.system(size: 22, weight: .bold, design: .rounded)
    static let btTitle3      = Font.system(size: 20, weight: .bold, design: .rounded)
    static let btHeadline    = Font.system(size: 17, weight: .semibold, design: .default)
    static let btBody        = Font.system(size: 15, weight: .regular, design: .default)
    static let btBodyMedium  = Font.system(size: 15, weight: .medium, design: .default)
    static let btCaption     = Font.system(size: 13, weight: .medium, design: .default)
    static let btCaption2    = Font.system(size: 11, weight: .semibold, design: .default)
    static let btLabel       = Font.system(size: 16, weight: .semibold, design: .default)
}

// ─────────────────────────────────────────────
// MARK: Spacing (8pt grid)
// ─────────────────────────────────────────────
enum Spacing {
    static let xs:  CGFloat = 4
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 16
    static let lg:  CGFloat = 24
    static let xl:  CGFloat = 32
    static let xxl: CGFloat = 48
}

// ─────────────────────────────────────────────
// MARK: Shadow Styles
// ─────────────────────────────────────────────
struct BTShadow: ViewModifier {
    var color: Color = .black.opacity(0.06)
    var radius: CGFloat = 12
    var x: CGFloat = 0
    var y: CGFloat = 6

    func body(content: Content) -> some View {
        content.shadow(color: color, radius: radius, x: x, y: y)
    }
}

extension View {
    func btCardShadow(color: Color = .black.opacity(0.06)) -> some View { modifier(BTShadow(color: color)) }
    func btDeepShadow(color: Color = .black) -> some View {
        modifier(BTShadow(color: color.opacity(0.12), radius: 20, y: 10))
    }
}

// ─────────────────────────────────────────────
// MARK: Reusable Primary Button
// ─────────────────────────────────────────────
struct BTPrimaryButton: View {
    let title: String
    var icon: String? = nil
    var gradient: LinearGradient = .btPrimaryGradient
    var shadowColor: Color? = nil
    var isLoading: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: {
            guard !isDisabled && !isLoading else { return }
            withAnimation(.spring(response: 0.15, dampingFraction: 0.6)) { pressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) { pressed = false }
            }
            action()
        }) {
            HStack(spacing: Spacing.sm) {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    if let icon = icon {
                        Image(systemName: icon).font(.system(size: 18, weight: .semibold))
                    }
                    Text(title).font(.btLabel)
                }
            }
            .foregroundColor(.white.opacity(isDisabled ? 0.6 : 1.0))
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(isDisabled ? Color.btTextTertiary : Color.clear)
            .background(isDisabled ? AnyView(Color.clear) : AnyView(gradient))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .btDeepShadow(color: (isDisabled || isLoading) ? Color.clear : (shadowColor ?? .btPrimary))
            .scaleEffect(pressed && !isDisabled ? 0.97 : 1.0)
            .opacity(isDisabled ? 0.8 : 1.0)
        }
        .disabled(isDisabled || isLoading)
        .buttonStyle(.plain)
    }
}

// ─────────────────────────────────────────────
// MARK: Reusable Input Field
// ─────────────────────────────────────────────
struct BTInputField: View {
    let placeholder: String
    var icon: String
    @Binding var text: String
    var isSecure: Bool = false
    @State private var isVisible = false
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: Spacing.sm + Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(isFocused ? .btPrimary : .btTextSecond)
                .frame(width: 22)
                .animation(.easeInOut(duration: 0.2), value: isFocused)

            Group {
                if isSecure && !isVisible {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .font(.btBodyMedium)
            .foregroundColor(.btTextPrimary)
            .focused($isFocused)

            if isSecure {
                Button(action: { isVisible.toggle() }) {
                    Image(systemName: isVisible ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 15))
                        .foregroundColor(.btTextTertiary)
                }
            }
        }
        .padding(.horizontal, Spacing.md)
        .frame(height: 54)
        .background(Color.btSurface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isFocused ? Color.btPrimary.opacity(0.6) : Color.btBorder, lineWidth: 1.5)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
        )
        .btCardShadow()
    }
}

// ─────────────────────────────────────────────
// MARK: Status Badge
// ─────────────────────────────────────────────
struct BTStatusBadge: View {
    enum Status { case success, error, warning, info }
    let message: String
    let status: Status

    var color: Color {
        switch status {
        case .success: return .btAccentGreen
        case .error:   return .btAccent
        case .warning: return .btAccentOrange
        case .info:    return .btPrimary
        }
    }
    var icon: String {
        switch status {
        case .success: return "checkmark.circle.fill"
        case .error:   return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info:    return "info.circle.fill"
        }
    }

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon).foregroundColor(color)
            Text(message)
                .font(.btCaption)
                .foregroundColor(color)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm + 2)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color.opacity(0.25), lineWidth: 1)
        )
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

// ─────────────────────────────────────────────
// MARK: Back Button
// ─────────────────────────────────────────────
struct BTBackButton: View {
    var tint: Color = .btTextPrimary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(tint)
                .frame(width: 40, height: 40)
                .background(Color.btSurface)
                .clipShape(Circle())
                .btCardShadow()
        }
    }
}

// ─────────────────────────────────────────────
// MARK: Section Header
// ─────────────────────────────────────────────
struct BTSectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var action: (() -> Void)? = nil
    var actionLabel: String = "See All"

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.btTitle2).foregroundColor(.btTextPrimary)
                if let sub = subtitle {
                    Text(sub).font(.btCaption).foregroundColor(.btTextSecond)
                }
            }
            Spacer()
            if let action = action {
                Button(action: action) {
                    Text(actionLabel)
                        .font(.btCaption)
                        .foregroundColor(.btPrimary)
                }
            }
        }
    }
}

// ─────────────────────────────────────────────
// MARK: Pill Tag
// ─────────────────────────────────────────────
struct BTPillTag: View {
    let label: String
    var color: Color = .btPrimary

    var body: some View {
        Text(label)
            .font(.btCaption2)
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}

// ─────────────────────────────────────────────
// MARK: Notification Badge
// ─────────────────────────────────────────────
struct BTNotificationBadge: View {
    let count: Int
    var body: some View {
        Group {
            if count > 0 {
                Text(count > 99 ? "99+" : "\(count)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .frame(minWidth: 18, minHeight: 18)
                    .padding(.horizontal, 3)
                    .background(Color.btAccent)
                    .clipShape(Capsule())
            }
        }
    }
}

// ─────────────────────────────────────────────
// MARK: Skeleton Loader
// ─────────────────────────────────────────────
struct BTSkeletonRow: View {
    @State private var shimmer = false

    var body: some View {
        HStack(spacing: Spacing.md) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.btSurface2)
                .frame(width: 56, height: 56)
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.btSurface2)
                    .frame(height: 14)
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.btSurface2)
                    .frame(width: 120, height: 12)
            }
            Spacer()
        }
        .padding(Spacing.md)
        .background(Color.btSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .opacity(shimmer ? 0.5 : 1.0)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                shimmer = true
            }
        }
    }
}
