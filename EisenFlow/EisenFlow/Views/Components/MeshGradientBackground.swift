import SwiftUI

/// An animated mesh gradient background
struct MeshGradientBackground: View {
    @State private var animationPhase: CGFloat = 0

    // Soft, muted colors for the background
    private let colors: [Color] = [
        Color(red: 0.15, green: 0.12, blue: 0.25),  // Deep purple
        Color(red: 0.12, green: 0.15, blue: 0.28),  // Deep blue
        Color(red: 0.18, green: 0.14, blue: 0.26),  // Muted purple
        Color(red: 0.14, green: 0.18, blue: 0.30),  // Steel blue
        Color(red: 0.16, green: 0.14, blue: 0.24),  // Soft purple
        Color(red: 0.13, green: 0.16, blue: 0.27),  // Twilight
        Color(red: 0.17, green: 0.13, blue: 0.23),  // Dusty purple
        Color(red: 0.12, green: 0.14, blue: 0.25),  // Night blue
        Color(red: 0.15, green: 0.15, blue: 0.26),  // Neutral purple
    ]

    private var animatedPoints: [SIMD2<Float>] {
        let offset = Float(sin(animationPhase * .pi * 2) * 0.03)
        let offset2 = Float(cos(animationPhase * .pi * 2) * 0.02)

        return [
            // Row 0
            SIMD2<Float>(0.0, 0.0),
            SIMD2<Float>(0.5 + offset2, 0.0),
            SIMD2<Float>(1.0, 0.0),
            // Row 1
            SIMD2<Float>(0.0, 0.5 + offset),
            SIMD2<Float>(0.5 + offset, 0.5 - offset),
            SIMD2<Float>(1.0, 0.5 - offset2),
            // Row 2
            SIMD2<Float>(0.0, 1.0),
            SIMD2<Float>(0.5 - offset2, 1.0),
            SIMD2<Float>(1.0, 1.0),
        ]
    }

    var body: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: animatedPoints,
            colors: colors,
            smoothsColors: true
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(
                .easeInOut(duration: 10)
                .repeatForever(autoreverses: true)
            ) {
                animationPhase = 1
            }
        }
    }
}

/// A lighter version for certain UI elements
struct LightMeshGradientBackground: View {
    @State private var animationPhase: CGFloat = 0

    private let colors: [Color] = [
        Color(red: 0.95, green: 0.93, blue: 0.98),
        Color(red: 0.93, green: 0.95, blue: 0.99),
        Color(red: 0.96, green: 0.94, blue: 0.97),
        Color(red: 0.94, green: 0.96, blue: 0.99),
        Color(red: 0.95, green: 0.95, blue: 0.98),
        Color(red: 0.93, green: 0.94, blue: 0.98),
        Color(red: 0.96, green: 0.93, blue: 0.97),
        Color(red: 0.94, green: 0.95, blue: 0.98),
        Color(red: 0.95, green: 0.94, blue: 0.97),
    ]

    private var animatedPoints: [SIMD2<Float>] {
        let offset = Float(sin(animationPhase * .pi * 2) * 0.02)

        return [
            SIMD2<Float>(0.0, 0.0),
            SIMD2<Float>(0.5, 0.0),
            SIMD2<Float>(1.0, 0.0),
            SIMD2<Float>(0.0, 0.5),
            SIMD2<Float>(0.5 + offset, 0.5 - offset),
            SIMD2<Float>(1.0, 0.5),
            SIMD2<Float>(0.0, 1.0),
            SIMD2<Float>(0.5, 1.0),
            SIMD2<Float>(1.0, 1.0),
        ]
    }

    var body: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: animatedPoints,
            colors: colors,
            smoothsColors: true
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(
                .easeInOut(duration: 12)
                .repeatForever(autoreverses: true)
            ) {
                animationPhase = 1
            }
        }
    }
}

#Preview("Dark Background") {
    MeshGradientBackground()
}

#Preview("Light Background") {
    LightMeshGradientBackground()
}
