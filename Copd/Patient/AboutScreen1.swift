import SwiftUI

struct AboutScreen1: View {
    @EnvironmentObject var session: PatientSession
    @State private var breatheExpanded = true
    @State private var textVisible = true
    @State private var buttonVisible = true
    @State private var particleAnimating = true

    var body: some View {
        ZStack {
            // ── Animated gradient background ──────────────────────
            AnimatedGradientBackground()

            // ── Floating particles ────────────────────────────────
            ForEach(0..<5, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(0.06))
                    .frame(width: CGFloat([60, 80, 45, 100, 55][i]),
                           height: CGFloat([60, 80, 45, 100, 55][i]))
                    .offset(x: CGFloat([-120, 100, -80, 130, -60][i]), y: CGFloat([-300, -200, 0, 180, 280][i]))
            }

            VStack(spacing: 0) {
                Spacer(minLength: 40)

                // ── Animated Lung Icon ─────────────────────────────
                ZStack {
                    // Pulse rings
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .stroke(Color.white.opacity(0.15 - Double(i) * 0.04), lineWidth: 1.5)
                            .frame(
                                width: 130 + CGFloat(i * 35),
                                height: 130 + CGFloat(i * 35)
                            )
                    }

                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 140, height: 140)
                        .overlay(
                            Image(systemName: "lungs.fill")
                                .font(.system(size: 60, weight: .regular))
                                .foregroundColor(.white)
                        )
                }
                .padding(.bottom, Spacing.xl)

                // ── App name ──────────────────────────────────────
                VStack(spacing: Spacing.sm) {
                    Text("BreathTrack")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(textVisible ? 1 : 0)
                        .offset(y: textVisible ? 0 : 16)

                    Text("COPD Management & Monitoring")
                        .font(.btBodyMedium)
                        .foregroundColor(.white.opacity(0.78))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .opacity(textVisible ? 1 : 0)
                        .offset(y: textVisible ? 0 : 10)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.15), value: textVisible)

                    Spacer().frame(height: Spacing.lg)

                    // ── Feature pills ──────────────────────────────
                    HStack(spacing: Spacing.sm) {
                        FeaturePill(icon: "chart.line.uptrend.xyaxis", label: "Track")
                        FeaturePill(icon: "calendar.badge.clock", label: "Appointments")
                        FeaturePill(icon: "bell.fill", label: "Reminders")
                    }
                    .opacity(textVisible ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: textVisible)
                }
                .animation(.spring(response: 0.7, dampingFraction: 0.8), value: textVisible)

                Spacer(minLength: 40)

                // ── Description card ──────────────────────────────
                VStack(spacing: Spacing.xl) {
                    Text("Bridges patients and healthcare professionals,\nmonitoring compliance and treatment in COPD.")
                        .font(.btBody)
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, Spacing.md)

                    // Get Started Button
                    Button(action: {
                        withAnimation(.spring()) { session.hasSeenIntro = true }
                    }) {
                        HStack(spacing: Spacing.sm) {
                            Text("Get Started")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.btPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: Color.black.opacity(0.15), radius: 20, y: 8)
                    }
                    .buttonStyle(.plain)
                    .opacity(buttonVisible ? 1 : 0)
                    .offset(y: buttonVisible ? 0 : 20)
                    .padding(.horizontal, Spacing.lg + Spacing.xs)
                }
                .padding(.bottom, 50)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Static view, animations removed.
        }
    }
}

// MARK: - Sub-views

private struct AnimatedGradientBackground: View {
    @State private var animating = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.btPrimaryDark, Color.btPrimary, Color.btPrimaryLight],
                startPoint: animating ? .topLeading : .bottomTrailing,
                endPoint: animating ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animating)

            // Bottom overlay
            LinearGradient(
                colors: [Color.black.opacity(0.2), Color.clear],
                startPoint: .bottom, endPoint: .center
            ).ignoresSafeArea()
        }
        .onAppear { animating = true }
    }
}

private struct FeaturePill: View {
    let icon: String
    let label: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
            Text(label)
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(Color.white.opacity(0.15))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1))
    }
}

#Preview {
    AboutScreen1()
        .environmentObject(PatientSession())
}
