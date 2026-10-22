import SwiftUI

// MARK: - Shared Questionnaire Components (Redesigned)

// ─────────────────────────────────────────────
// MARK: Questionnaire Header with Progress
// ─────────────────────────────────────────────
struct QuestionnaireHeader: View {
    let title:    String
    let progress: Double   // 0.0 → 1.0
    let onBack:   () -> Void

    var body: some View {
        VStack(spacing: Spacing.sm) {
            HStack {
                // Modern back button
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.btTextPrimary)
                        .frame(width: 40, height: 40)
                        .background(Color.btSurface)
                        .clipShape(Circle())
                        .btCardShadow()
                }

                Spacer()

                Text(title)
                    .font(.btHeadline)
                    .foregroundColor(.btTextPrimary)

                Spacer()

                // Progress badge
                Text("\(Int(progress * 100))%")
                    .font(.btCaption2)
                    .foregroundColor(.btPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.btPrimary.opacity(0.1))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, Spacing.md)

            // Animated progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.btBorder)
                        .frame(height: 6)

                    // Fill
                    RoundedRectangle(cornerRadius: 6)
                        .fill(LinearGradient.btPrimaryGradient)
                        .frame(width: max(0, geo.size.width * progress), height: 6)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
                }
            }
            .frame(height: 6)
            .padding(.horizontal, Spacing.md)
        }
        .padding(.vertical, Spacing.md)
        .background(Color.btBackground)
    }
}

// ─────────────────────────────────────────────
// MARK: Modern Question Card
// ─────────────────────────────────────────────
struct ModernQuestionCard: View {
    let number:  Int
    let titleEN: String
    let titleTA: String
    let footerEN: String
    let footerTA: String
    let selected: Int?
    let onSelect: (Int) -> Void

    var body: some View {
        VStack(spacing: Spacing.lg) {

            // ── Question label ───────────────────────────────────
            HStack(alignment: .top, spacing: Spacing.md) {
                // Number badge
                Text("\(number)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 30, height: 30)
                    .background(LinearGradient.btPrimaryGradient)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 6) {
                    Text(titleEN)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.btTextPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(titleTA)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.btTextSecond)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // ── Likert Scale ─────────────────────────────────────
            VStack(spacing: Spacing.sm) {
                // Scale labels
                HStack {
                    Label("Better", systemImage: "arrow.up.circle.fill")
                        .font(.btCaption2)
                        .foregroundColor(.btAccentGreen)
                    Spacer()
                    Label("Moderate", systemImage: "equal.circle.fill")
                        .font(.btCaption2)
                        .foregroundColor(.btAccentOrange)
                    Spacer()
                    Label("Severe", systemImage: "arrow.down.circle.fill")
                        .font(.btCaption2)
                        .foregroundColor(.btAccent)
                }
                .padding(.horizontal, Spacing.xs)

                ModernLikertScale(selected: selected, onSelect: onSelect)
            }

            // ── Description footer ───────────────────────────────
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.btPrimary)
                    Text("Description")
                        .font(.btCaption2)
                        .foregroundColor(.btTextSecond)
                }
                Text(footerEN)
                    .font(.btCaption)
                    .foregroundColor(.btTextPrimary)
                Text(footerTA)
                    .font(.btCaption)
                    .italic()
                    .foregroundColor(.btTextSecond)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.md)
            .background(Color.btSurface2)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(Spacing.lg)
        .background(Color.btSurface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .btCardShadow()
    }
}

// ─────────────────────────────────────────────
// MARK: Likert Scale
// ─────────────────────────────────────────────
struct ModernLikertScale: View {
    let selected: Int?
    let onSelect: (Int) -> Void

    private let trackColors: [Color] = [
        Color.btAccentGreen,
        Color(hex: "5BB89A"),
        Color.btAccentOrange.opacity(0.8),
        Color.btAccentOrange,
        Color(hex: "FF7F5A"),
        Color.btAccent
    ]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<6) { value in
                let isSelected = selected == value
                let col = trackColors[value]

                Button { onSelect(value) } label: {
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(isSelected ? col : col.opacity(0.15))
                                .frame(width: isSelected ? 48 : 42,
                                       height: isSelected ? 48 : 42)

                            if isSelected {
                                Circle()
                                    .stroke(col, lineWidth: 3)
                                    .frame(width: 54, height: 54)
                                    .scaleEffect(isSelected ? 1 : 0.7)
                                    .opacity(isSelected ? 1 : 0)
                            }

                            Text("\(value)")
                                .font(.system(size: isSelected ? 17 : 15, weight: .bold))
                                .foregroundColor(isSelected ? .white : col)
                        }
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// ─────────────────────────────────────────────
// MARK: Questionnaire Submit Button
// ─────────────────────────────────────────────
struct QuestionnaireSubmitButton: View {
    let label:     String
    let isLoading: Bool
    let action:    () -> Void

    var body: some View {
        BTPrimaryButton(title: label, icon: isLoading ? nil : "checkmark.circle.fill", isLoading: isLoading, action: action)
    }
}

// ─────────────────────────────────────────────
// MARK: Color(hex:) extension
// (kept in this file for backward compatibility)
// ─────────────────────────────────────────────
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:(a, r, g, b) = (255, 255, 255, 255)
        }
        self.init(.sRGB,
                  red:     Double(r) / 255,
                  green:   Double(g) / 255,
                  blue:    Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}
