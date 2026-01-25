import SwiftUI

/// Centralized animation configurations for consistent feel
enum EisenFlowAnimation {
    /// Drop animation with bouncy landing
    static let drop = Animation.spring(duration: 0.5, bounce: 0.3, blendDuration: 0.1)

    /// Hover scale animation
    static let hover = Animation.spring(duration: 0.25, bounce: 0.2)

    /// Fade out for completed tasks
    static let fadeOut = Animation.easeOut(duration: 0.4)

    /// Ripple effect timing
    static let ripple = Animation.easeOut(duration: 0.3)

    /// Card scale on drag start
    static let dragScale = Animation.interpolatingSpring(
        mass: 0.5,
        stiffness: 200,
        damping: 15,
        initialVelocity: 0
    )

    /// Magnetic zone highlight
    static let magneticGlow = Animation.easeInOut(duration: 0.2)

    /// List item appearance
    static let listAppear = Animation.spring(duration: 0.4, bounce: 0.2)

    /// Confetti celebration
    static let confetti = Animation.easeOut(duration: 1.5)
}

/// View modifier for standard card hover effect
struct CardHoverEffect: ViewModifier {
    @State private var isHovered = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .shadow(
                color: .black.opacity(isHovered ? 0.15 : 0.1),
                radius: isHovered ? 12 : 8,
                y: isHovered ? 6 : 4
            )
            .animation(EisenFlowAnimation.hover, value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

extension View {
    func cardHoverEffect() -> some View {
        modifier(CardHoverEffect())
    }
}
