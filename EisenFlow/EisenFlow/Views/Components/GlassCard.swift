import SwiftUI

/// A reusable glassmorphism card component
struct GlassCard<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat = 16
    var padding: CGFloat = 12

    init(
        cornerRadius: CGFloat = 16,
        padding: CGFloat = 12,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                ZStack {
                    // Base glass effect
                    SuperellipseShape(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)

                    // Subtle white overlay for depth
                    SuperellipseShape(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .clipShape(SuperellipseShape(cornerRadius: cornerRadius))
            .overlay(
                // Border gradient for glass edge effect
                SuperellipseShape(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.5),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

/// Preview
#Preview {
    ZStack {
        LinearGradient(
            colors: [.purple, .blue, .cyan],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Glass Card")
                    .font(.headline)
                Text("This is a glassmorphism card component with a subtle blur effect.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 250)
        }
    }
}
