import SwiftUI

struct AxisLines: View {
    let size: CGSize
    @Binding var horizontalRipple: Bool
    @Binding var verticalRipple: Bool

    @State private var horizontalRippleScale: CGFloat = 1
    @State private var horizontalRippleOpacity: Double = 0
    @State private var verticalRippleScale: CGFloat = 1
    @State private var verticalRippleOpacity: Double = 0

    var body: some View {
        ZStack {
            // Vertical axis (Urgency)
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            .white.opacity(0),
                            .white.opacity(0.3),
                            .white.opacity(0.3),
                            .white.opacity(0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 2)
                .position(x: size.width / 2, y: size.height / 2)

            // Vertical ripple effect
            Capsule()
                .fill(Color.white.opacity(verticalRippleOpacity))
                .frame(width: 4, height: size.height * 0.8)
                .scaleEffect(x: verticalRippleScale, y: 1)
                .position(x: size.width / 2, y: size.height / 2)

            // Horizontal axis (Importance)
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            .white.opacity(0),
                            .white.opacity(0.3),
                            .white.opacity(0.3),
                            .white.opacity(0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
                .position(x: size.width / 2, y: size.height / 2)

            // Horizontal ripple effect
            Capsule()
                .fill(Color.white.opacity(horizontalRippleOpacity))
                .frame(width: size.width * 0.8, height: 4)
                .scaleEffect(x: 1, y: horizontalRippleScale)
                .position(x: size.width / 2, y: size.height / 2)

            // Axis labels
            axisLabels
        }
        .onChange(of: horizontalRipple) { _, triggered in
            if triggered {
                triggerHorizontalRipple()
            }
        }
        .onChange(of: verticalRipple) { _, triggered in
            if triggered {
                triggerVerticalRipple()
            }
        }
    }

    private var axisLabels: some View {
        ZStack {
            // Urgent label (left)
            Text("URGENT")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.4))
                .position(x: size.width * 0.25, y: size.height / 2 - 12)

            // Not Urgent label (right)
            Text("NOT URGENT")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.4))
                .position(x: size.width * 0.75, y: size.height / 2 - 12)

            // Important label (top)
            Text("IMPORTANT")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.4))
                .rotationEffect(.degrees(-90))
                .position(x: size.width / 2 + 12, y: size.height * 0.25)

            // Not Important label (bottom)
            Text("NOT IMPORTANT")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.4))
                .rotationEffect(.degrees(-90))
                .position(x: size.width / 2 + 12, y: size.height * 0.75)
        }
    }

    private func triggerHorizontalRipple() {
        horizontalRippleScale = 1
        horizontalRippleOpacity = 0.5

        withAnimation(EisenFlowAnimation.ripple) {
            horizontalRippleScale = 3
            horizontalRippleOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            horizontalRipple = false
        }
    }

    private func triggerVerticalRipple() {
        verticalRippleScale = 1
        verticalRippleOpacity = 0.5

        withAnimation(EisenFlowAnimation.ripple) {
            verticalRippleScale = 3
            verticalRippleOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            verticalRipple = false
        }
    }
}

#Preview {
    GeometryReader { geometry in
        ZStack {
            MeshGradientBackground()
            AxisLines(
                size: geometry.size,
                horizontalRipple: .constant(false),
                verticalRipple: .constant(false)
            )
        }
    }
}
