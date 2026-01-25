import SwiftUI

struct QuadrantView: View {
    let quadrant: Quadrant
    let isHighlighted: Bool
    let frame: CGRect

    @State private var glowOpacity: Double = 0

    var body: some View {
        ZStack {
            // Background with glass effect
            SuperellipseShape(cornerRadius: 20)
                .fill(.ultraThinMaterial.opacity(0.3))

            // Colored overlay
            SuperellipseShape(cornerRadius: 20)
                .fill(quadrant.accentColor.opacity(0.1))

            // Highlight glow (magnetic zone effect)
            SuperellipseShape(cornerRadius: 20)
                .fill(quadrant.glowColor)
                .opacity(glowOpacity)

            // Inner glow when highlighted
            if isHighlighted {
                SuperellipseShape(cornerRadius: 20)
                    .stroke(quadrant.accentColor.opacity(0.5), lineWidth: 2)
                    .blur(radius: 4)
            }

            // Quadrant label
            VStack(spacing: 4) {
                Text(quadrant.title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(quadrant.accentColor.opacity(0.6))

                Text(quadrant.subtitle)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary.opacity(0.5))
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: labelAlignment)
        }
        .frame(width: frame.width, height: frame.height)
        .position(x: frame.midX, y: frame.midY)
        .onChange(of: isHighlighted) { _, highlighted in
            withAnimation(EisenFlowAnimation.magneticGlow) {
                glowOpacity = highlighted ? 0.3 : 0
            }
            if highlighted {
                HapticManager.shared.quadrantEntered()
            }
        }
    }

    private var labelAlignment: Alignment {
        switch quadrant {
        case .urgentImportant: return .topLeading
        case .notUrgentImportant: return .topTrailing
        case .urgentNotImportant: return .bottomLeading
        case .notUrgentNotImportant: return .bottomTrailing
        }
    }
}

#Preview {
    GeometryReader { geometry in
        ZStack {
            MeshGradientBackground()

            ForEach(Quadrant.allCases) { quadrant in
                QuadrantView(
                    quadrant: quadrant,
                    isHighlighted: quadrant == .urgentImportant,
                    frame: quadrant.frame(in: CGSize(width: geometry.size.width - 40, height: geometry.size.height - 40))
                )
            }
        }
        .padding(20)
    }
}
