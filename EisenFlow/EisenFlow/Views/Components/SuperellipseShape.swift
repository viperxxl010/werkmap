import SwiftUI

/// A shape with continuous (superellipse/squircle) corners like iOS app icons
struct SuperellipseShape: Shape {
    var cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        // Use continuous corner style for Apple-like rounded corners
        Path(roundedRect: rect, cornerRadius: cornerRadius, style: .continuous)
    }
}

/// Convenience view modifier for superellipse clipping
extension View {
    func superellipseClip(cornerRadius: CGFloat) -> some View {
        self.clipShape(SuperellipseShape(cornerRadius: cornerRadius))
    }

    func superellipseBorder(cornerRadius: CGFloat, color: Color, lineWidth: CGFloat = 1) -> some View {
        self.overlay(
            SuperellipseShape(cornerRadius: cornerRadius)
                .stroke(color, lineWidth: lineWidth)
        )
    }
}
