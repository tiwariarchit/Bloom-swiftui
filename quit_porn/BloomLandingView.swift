import SwiftUI
import UIKit

struct BloomLandingView: View {
    @Binding var hasSeenLanding: Bool
    @State private var animateHero = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.20, green: 0.73, blue: 0.71),
                    Color(red: 0.08, green: 0.42, blue: 0.58)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer(minLength: 40)

                Image("BloomLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 170, height: 170)
                    .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
                    .shadow(color: .black.opacity(0.22), radius: 16, x: 0, y: 10)
                    .scaleEffect(animateHero ? 1 : 0.92)
                    .animation(.spring(response: 0.5, dampingFraction: 0.72), value: animateHero)

                VStack(spacing: 10) {
                    Text("Bloom")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Break the urge loop with fast, practical calm tools.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.94))
                        .font(.body.weight(.medium))
                        .padding(.horizontal, 20)
                }

                VStack(alignment: .leading, spacing: 14) {
                    landingBullet(icon: "leaf.fill", text: "Guided calm mode when urges spike")
                    landingBullet(icon: "figure.run", text: "Movement-based reset challenges")
                    landingBullet(icon: "chart.line.uptrend.xyaxis", text: "Streak and consistency tracking")
                }
                .padding(18)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .padding(.horizontal, 20)

                Spacer()

                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    hasSeenLanding = true
                } label: {
                    Text("Start Bloom")
                        .font(.headline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 54)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 16))
                .controlSize(.large)
                .tint(.white)
                .foregroundStyle(Color(red: 0.05, green: 0.35, blue: 0.39))
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            animateHero = true
        }
    }

    private func landingBullet(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color(red: 0.06, green: 0.40, blue: 0.44))
                .frame(width: 22)
            Text(text)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
            Spacer()
        }
    }
}
